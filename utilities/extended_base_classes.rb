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