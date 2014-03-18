require 'lib/hl7module/HL7'
require 'rspec'
require 'rspec/expectations'

RSpec.configure do |config|
  
  config.after(:each) do
    flag_example_exception( example, $message ) if example.exception   # store specifics for future logging
  end

end

def flag_example_exception( example, message )
  exception_message = example.exception.to_s.split("Diff:")[0].chomp

  patt = example.metadata[:pattern]
  error_message = "#{example.metadata[:full_description]}"
  error_message << "(" + patt + ")" if patt
  error_message << "\n" + exception_message
  
  dets = patient_details(message)
  if $flagged_messages.has_key?( dets )
    $flagged_messages[dets] << error_message
  else
    $flagged_messages[dets] = [error_message]
  end
end

def patient_details( message )
  det = message.details
  str = <<-END
  Message Date: #{message.header.field(:date_time).as_datetime}
  Patient: #{det[:PT_ID]} - #{det[:PT_NAME]}
  Account: #{det[:PT_ACCT]}
  Date of Birth: #{det[:DOB]}      
  END

  if message.type != :adt
    str << "  Procedure: #{det[:PROC_NAME]} on #{det[:PROC_DATE]}\n"
  end
  
  str
end