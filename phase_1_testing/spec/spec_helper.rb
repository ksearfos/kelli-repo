require 'lib/hl7module/HL7'
require 'rspec'
require 'rspec/expectations'

def flag_example_exception( example, message )
  exception_message = example.exception.to_s.split("Diff:")[0].chomp

  patt = example.metadata[:pattern]
  error_message = "#{example.metadata[:full_description]}"
  error_message << " (" + patt + ")" if patt

  $errors << error_message
end

def patient_details( message )
  det = message.details
  str = <<-END
  Message Date: #{message.header.field(:date_time).as_datetime}
  Patient: #{det[:PT_ID]} - #{det[:PT_NAME]}
  Account: #{det[:PT_ACCT]}
  Date of Birth: #{det[:DOB]}      
  END

  str << "  Procedure: #{det[:PROC_NAME]} on #{det[:PROC_DATE]}\n" if message.type != :adt  
  str
end