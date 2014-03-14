require 'lib/hl7module/HL7'
require 'rspec'
require 'rspec/expectations'

$test_descriptions = []
$flagged_messages = {}

RSpec.configure do |config|
  
  config.before(:suite) do
    $logger.info "Beginning test of message: #{$message.id}\n"
  end  
  
  config.after(:each) do
    add_description( example.metadata[:full_description] )
    log_example_exception( example, message ) if example.exception
  end
  
  config.after(:suite) do
    $logger.info "Number of records with potential errors: #{$flagged_messages.size}\n"    
    $logger.info "#{'*'*80}\nElements Tested For:\n"
    $test_descriptions.each{ |desc| $logger.info desc }
    $logger.info "*"*80 + "\n"    
    $flagged_messages.each_value{ |errs| errs.each{ |err_data| $logger.error err_data } }
  end
end

def get_patient_info( message )
  pid = message[:PID]

  str = <<-DONE
  #{'='*30} Patient Information #{'='*30}
  Name               : #{pid.patient_name.as_name}
  MRN                : #{pid.patient_id}
  Account Number     : #{pid.account_number}
  Date of Birth      : #{pid.dob.as_date}
  Encounter Date/Time: #{message[:OBR][:observation_date].as_datetime}
  #{'='*87}
  DONE
  
  str
end

def log_example_exception( example, message )
  exception_message = ""
  if example.exception.to_s[/Diff:/]
    exception_message = example.exception.to_s.split("Diff:")[0]
  else
    exception_message = example.exception.to_s
  end

  error_message = <<-END
    #{'*'*80}
    Error found in:\n#{example.metadata[:full_description]}
    Example Exception:\n#{cap_first( exception_message )}
    Pattern translation:\n#{cap_first( example.metadata[:pattern] )}
    #{'*'*87}
  END
  
  if $flagged_messages.has_key?( message[0] )
    $flagged_messages[message[0]] =
      $flagged_messages.fetch(message[0]) << error_message
  else
    patient_info = get_patient_info( message )
    $flagged_messages[message[0]] = [patient_info, error_message] 
  end
end

def add_description( description )
  $test_descriptions.add( description )
end