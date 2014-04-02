require 'lib/extended_base_classes'
require 'lib/hl7/HL7'

module OhioHealthUtilities
  
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
    when :TS then method = :is_timestamp?
    else
      puts "I do not recognize type #{type}."
      return false
    end 
    
    fs.each{ |f| return true if HL7.send( method, f.to_s ) }
    false   # if we get here, not a single value was of the correct type
  end

  def self.get_field_values_at_runtime(messages, message_type, criteria_to_add)
    criteria = self.const_get("#{message_type.upcase}_RUNTIME_FIELDS")
    criteria_to_add.each_pair do |criterion_name, field_of_reference| 
      criteria.merge! get_criteria_from_messages(messages, criterion_name, field_of_reference)
    end
    
    criteria
  end
  
  # creates group of procs all checking for a field to have one of the values in the given list (vals)
  # returns the new hash { :description_of_value => proc_that_checks_value }
  def self.define_group(field, all_values, description)   
    new_procs = {}
    all_values.each do |value| 
      proc_name = "#{description}_of_#{value}".to_sym    # :some_val_of_x, e.g. :blood_type_of_AB, etc.
      new_procs[proc_name] = Proc.new { |record| is_val?(record, field, value) }
    end
    new_procs    
  end
  
  def self.get_criteria_from_messages(messages, description, field)
    field_values = HL7.get_data(messages, field)
    define_group(field_of_reference, field_values, name)
  end
end