# adding dynamic functionality for segment-type Eigenclasses
# e.g. every segment will be a HL7::Segment, but it will also have a few attributes shared by its eigenclass:
#   @type, the type - :PID, :OBX, etc.
#   @field_index_maps - hashes containing the field-to-index mappings for each field, e.g. { :patient_name => 5, :patient_id => 3 }
# since these vary by segment type, and we want every segment of the same type to have the same values available, they should
#   be class-level variables; but they are obviously different for different segments
# now, I could create a static class for each segment type, but that is incredibly annoying and requires maintenance
# instead, I will create them at runtime, and we will only have 1 eigenclass for each segment type in the message we are reading
module HL7Test
  
  class Segment     
    
    def self.is_eigenclass?
      self.instance_variable_defined?( :@type )
    end
    
    # instance-level accessors for the two added variables, @type and @field_index_maps
    def type
      self.class.type
    end
    
    def field_index_maps
      self.class.field_index_maps
    end
    
    # eigenclass stuff
    # used by child classes like Pid and Obx
    class << self
      # everything in here is a class-level variable/method, despite the fact that there's only one @
      attr_reader :type, :field_index_maps
      
      # setter
      def type=(t)
        @type = t
      end
           
      # setter
      def field_index_maps=(hash)
        @field_index_maps = hash
      end
      
      def add( field, index )
        field_index_maps[field] = index
      end
    end    
    
  end

  # out of the Segment class, back to the module
  def self.new_typed_segment(type)
    # create new class
    t = type.upcase
    klass = Object.const_set( t.to_s, Class.new(Segment) )   # => new class called TYPE
    klass.type = t
  
    # populate class variables @type, @field_index_maps
    # despite the names, they are class-level variables
    hash_name = "#{t}_FIELDS"
    klass.field_index_maps = HL7Test.const_defined?( hash_name ) ? HL7Test.const_get( hash_name ) : {}
        
    klass
  end
        
end