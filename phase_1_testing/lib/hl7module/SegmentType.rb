
module HL7Test 
 
  class SegmentType     
    attr_accessor :type, :field_index_map

    def initialize( type, map = {} )   
      @type = type.upcase.to_sym    
      
      hash_name = "#{@type.to_s}_FIELDS"
      @field_index_map = HL7Test.const_defined?( hash_name ) ? HL7Test.const_get( hash_name ) : {}
      @field_index_map.merge!( map )
    end 
    
    # NAME: to_s
    # DESC: returns this segment type
    # ARGS: none 
    # RETURNS:
    #  [String] the type
    # EXAMPLE:
    #  type.to_s => "PID"
    def to_s
      @type.to_s
    end

    # NAME: []
    # DESC: returns value for the given key
    # ARGS: 1
    #  key [Symbol/String] - the key whose value we want
    # RETURNS:
    #  [Integer] the index for the given type
    # EXAMPLE:
    #  type[:patient_id] => 5
    def [](key)
      @field_index_map[key]
    end
    
    def []=(name,index)
      @field_index_map[name] = index
    end
    
    # NAME: method_missing
    # DESC: handles methods not defined for the class
    # ARGS: 1+
    #  sym [Symbol] - symbol representing the name of the method called
    #  *args - all arguments passed to the method call
    #  [code block] - optional code block passed to the method call
    # RETURNS: depends on handling
    #     ==>  first checks @@field_index_map for a matching method
    #     ==>  then gives up and throws an Exception
    # EXAMPLE:
    #  segment.keys => [ :set_id, :patient_id, :patient_name, :ssn, :sex ]
    #  segment.fake_method => throws NoMethodError
    def method_missing( sym, *args, &block )
      if Hash.method_defined?( sym )
        @fields_index_map.send( sym, *args )
      else
        super     # don't want it downcased here!
      end
    end

    # NAME: view
    # DESC: displays the keys and their indices
    # ARGS: none
    # RETURNS: nothing; writes to stdout
    # EXAMPLE:
    #  types.view ==> PID segment
    #                 {1=>[:set_id], 2=>[:type], 3=>[:patient_id, :id, :ptid]}
    def view
      puts "#{type} segment"
      fim = @field_index_map.clone               # funny things happen if you don't clone
      tmp_ary = fim.sort_by{ |_,index| index }    # sorts ascending order by index -- returns an array, for some reason
      tmp_hash = {}
      fim.values.uniq.each{ |v| tmp_hash[v] = [] }
      tmp_ary.each{ |v,k| tmp_hash[k] << v }
      puts tmp_hash
    end

    # NAME: add
    # DESC: adds a new field-index pair to @field_index_map
    # ARGS: none
    # RETURNS: nothing; updates @field_index_map
    # EXAMPLE:
    #  type.add(:newfield,13) ==> @field_by_index[:newfield] => 13
    def add( name, index)
      @field_index_map[name] = index
    end
  end
end