#------------------------------------------
#
# MODULE: HL7
#
# CLASS: HL7::Segment
#
# DESC: Defines a segment in a HL7 message
#       A segment is essentially a single line of text, headed with a type (3 capital letters, e.g. 'PID')
#         and separated into fields with pipes (|)
#       The segment class keeps track of the full text of the segment minus the type, an array of its fields,
#         and any "child" segments described as segments of the same type. A single segment object will exist
#         for each line in the message, but the Message itself will only link to the first segment of any
#         given type--subsequent lines will be treated as children and manipulated through the parent segment
#       For example, if there are 4 OBX segments in one message: MESSAGE => OBX1 => OBX2, OBX3, OBX4
#       A segment will generally contain multiple fields
#
# EXAMPLE: PID => "|12345||SMITH^JOHN||19631017|M|||" / [,"12345",,"SMITH^JOHN",,"19631017","M",,]
# 
# CLASS VARIABLES: uses HL7::SEG_DELIM, HL7::FIELD_DELIM, and the HL7::[type]_FIELDS hash for its type
#    @@field_by_index [Hash]: stores the name of each field mapped to its index (for the @fields & @field_text Arrays)
#
# READ-ONLY INSTANCE VARIABLES:
#    @original_text [String]: stores the text originally found in the segment, e.g. "|12345||SMITH^JOHN||19631017|M|||"
#    @fields [Array]: stores each field in the segment as a HL7::Field object, e.g. [nil,F1,nil,F2,nil,F3,F4,nil,nil]
#    @lines [Array]: stores the original text for each line containing a segment of this type
#             ====>  for example, for 2 OBX segments: @lines = [ "1|TX|My favorite number is:", "2|NM|42" ]
#    @number_of_lines [Integer]: the number of lines/segments of this type in the message; basically @lines.size
#    @type [Symbol]: the type of segment, e.g. :OBX or :PID
#
# PRIVATE INSTANCE VARIABLES:
#    @field_text [Array]: stores the text of each field, e.g. ["","12345","","SMITH^JOHN","","19631017","M","",""]
#    @child [Boolean]: false if this is a parent, i.e. the first segment of this type in the message; false otherwise
#    @child_segs [Array]: stores each of this segment's children as HL7::Segment objects
#
# CLASS METHODS: none
#
# INSTANCE METHODS:
#    new(segment_text): creates new Segment object based off of given text
#    to_s: returns String form of Segment (including child segments)
#    [](which): returns Field with given name or at given index - count starts at 1
#    field(which): alias for []
#    each(&block): loops through each field in each segment of this type (parent and children),
#                  executing given code
#             ==>  for most Segments, this will do the same thing as each_field
#    each_line(&block): loops through each segment of this type, executing given code
#    each_field(&block): loops through each field, executing given code
#    method_missing: tries to reference a field with the name of the method; then throws exception
#    view: prints fields (and children's fields) to stdout in readable form, headed by component index
#    add(field,index): adds name for the field at the given index
#
# CREATED BY: Kelli Searfos
#
# LAST UPDATED: 3/6/14 9:38 AM
#
# LAST TESTED: 3/4/14
#
#------------------------------------------

module HL7Test 

  # has value of first segment in record of this type
  # if there are others, those are saved as Segment objects in @child_segs
  # e.g. if there are 3 OBX segments,
  #   self = Segment( obx1 )
  #   self.child_segs = [ Segment(obx2), Segment(obx3) ]  
  class SegmentGroup     
    attr_accessor :lines, :original_text, :size
    
    # NAME: new
    # DESC: creates a new HL7::Segment object from its original text
    # ARGS: 2
    #  segment_text [String] - the text of the segment, with or without its Type field
    #  type [Symbol/String] - the type of segment, e.g. PID or OBX
    # RETURNS:
    #  [HL7::Segment] newly-created Segment
    # EXAMPLE:
    #  HL7::Field.new( "PID|a|b|c", "PID" ) => new PID Segment with text "a|b|c" and fields ["a","b","c"]
    def initialize( segment_text, type )
      @lines = segment_text.split( SEG_DELIM )    # an array of strings
         
      @original_text = lines.first
      @size = lines.size
      # @number_of_lines = @lines.size
      @fields = []              # all fields in first line, as objects, e.g. [ f1,nil,f2,nil,f3 ]
      
      # the remaining instance variables are not accessible outside the class
      # @field_text = []          # text of all fields in first line, e.g. [ "1",,"SMITH^JOHN^^JR.",,"12345" ]
      # @child = is_child
      @segments = []         # array of all Segments of this same segment type
      
      for i in 0...@size    # ignore first line, e.g. won't run if there's only one line
        @children << TypedSegment.new( lines[i], type )
      end
      
      break_into_fields    # sets @fields, @field_text
      
      hash_name = "#{@type.to_s}_FIELDS"
      @@fields_by_index = HL7Test.const_defined?( hash_name ) ? HL7Test.const_get( hash_name ) : {}
    end 
    
    # NAME: to_s
    # DESC: returns this line of the segment as a String object - does NOT return child segments' text
    # ARGS: none 
    # RETURNS:
    #  [String] the segment in textual form, with the type field added back in
    # EXAMPLE:
    #  segment.to_s => "TYPE|a|b|c"
    def to_s
      type.to_s + FIELD_DELIM + @original_text
    end

    # NAME: each
    # DESC: performs actions for each field in each line of the segment
    # ARGS: 1
    #  [code block] - the code to execute on each field
    # RETURNS: nothing, unless specified in the code block
    # EXAMPLE:
    #  1-line segment: segment.each{ |f| print f + " & " } => a & b & c
    #  2-line segment: segment.each{ |f| print f + " & " } => a & b & c
    #                                                         a2 & b2 & c2    
    def each
      each_line{ |seg| seg.each_field{ |f| yield(f) } }
    end

    # NAME: each_line
    # DESC: performs actions for each line of the segment
    # ARGS: 1
    #  [code block] - the code to execute on each line
    # RETURNS: nothing, unless specified in the code block
    # EXAMPLE:
    #  segment.each_line{ |l| print l.to_s + ' & ' } => a|b|c & a2|b2|c2 & a3|b3|c3 
    def each_line
      yield(self)
      @child_segs.each{ |ch_obj| yield(ch_obj) }
    end

    # NAME: each_field
    # DESC: performs actions for each field of this line of the segment
    # ARGS: 1
    #  [code block] - the code to execute on each line
    # RETURNS: nothing, unless specified in the code block
    # EXAMPLE:
    #  segment.each_field{ |f| print f.to_s + ' & ' } => a & b & c     
    def each_field
      @fields.each{ |f_obj| yield(f_obj) }
    end

    # NAME: []
    # DESC: returns field at given index (in this line only!)
    # ARGS: 1
    #  index [Integer/Symbol/String] - the index or name of the field we want -- count starts at 1
    # RETURNS:
    #  [String] the value of the field
    # EXAMPLE:
    #  segment[2] => "b"
    #  segment[:beta] => "b"  
    # ALIASES: field()  
    def [](which)
      field(which)
    end
    
    # NAME: field
    # DESC: returns field at given index (in this line only!)
    # ARGS: 1
    #  index [Integer/Symbol/String] - the index or name of the field we want -- count starts at 1
    # RETURNS:
    #  [String] the value of the field
    # EXAMPLE:
    #  segment.field(2) => "b"
    #  segment.field(:beta) => "b" 
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
    
    # NAME: all_fields
    # DESC: returns array of fields at given index (in this line and all children!)
    # ARGS: 1
    #  index [Integer/Symbol/String] - the index or name of the field we want -- count starts at 1
    # RETURNS:
    #  [Array] the value of the field for each line
    #      ==>  if there is only one line of this segment's type, returns field() IN AN ARRAY
    # EXAMPLE:
    #  segment.all_fields(2) => [ "b", "b2", "b3" ]
    #  segment.all_fields(:beta) => [ "b", "b2", "b3" ] 
    def all_fields( which )
      all = [ field( which ) ]     # yes, this is an array
      @child_segs.each{ |seg_obj| all << seg_obj.field(which) }
      all
    end
    
    # NAME: method_missing
    # DESC: handles methods not defined for the class
    # ARGS: 1+
    #  sym [Symbol] - symbol representing the name of the method called
    #  *args - all arguments passed to the method call
    #  [code block] - optional code block passed to the method call
    # RETURNS: depends on handling
    #     ==>  first checks @@fields_by_index for a key by that name, and calls field(key)
    #     ==>  then gives up and throws an Exception
    # EXAMPLE:
    #  segment.patient_name => "SMITH^JOHN" (calls field(:patient_name) )
    #  segment.5 => throws NoMethodError (5 is a value in @@fields_by_index, NOT a key)
    #  segment.fake_method => throws NoMethodError
    def method_missing( sym, *args, &block )
      if @@fields_by_index.has_key?( sym.downcase )
        field(sym.downcase)
      else
        super     # don't want it downcased here!
      end
    end

    # NAME: view
    # DESC: displays the fields, for each line, clearly enumerated
    # ARGS: none
    # RETURNS: nothing; writes to stdout
    # EXAMPLE:
    #  1-line segment: segment.view => 1:a, 2:b, 3:c
    #  2-line segment: segment.view => 1:a, 2:b, 3:c
    #                                  1:a2, 2:b2, 3:c2
    def view
      last = @field_text.size    # last index
      for i in 1..last 
        print "#{i}:#{@field_text[i-1]}"
        print i == last ? "\n" : ", "
      end
      @child_segs.each{ |seg| seg.view }
    end

    # NAME: view
    # DESC: displays the components, clearly enumerated
    # ARGS: none
    # RETURNS: nothing; writes to stdout
    # EXAMPLE:
    #  field.view => 1:a, 2:b, 3:c
    #  field.view => 1:Smith, 2:John, 3:, 4:III    
    # if user wants to add fields or field names not listed in default hash, use add
    # add[:newfield] = 13 adds :newfield at index 13, and/or aliases whatever field is already at that index
    def add( field, index )
      each_line{ |l| l.fields_by_index[field] = index }
    end
    
    private
    
    def break_into_fields   
      @field_text = lines.first.split( FIELD_DELIM )
      remove_name_field
      
      @field_text.each{ |f|
        @fields << ( f.empty? ? nil : Field.new( f ) )
      }
    end
    
    def field_index( name )
      n = name.downcase.to_sym
      @@fields_by_index[n]
    end

    def remove_name_field
        first = @field_text[0]
        @field_text = @field_text[1..-1] if first == @type.to_s
    end
    
  end

end