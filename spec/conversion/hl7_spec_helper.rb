require 'lib/hl7/HL7'
require 'lib/OHmodule/OhioHealthUtilities'
require 'lib/extended_base_classes'
require 'rspec'
require 'rspec/expectations'

def is_physician?( field )
  return true if field.nil? || !field.components[0..6].has_value?
 
  id = field.first
  name = field.components[1..6]
  ok = ( id =~ /^\d+$/ && field.to_s =~ /\w+PROV/ )
  name.has_value? ? ok && HL7Test.is_name?( name ) : ok
end

def pass?( messages, logic )
  failed = []
  messages.each{ |msg| failed << msg unless logic.call(msg) }
  failed
end

def pass_for_each?( messages, logic, segment )
  p = Proc.new{ |msg|
    seg_obj = msg[segment]
    return true if seg_obj.nil?
    
    ok = true
    seg_obj.each{ |seg| ok &&= logic.call(seg) }        
    ok
  }
  
  pass?( messages, p )
end

def log_example( example )
  $logger.info example_summary( example )
end 

def log_result( ary, example )
  if ary.empty?
    $logger.info "Passed for all records.\n"
  else
    $logger.error "!! Failed for #{ary.size} records !!\n".upcase
   
    ex = example.description
    ary.each{ |msg|
      $flagged[msg] ? $flagged[msg] << ex : $flagged[msg] = [ex]
    }
  end  
end

def example_summary( example )
  patt = example.metadata[:pattern]
  message = "#{example.metadata[:full_description]}"
  message << " (" + patt + ")" if patt
  message  
end 