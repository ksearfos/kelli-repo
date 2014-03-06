# last updated 2/28/14 3:35pm

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
  # e.g. [], [nil] and ["",""] all return false
  def has_value?
    return false if empty?
    
    new = self.clone                   # otherwise it will change the value of self, and we don't want that!
    new.flatten!
    new.keep_if{ |val| (val && !val.to_s.empty?) }   # remove all empty values
    !new.empty?                        # is there anything left?
  end
end

class Hash
  def add_keys( val, *keys )
    keys.flatten.each{ |k| self[k] = val }
  end
  
  # removes key-value pairs that have the same value as other pairs
  # thanks to the magic of Hash.invert, it keeps the LAST pair to have a given value
  # EXAMPLE:
  # { "one" => 1, "uno" => 1, "two" => 2 } ==> { "uno" => 1, "two" => 2 }
  def remove_duplicate_values!
    clean = self.invert.invert    # inverting keeps only one key with a given value...
    self.replace( clean )         #+ then revert back to keys being keys
  end

  # "flips" an array, essentially inverting it but keeping track of all of the keys-turned-values
  # Hash.invert will only keep the last key it finds that has a given value; this will keep them all
  # to demonstrate, imagine the hash { "one"=>1, "uno"=>1, "two"=>2 }
  #   invert: { 1=> "uno", 2 => "two" }   -- note that this loses 1 => "one"
  #   flip: { 1 => ["one","uno"], 2 => ["two"] }  -- note that this retains all values (though even single values become Arrays)
  def flip
    ary = self.sort_by{ |_,value| value }   # sorts in order by value, and returns an array of key-value pairs [ ["a",1], ["b",1] ]

    new_hash = {}
    ary.each{ |new_val,new_key| 
      new_hash.has_key?( new_key ) ? new_hash[new_key] << new_val : new_hash[new_key] = [ new_val ]
    }

    new_hash
  end
  
  # what do you think this does?
  # yep, it does that
  def flip!
    newh = flip
    self.replace( newh )
  end
end