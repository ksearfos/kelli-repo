# adding dynamic functionality for segment-type Eigenclasses
# e.g. every segment will be a HL7::Segment, but it will also have a few attributes shared by its eigenclass:
#   @type, the type - :PID, :OBX, etc.
#   @field_index_maps - hashes containing the field-to-index mappings for each field, e.g. { :patient_name => 5, :patient_id => 3 }
# since these vary by segment type, and we want every segment of the same type to have the same values available, they should
#   be class-level variables; but they are obviously different for different segments
# now, I could create a static class for each segment type, but that is incredibly annoying and requires maintenance
# instead, I will create them at runtime, and we will only have 1 eigenclass for each segment type in the message we are reading
# remind me to add something to messagehandler to count/create those.....
module HL7Test
  
  class Segment     

    class << self
      # everything in here is a class-level variable/method
      attr_reader :type, :field_index_maps
      
      # setter
      def type=(t)
        @type = t
      end
           
      # setter
      def field_index_maps=(hash)
        @field_index_maps = hash
      end
      
      # writer
      def add( field, index )
        field_index_maps[field] = index
      end
    end
#============================    
end

def self.new_typed_segment(type)
  klass = Object.const_set(type.to_s.capitalize, Class.new(SegmentEigenclass))
  klass.type = type.upcase
  
  hash_name = "#{type.to_s}_FIELDS"
  klass.field_index_maps = HL7Test.const_defined?( hash_name ) ? HL7Test.const_get( hash_name ) : {}
  klass
end

end