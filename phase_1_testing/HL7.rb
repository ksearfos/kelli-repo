module HL7
  SEG_DELIM = "\n"       # split into segments across lines, currently
  FIELD_DELIM = "|"      # fields of a segment are separated by this
  COMP_DELIM = "^"       # components in a field are separated by this
  DUP_DELIM = "~"        # duplicate information in a single field is separated by this
  HDR = /\d+MSH/         # regex defining header row
  
  class HL7::Message  
    attr_accessor :segments, :lines, :message
    
    def initialize( message_text )
      @message = message_text
      @lines = []
      @segments = {}
      @segment_text = {}
      break_into_segments    # sets @lines, @segments
      
      # blah blah stuff happens with text
      # parsing into records - or are they messages?
    end  
    
    private
    
    def break_into_segments    
      segments = @message.split( SEG_DELIM )   # all segments, including the type found in field 0
      segments.each{ |seg|
        end_of_type = seg.index( @@FIELD_DELIM )   # first occurrence of delimiter => end of the type field
        type = seg[0...end_of_type]
        body = seg[end_of_type+1..-1]
        is_hdr = ( type =~ HDR )               # is this a header line?        
        type = ( is_hdr ? :MSH : type.upcase.to_sym )
        
        # save segment text in @segment_text as arrays, linked to by segment name
        #+  e.g. { :MSH => [header_text], :OBX => [obx_text1, obx_text2, obx_text3] }
        # also save order of original segments as @lines
        #+  e.g. [:MSH, :PID, :PV1, :OBX, :OBX, :OBX ]
        ary = @segment_text[type]                       # might be nil, might be an array
        ary ? @segment_text[type] << body : @segment_text[type] = [body]
        @lines << type                 # what line of the message this field comes in
      }
      
      # now convert segment text into segment object and add to @segments
      #+  e.g. { :MSH => mshObj, :PID => pidObj, :OBX => obxObj }
      # let objects track multiple occurrences -- 7 obx segments is still 1 OBX object
      segment_text.each{ |type,text|
        line = text.join( SEG_DELIM )
        @segments[type] = HL7::Segment.new( line )  
      }
    end
    
    def view_segments
      puts @segment_text.each{ |k,v| puts k.to_s + ": " + v.to_s }
  end
  end
  
  # reads in a HL7 message as a text file from the given filepath
  # changes coding to end in \n for easier parsing
  # returns HL7::Message object
  def HL7::read_message( file )
    puts "Reading #{file}..."
    msg = File.open( file ) { |f| f.gets.chop }
    msg.tr!( "\r\n", SEG_DELIM )
    msg.tr!( "\r", SEG_DELIM )        # really don't know whether it will be CRLN or just CR
    HL7::Message.new( msg )
  end
end