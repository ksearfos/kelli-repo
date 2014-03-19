require 'lib/hl7module/HL7'
require 'rspec'
require 'rspec/expectations'

def pass?( messages, logic )
  failed = []
  messages.each{ |msg| failed << msg unless logic.call(msg) }
  failed
end

def log_example( example )
  $logger.info example_summary( example )
end

def example_summary( example )
  patt = example.metadata[:pattern]
  message = "#{example.metadata[:full_description]}"
  message << " (" + patt + ")" if patt
  message  
end  

def log_result( ary, example )
  if ary.empty?
    $logger.info "Passed for all records.\n"
  else
    filename = example.metadata[:description].gsub(" ", "_") + ".log"
    file = "#{$LOG_DIR}/#{filename}"
    File.open( file, "w" ) do |f|
      f.puts example_summary( example )
      ary.each{ |rec| f.puts patient_details( rec ) + "\n" }
    end

    $logger.error "Failed for #{ary.size} records. See #{file}.\n"
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

  str << "  Procedure: #{det[:PROC_NAME]} on #{det[:PROC_DATE]}\n" if message.type != :adt  
  str
end