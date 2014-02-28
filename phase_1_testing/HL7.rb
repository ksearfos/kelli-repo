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
        end_of_type = seg.index( FIELD_DELIM )   # first occurrence of delimiter => end of the type field
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
    
    # displays readable version of the segments, headed by the type of the segment
    # e.g. PID: abc|123456||SMITH^JOHN^^IV|||19840106
    def view_segments
      @segment_text.each{ |type,text| 
        text.each{ |line| print type.to_s + ": " + line }
      }
    end
    
    # not rewritten yet
    def fetch_field( field )
      seg = field[0...3]   # first three charcters, the name of the segment - have to do it this way for PV1 etc.
      f = field[3..-1]     # remaining 1-3 characters, the number of the field
       
      seg_obj = @segments[seg.upcase.to_sym]   # segment expected to be an uppercase symbol
      return nil if seg_obj.nil?
      seg_obj.fetch_field( field )
    end
  end
  
  class HL7::Segment  
    attr_accessor :fields, :lines, :full_text
    
    def initialize( segment_text )
      @full_text = segment_text
      @lines = segment_text.split( SEG_DELIM )    # an array don't forget
      @fields = {}
      @field_text = {}
      break_into_fields    # sets @fields
      
      # blah blah stuff happens with text
      # parsing into records - or are they messages?
    end  
    
    private
    
    def break_into_fields    
      segments = @message.split( SEG_DELIM )   # all segments, including the type found in field 0
      segments.each{ |seg|
        end_of_type = seg.index( FIELD_DELIM )   # first occurrence of delimiter => end of the type field
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
    
    # displays readable version of the segments, headed by the type of the segment
    # e.g. PID: abc|123456||SMITH^JOHN^^IV|||19840106
    def view_segments
      @segment_text.each{ |type,text| 
        text.each{ |line| print type.to_s + ": " + line }
      }
    end
    
    # not rewritten yet
    def fetch_field( field )
      seg = field[0...3]   # first three charcters, the name of the segment - have to do it this way for PV1 etc.
      f = field[3..-1]     # remaining 1-3 characters, the number of the field
       
      seg_obj = @segments[seg.upcase.to_sym]   # segment expected to be an uppercase symbol
      return nil if seg_obj.nil?
      seg_obj.fetch_field( field )
    end
  end
  
  # reads in a HL7 message as a text file from the given filepath
  # changes coding to end in \n for easier parsing
  # returns HL7::Message object
  def HL7::read_message( file )
    puts "Reading #{file}..."
    msg = File.open( file ) { |f| f.gets.chop }
    msg.tr!( "\r\n", SEG_DELIM )    # really don't know whether it will have CRLF or CR, but
    msg.tr!( "\r", SEG_DELIM )      #+ ruby always plays nicely with plain ol' LF
    HL7::Message.new( msg )         
  end
end