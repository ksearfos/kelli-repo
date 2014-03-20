proj_dir = File.expand_path( "../..", __FILE__ )
require "#{proj_dir}/lib/extended_base_classes.rb"
require "#{proj_dir}/lib/hl7module/HL7.rb"

module OHProcs
  
  # does the given field of the record have a value?
  # returns true if at least one matching field has a value, false otherwise
  def self.has_val?( record, field )
    res = record.fetch_field( field )   # always returns an array
    res.has_value?
  end
  
  # do both of the given fields of the record have values?
  # returns true if both have values, false otherwise
  def self.both_have_vals?( record, field1, field2 )
    res1 = has_val?( record, field1 )
    res2 = has_val?( record, field2 )
    res1 && res2
  end
  
  # is the value of the given field in the record the value we desire?
  # returns true if at least one field matches the given value, false otherwise
  def self.is_val?( record, field, value )
    res = record.fetch_field( field )
    res.map{ |f| f.to_s }.include?( value.to_s )
  end

  # is_val? for proc
  # does the value of the given field in the record make the given code return true?
  # returns true if at least one field passes, false otherwise
  def self.matches?( record, field, code )
    res = record.fetch_field( field )
    res.each{ |val|
      next if val.nil?
      return true if code.call(val)
    }   
    return false  # no non-nil, or code never returned true
  end
  
  # checks if the values of two fields are the same - by default only checks cases where both fields have
  #+  non-empty values
  # optionally force checking of empty values - if you want f1 = "abc" and f2 = "" to count as not the same,
  #+  set check_empty to true
  def self.fields_are_same?( record, f1, f2, check_empty = false )
    res1 = record.fetch_field( f1 )
    res2 = record.fetch_field( f2 )
    return false if res1.size != res2.size    # if there isn't a 1:1 mapping, they clearly aren't the same!
    
    for i in (0...res1.size)
      val1 = res1[i]
      val2 = res2[i]
      
      # if an array is empty, an index returns nil - but nil won't register as empty!
      val1 ||= ""
      val2 ||= ""
      
      next if ( !check_empty && ( val1.empty? || val2.empty? ) )  # empty values automatically pass if check_empty = false
      return false if ( val1.to_s != val2.to_s )       # I am assuming we want "1" and 1 to be considered the same
    end
    
    # if we get here, there were no non-empty fields that didn't contain the same text, so...
    return true
  end
    
  def self.comp_has_val?( record, field, comp )
    fs = record.fetch_field( field )
    fs.each{ |f|
      c = f[comp]
      next if c.nil?
      return true if !c.empty?   # component indices start at 1 in the message, so comp8 has index 7
    }
    return false       # no match in any of the fields
  end
  
  # at least one field in the record has a segment that matches the desired value
  def self.comp_is_val?( record, field, comp, val )
    fs = record.fetch_field( field )
    return false unless fs.has_value?

    fs.each{ |f| return true if ( f[comp] == val.to_s ) }
    return false       # no match in any of the fields
  end

  def self.is_type?( record, field, type )
    fs = record.fetch_field( field )
    
    method = nil
    case type.to_sym
    when :SN then method = :is_struct_num?
    when :NM then method = :is_numeric?
    when :TX then method = :is_text?
    else
      puts "I do not recognize type #{type}."
      return false
    end 
    
    fs.each{ |f| return true if HL7Test.send( method, f.to_s ) }
    false   # if we get here, not a single value was of the correct type
  end
  
  # creates group of procs all checking for a field to have one of the values in the given list (vals)
  # stores the whole group of procs as an array called [FIELD]_VALS
  # returns the new hash
  def self.define_group( field, vals, name )   
    all_procs = {}
    vals.each{ |s| 
      key = "#{name}_of_#{s}".to_sym    # :some_val_of_x
      all_procs[key] = Proc.new{ |rec| is_val?(rec,field,s) }
    }
    all_procs
    #const_name = "#{field.upcase}_VALS"
    #self.const_set( const_name, all_procs )
    #return self.const_get( const_name )  # just so there's no ambiguity about why there's a const_get here    
  end
end