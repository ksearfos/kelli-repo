# last updated 3/4/14
# last tested 3/4/14

module HL7
   
  class Message  
    attr_accessor :segments, :lines, :message, :id
    
    def initialize( message_text )
      @message = message_text
      @lines = []
      @segments = {}         # { :SEG_TYPE => Segment object }
      @segment_text = {}     # { :SEG_TYPE => raw_text }

      break_into_segments    # sets @lines, @segments
      
      @id = header.message_control_id
    end  
    
    def to_s
      @message
    end
    
    def []( key )
      @segments[key]
    end
    
    def each_segment
      @segments.each_pair{ |seg_type,seg_obj| yield(seg_type,seg_obj) }  
    end
    
    def method_missing( sym, *args, &block )
      if Array.method_defined?( sym )
        @segments.send( sym, *args, block )
      else
        super
      end
    end
    
    def header
      @segments[:MSH]
    end

    def view_details
      puts "Message ID: " + @id
      puts "Sent at: " + @segments[:MSH].date_time.as_datetime
      puts "Patient ID: " + important_details( :patient_id )
      puts "Patient Name: " + important_details( :patient_name )
      puts "Visit Number: " + important_details( :visit_number )
      puts ""
    end
    
    # returns a hash, or just text if segment specified
    #+  e.g. encounter_details() => { :ID => "12345", :NAME => "SMITH^JOHN", :VISIT => "01834" }
    #+       encounter_details(:ID) => "12345"
    def encounter_details( *section )
      me = { :ID => important_details( :patient_id ),
             :NAME => important_details( :patient_name ),
             :VISIT => important_details( :visit_number ) }
             
      ( section.empty? ? me : me[section] )
    end
    
    # displays readable version of the segments, headed by the type of the segment
    # e.g. PID: abc|123456||SMITH^JOHN^^IV|||19840106
    def view_segments
      each_segment{ |type,obj| 
        obj.lines.each{ |line| puts type.to_s + ": " + line }
      }
    end
    
    # returns an ARRAY of value(s) of segment/field given
    # this is for easy handling of segments that have more than one occurrence in a message
    #+  e.g. for PID|12345|||, fetch_field("pid1") => [ "12345" ]
    #+  and for OBX|1|20131223|
    #+          OBX|2|20131211|, fetch_field("obx2") => [ "20131223", "20131211" ]
    def fetch_field( field )
      seg = field[0...3]   # first three charcters, the name of the segment - have to do it this way for PV1 etc.
      f = field[3..-1]     # remaining 1-3 characters, the number of the field

      seg_obj = @segments[seg.upcase.to_sym]  # segment expected to be an uppercase symbol
      return nil if seg_obj.nil?
      seg_obj.all_fields( f.to_i )
    end

    # simple "translation" for most commonly referenced message pieces
    def important_details( type )
      case type
        when :patient_id then @segments[:PID][3].first_component
        when :patient_name then @segments[:PID][5].as_name
        when :visit_number then @segments[:PV1][19].first_component
        when :message_header then header
        when :message_id then @id
        else
          puts "I don't know where to look in the message to find the #{type}."
          return nil
      end
    end
    
    def segment_before( seg )
      i = @lines.index( seg )
      @lines[i-1]
    end
    
    def segment_after( seg )
      sinel = @lines.clone.reverse   # yeah, super-clever name, I know
      i = sinel.index( seg )
      sinel[i-1]    # before seg in reverse array == after the seg in original array
    end
    
    private
    
    def break_into_segments    
      segments = @message.split( SEG_DELIM )     # all segments, including the type found in field 0
      segments.each{ |seg|
        end_of_type = seg.index( FIELD_DELIM )   # first occurrence of delimiter => end of the type field
        type = seg[0...end_of_type]
        body = seg[end_of_type+1..-1]
        is_hdr = ( type =~ HDR )               # is this a header line?        
        type = ( is_hdr ? :MSH : type.upcase.to_sym )
        
        # save segment text in @segment_text as arrays, linked to by segment name
        #+  e.g. { :MSH => [header_text], :OBX => [obx_text1, obx_text2, obx_text3] }
        # also save order of original segments as @lines
        #+  e.g. [:MSH, :PID, :PV1, :OBR, :OBR, :OBX, :NTE, :NTE, :NTE ]
        ary = @segment_text[type]                       # might be nil, might be an array
        ary ? @segment_text[type] << body : @segment_text[type] = [body]
        @lines << type                 # what line of the message this field comes in
      }
      
      # now convert segment text into segment object and add to @segments
      #+  e.g. { :MSH => mshObj, :PID => pidObj, :OBX => obxObj }
      # let objects track multiple occurrences -- 7 obx segments is still 1 OBX object
      @segment_text.each{ |type,text|
        line = text.join( SEG_DELIM )
        @segments[type] = HL7::Segment.new( line, type )  
      }
    end
  end
end