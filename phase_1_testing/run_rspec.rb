#!/bin/env ruby

require "spec/spec_helper"
require 'logger'

def run_rspec( file, messages )
  set_up_rspec( file )
  $messages = messages
  RSpec::Core::Runner.run [ "spec/test_spec.rb" ]
  # RSpec::Core::Runner.run [ "spec/#{$messages[0].type}_spec.rb" ]
end

def set_up_rspec( file )
  $stdout.reopen(file, "w")   # send results of test to new file
  $logger.info "Beginning testing of messages\n"
end

# def print_record( message )
    # puts "\n#{"="*30}RECORD#{"="*30}\n"
    # $message.view_segments
    # puts "#{"="*66}\n"
# end

def summarize
  sz = $errors.size

  err_text = "#{sz} errors found for record\n\n#{patient_details($message)}\n"
  for i in (1..sz)
    err_text << "Error #{i}: ".rjust(10) << $errors[i-1] << "\n\n" 
  end
  
  $logger.error err_text
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