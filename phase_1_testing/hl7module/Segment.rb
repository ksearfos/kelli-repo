# last updated 3/4/14
# last tested 3/4/14

module NewHL7 

  # has value of first segment in record of this type
  # if there are others, those are saved as Segment objects in @child_lines
  # e.g. if there are 3 OBX segments,
  #   self = Segment( obx1 )
  #   self.child_lines = [ Segment(obx2), Segment(obx3) ]
  class HL7::Segment  
    attr_accessor :fields, :lines, :full_text, :number_of_lines, :type
    
    def initialize( segment_text, type, is_child = false )
      @type = type.upcase    
      @full_text = segment_text
      @lines = segment_text.split( SEG_DELIM )    # an array of strings
      @number_of_lines = @lines.size
      @fields = []              # all fields in first line, as objects, e.g. [ f1,nil,f2,nil,f3 ]
      @field_text = []          # text of all fields in first line, e.g. [ "1",,"SMITH^JOHN^^JR.",,"12345" ]
      @child = is_child
      @child_lines = []         # array of all other lines of this same segment type, as Segment objects
      
      for i in 1...@number_of_lines    # ignore first line, e.g. won't run if there's only one line
        @child_lines << HL7::Segment.new( @lines[i], type, true )
      end
      
      break_into_fields    # sets @fields, @field_text
      
      hash_name = "#{@type.to_s}_FIELDS"
      @fields_by_index = HL7.const_defined?( hash_name ) ? HL7.const_get( hash_name ) : {}
    end 
    
    def to_s
      @full_text
    end
    
    def each_line
      yield(self)
      @child_lines.each{ |ch_obj| yield(ch_obj) }
    end
    
    def each_field
      @fields.each{ |f_obj| yield(f_obj) }
    end
    
    def [](which)
      field(which)
    end
    
    # only returns value of field with index/name specified in which for first line of this segment type
    # to get values in all lines, use all_fields() instead
    def field( which )
      if which.is_a?( Integer )   # already an index
        @fields[which-1]          # field count starts at 1, but array index starts at 0
      elsif which.is_a?( String ) || which.is_a?( Symbol )
        i = field_index( which )
        return nil unless i
        
        @fields[i-1]
      else
        puts "Cannot find field of type #{which.class}"
        nil
      end
    end
    
    # returns array of all values of field with index/name specified in which, including any in child lines
    def all_fields( which )
      all = [ field( which ) ]     # yes, this is an array
      @child_lines.each{ |seg_obj| all << seg_obj.field(which) }
      all
    end
    
    # if use asks for a field directly by name, e.g. as segment.patient_name, it will get routed through here
    def method_missing( sym, *args, &block )
      if @fields_by_index.has_key?( sym.downcase )
        field(sym.downcase)
      else
        super     # don't want it downcased here!
      end
    end
    
    # displays readable version of the fields, headed by the index of the field
    # e.g. 1: 12345, 2:, 3: SMITH^JOHN^^JR., 4: 19630506
    def view_fields
      last = @field_text.size    # last index
      for i in 1..last 
        print "#{i}:#{@field_text[i-1]}"
        print i == last ? "\n" : ", "
      end
    end
    
    # if user wants to add fields or field names not listed in default hash, use add
    # add[:newfield] = 13 adds :newfield at index 13, and/or aliases whatever field is already at that index
    def add( field, index )
      @fields_by_index[field] = index
    end
    
    private
    
    def break_into_fields   
      @field_text = lines.first.split( FIELD_DELIM )
      remove_name_field
      
      @field_text.each{ |f|
        @fields << ( f.empty? ? nil : HL7::Field.new( f ) )
      }
    end
    
    def field_index( name )
      n = name.downcase.to_sym
      @fields_by_index[n]
    end

    def remove_name_field
        first = @field_text[0]
        @field_text = @field_text[1..-1] if first == @type.to_s
    end
    
  end

end