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
end

class Hash
  def add_keys( val, *keys )
    keys.flatten.each{ |k| self[k] = val }
  end
  
  def remove_duplicate_values!
    clean = self.invert.invert    # inverting keeps only the first key to have a given value
    self.replace( clean )         # then revert back to keys being keys
  end
end