require 'ruby-hl7'

HDR = /\d+MSH/            # regex defining header row

#-------------------------CLASS EXTENSIONS-------------------------#

# need to recognize a header as such
class HL7::Message::Segment::MSH < HL7::Message::Segment
end

class HL7::Message
  
  # access a segment of the message
  # index:: can be a Range, Fixnum or anything that
  # responds to to_sym
  # modified to return only an array - previously would return Segment if there was only one value
  def []( index )
    ret = nil

    if index.kind_of?(Range) || index.kind_of?(Fixnum)
      ret = @segments[ index ]
    elsif (index.respond_to? :to_sym)
      ret = @segments_by_name[ index.to_sym ]
      
      # the following line was screwing everything up so I am removing it:
      # ret = ret.first if ret && ret.length == 1
    end

    ret
  end
  
  # overwrites default @segments_by_name variable to work in a more intuitive way :)
  # when this method is run, gives @segments_by_name the values of { name => array of all segment objects }
  # e.g. { :PID => [PID object 1, PID object 2] }
  # essentially this allows you to access field values by name, e.g. message[:PID][0].patient_name
  def create_children
    hash = {}
    
    @segments_by_name.each{ |k,v|
      is_hdr = k.to_s =~ HDR                # is this a header line?
      str = v.to_s
      tmp_ary = v.to_s.split( ", #{k}" )    # split into individual entries
      
      str_ary = [tmp_ary[0]]
      tmp_ary[1..-1].each{ |seg| str_ary << "#{k.to_s}#{seg}" }   # each entry except first lost its label initially,
                                                                  # so put it back
      cls = 'HL7::Message::Segment::'
      cls << ( is_hdr ? 'MSH' : k.to_s )    # soemthing like HL7::Message::Segment::PID
      
      seg_ary = []
      str_ary.each{ |s|
        seg_ary << eval( cls ).new( s )     # an array of objects of type HL7::Message::Segment::[segment name]
      }
      
      if is_hdr
        hash[:MSH] = seg_ary
        hash.delete( k )           # want segment called MSH and not 000000012345MSH
      else
        hash[k] = seg_ary
      end
    }
    
    @segments_by_name = hash       # overwrite default @segments_by_name so we can still use [] notation
  end
  
  # there is not actually a way to view @segments_by_name, so I have added this
  # prints something similar to:
  #      PID: PID|||12345||Name^Name^^^MI||||other stuff, PID|||1246||Name^Name^^^MI|||||
  #      ORC: ORC|RE, ORC|RE
  #      ...
  def view_children
    puts @segments_by_name.each{ |k,v| puts k.to_s + ": " + v.to_s }
  end
  
  def children
    @segments_by_name
  end
  
  # cheat method to allow you to grab field without having to break it into segments first
  # takes name of segment + field number as a single string, e.g. "pid8"
  # returns an array of the value of the segment's field for each contained field--empty if no matches
  def fetch_field( field )
    seg = field[0...3]   # first three charcters, the name of the segment - have to do it this way for PV1 etc.
    f = field[3..-1]     # remaining 1-3 characters, the number of the field

    seg.upcase!          # segment expected to be an uppercase symbol
    
    all = []
    segs = @segments_by_name[seg.to_sym]    # if there is more than one segment of this type,
    return all if segs.nil?                 #+  there will be more than value here
    
    segs.each{ |s| all << s.send( "e#{f}" ) }     # e8, e11, etc
    all
  end
end  # extension of HL7::Message

#------------------------------------FUNCTIONS---------------------------------#
# reads in text from a file
# nothing special except chops to remove empty lines
def get_hl7( file )
  puts "Reading #{file}..."
  File.open( file ) { |f| f.gets.chomp }
end

# returns array of strings containing hl7 message of individual records
# does NOT return HL7::Message objects!
def break_into_records( hl7 )
  hdrs = hl7.scan( HDR )       # all headers (will be needed later)
  recs = hl7.split( HDR )   # split across headers, yielding individual records
  recs.delete_if{ |r| r.empty? }

  all_recs = []
  for i in 0...hdrs.size
    #puts "\nRecord #{i+1}: \n"
    #p recs[i].gsub(/\n/, "\r")
    #print "Header ||::==>> " + hdrs[i].gsub(/\n/, "\r").to_s + recs[i].to_s
    all_recs << hdrs[i] + recs[i].chomp      # those pesky endline characters cause a LOT of problems!
  end
  
  all_recs
end

# this one returns HL7::Message objects
# return is an array of HL7::Messages that have already run create_children
# can access segments as hl7_by_record(stuff)[index][segment_name]
# e.g. hl7_messages_array[2][:PID].e7 returns the sex, as done hl7_messages_array[2][:PID].sex
def hl7_by_record( hl7 )
  all_recs = break_into_records(hl7)
  
  all_recs.map!{ |msg| HL7::Message.new( msg ) }   # array of HL7 messages, but not in usable form yet....
  all_recs.each{ |rec| rec.create_children }       # now objects are in preferred form
end

def orig_hl7_by_record( hl7 )
  all_recs = break_into_records(hl7)
  all_recs.map!{ |msg| msg.gsub!(/\n/, "\r") }  # HL7 gem likes carriage return
  all_recs.map!{ |msg| HL7::Message.new( msg ) }   # In HL7 gem format
  all_recs
end

def record_id( rec )
  rec[:MSH][0].message_control_id
end

def record_details( rec )
  puts "Message ID: " + record_id(rec)
  puts "Sent at: " + reformat_datetime( rec[:MSH][0].time )
  puts "Patient ID: " + rec[:PID][0].e3.before( "^" )
  puts "Patient Name: " + reformat_name( rec[:PID][0].patient_name )
end

# HL7 puts date into the following format: YYYYMMDD
# this will spit it back out as MM/DD/YYYY
def reformat_date( date_str, delim = "/" )
  yr = date_str[0...4]
  mon = date_str[4...6]
  day = date_str[6...8]
  
  mon + delim + day + delim + yr
end

# HL7 puts time into the following format: HHMM (24-hour clock)
# this will spit it back out as HH:MM AM/PM
def reformat_time( time_str )
  hr = time_str[0...2]
  min = time_str[2...4]

  ampm = "AM"
  if ( hr.to_i > 12 )
    am = "PM"
    hr = hr.to_i - 12
  end
  
  hr + ":" + min + " " + ampm
end

# HL7 puts time into the following format: YYYYMMDDHHNN (24-hour clock)
# this will spit it back out as MM/DD/YYYY HH:MM AM/PM
def reformat_datetime( dt_str )
  date = dt_str[0...8]
  time = dt_str[8...12]
  
  reformat_date( date ) + " " + reformat_time( time )
end

# HL7 puts names into the following format: Last^First^MI^Ext
# this will spit it back out as First MI Last Ext
def reformat_name( name )
  name_ary = name.split( "^" )
  last = name_ary[0]
  first = name_ary[1]
  mi = name_ary[2]
  ext = name_ary[3]
  
  mi_str = ( mi && !mi.empty? ? "#{mi} " : "" )
  ext_str = ( ext && !ext.empty? ? " #{ext}" : "" )
  
  first + " " + mi_str + last + ext_str
end

def components( field )
  field.split( "^" )
end
