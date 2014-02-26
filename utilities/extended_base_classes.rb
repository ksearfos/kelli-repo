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
end