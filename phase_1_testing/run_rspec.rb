#!/bin/env ruby

require "spec/spec_helper"
require 'logger'

MAX = 1000    # max number of records to test at one time

def run_rspec( file, messages )
  i = 0
  begin
    recs = messages.shift( MAX )
    i += 1
    set_up_rspec( file + "_#{i}.log" )
    $logger.info "Batch #{i}"
    
    recs.each{ |msg|
      $message = msg
      $errors = []
      
      # run tests (for this message)
      RSpec::Core::Runner.run [ "spec/#{$message.type}_spec.rb" ]
      
      # output record and error details to rspec log and testrunner log  
      print_record(msg) unless $errors.empty?
      summarize
    }

  end until messages.empty?  
end

def set_up_rspec( file )
  $stdout.reopen(file, "w")   # send results of test to new file
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