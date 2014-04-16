# last updated 2/28/14 3:35pm

class Object
  def self.subclasses
    ObjectSpace.each_object(::Class).select{ |klass| klass < self }
  end
  
  def self.is_subclass?( klass )
    self.subclasses.include?(klass)
  end
end

# added the following to class String:
#    rem() / rem!()   This removes the given character(s) from the string
#                     Calls tr(), meaning removes all characters given but not sequence
class String
  # removes given characters -- avoids the need to add an empty string every time
  def rem( chs )
    tr( chs, "" )
  end

  def rem!( chs )
    tr!( chs, "" )
  end
  
  # returns portion of string before first occurence of ch
  def before( ch )
    i = index( ch )
    self[0...i]
  end
  
  # returns portion of string after first occurence of ch
  def after( ch )
    i = index( ch ) + 1
    self[i..-1]
  end
  
  # returns true if string is numeric, i.e. an integer or a decimal
  # returns false if not
  def is_numeric?
    strip!
    return false if self[0] !~ /-|\d/   # first character is a digit or negative sign?
    return false if self[-1] !~ /\d/    # last character is a digit?

    middle = self[1..-2] 
    return true if middle.empty?
    return middle =~ /^\d*\.?\d*$/   # middle is nothing but digits and a possible decimal point
  end
end

class Array
  # returns true if self is non-empty and has at least one non-empty index
  # false otherwise
  # e.g. [] and ["",""] both return false
  def has_value?
    return false if empty?
    
    new = self.clone                   # otherwise it will change the value of self, and we don't want that!
    new.keep_if{ |val| (val && !val.empty?) }   # remove all empty values
    !new.empty?                        # is there anything left?
  end

  def find_duplicates
    full_list = select { |element| count(element) > 1 }
    full_list.uniq
  end
  
  # as delete, except not destructive
  def remove(*elements)
    self - elements
  end
  
  def make_table   # should be an array of arrays
    num_cols = self.size
    max_rows = 0
    width = 0
    self.each{ |col|
      max_rows = col.size if col.size > max_rows      
      col.each{ |e| width = e.size if e.size > width }
    }
    
    str = ""
    for row_i in 0...max_rows
      self.each{ |col| str << "\t" + col[row_i].to_s.ljust(width) }
      str << "\n"
    end
    
    str
  end  
end

class Hash
  def +(other_hash)
    self.merge other_hash
  end
  
  def add_keys( val, *keys )
    keys.flatten.each{ |k| self[k] = val }
  end
  
  def remove_duplicate_values
    self.invert.invert    # inverting keeps only the first key to have a given value
  end                     # then revert back to keys being keys
  
  def remove_duplicate_values!
    self.replace( remove_duplicate_values )
  end

  def update_values!(&block)
    self.each{ |key,value| self[key] = yield(key,value) }  
  end
  
  def self.new_from_array( array, default_value=nil )
    Hash[array.collect { |key| [key,default_value] }]
  end

  # inverts Self, but keeps all keys linked to the same value
  # e.g { 1=>"a", 2=>"b", 3=>"a" } becomes { "a"=>[1,3], "b"=>2 }
  def flip
    new_hash = {}
    me_as_array = self.to_a
    me_as_array.map!{ |pair| pair.reverse }
    me_as_array.each{ |key,value|
      new_hash[key] ||= []
      new_hash[key] << value
    }
    new_hash  
  end
  
  def flip!
    self.replace( flip )
  end

  def delete_all( *keys )
    self.delete_if{ |key,_| keys.include?( key ) }
  end
end

class Numeric
  def positive?
    self > 0
  end
  
  def negative?
    self < 0
  end
end