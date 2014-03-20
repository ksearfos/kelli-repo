require 'lib/hl7module/HL7'
require 'rspec'
require 'rspec/expectations'

RSpec.configure do |config|
  config.before(:suite) do
    # stuff
  end
  
  config.after(:suite) do
    # stuff
  end  
end
  
def pass?( messages, logic )
  failed = []
  messages.each{ |msg| failed << msg unless logic.call(msg) }
  failed
end

def pass_for_each?( messages, logic, segment )
  p = Proc.new{ |msg|
    ok = true
    msg[segment].each{ |seg| ok &&= logic.call(seg) }        
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
    filename = example.metadata[:description].gsub(" ", "_")
    # file = "#{$LOG_DIR}/#{ary[0].type}_#{filename}.log"
    # File.open( file, "w" ) do |f|
      # f.puts "#{example_summary(example)}\n\n"
      # ary.each{ |rec| f.puts patient_details( rec ) + "\n" }
    # end

    $logger.error "!! Failed for #{ary.size} records !!\n".upcase
    
    ex = example.metadata[:full_description]
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

def patient_details( message )
  det = message.details
  str = <<END
Message Date: #{message.header.field(:date_time).as_datetime}
Patient: #{det[:PT_ID]} - #{det[:PT_NAME]}
Account: #{det[:PT_ACCT]}
Date of Birth: #{det[:DOB]}      
END

  str << "Procedure: #{det[:PROC_NAME]} on #{det[:PROC_DATE]}\n" if message.type != :adt  
  str
end