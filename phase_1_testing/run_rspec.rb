#!/bin/env ruby

require "spec/spec_helper"
require 'logger'
require 'FileUtils'

MAX = 1000    # max number of records to test at one time

def run_rspec( file, messages )
  $flagged_records = []

  i = 1
  begin
    recs = messages.pop( MAX )

    set_up_rspec( file + "_#{i}" )
    $logger.info "Checking batch #{i}...\n"
    # $errors = {}    #=> { error => 1 message to have this error } 
    
    recs.each{ |msg|
      $message = msg
      # $found_error = false
      $errors = []
      RSpec::Core::Runner.run [ "spec/#{$message.type}_spec.rb" ]
      # print_record(msg) if $found_error
      
      summarize
    }
    
    # FileUtils.rm( file + "_#{i-1}" ) if i > 1 #truncate( file + "_#{i-1}", 0 )
    i += 1
  end until messages.empty?
  
  # $errors.each{ |err_txt,msg_summ| 
    # $logger.error "#{err_txt}\n\n#{msg_summ}\n"
  # }
end

def set_up_rspec( file )
  # $stdout.reopen(file, "w")   # send results of test to new file
  $logger.info "Beginning testing of messages\n"
end

def print_record( message )
    puts "\n#{"="*30}RECORD#{"="*30}\n"
    $message.view_segments
    puts "#{"="*66}\n"
end

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