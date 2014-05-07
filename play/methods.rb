def type
  message.type
end

def check_all(name)
  values = value_group(name)  
  check(*values)
end

def check(*values)
  values.each { |value| record.send(value, *args) } 
end

def correct_segments(*list)
  list.each { |segment| record.include?(segment) }
end

...