#!/bin/env ruby

require "spec/spec_helper"
require 'logger'

def run_rspec( message )
  $message = message
  introduce_record
  RSpec::Core::Runner.run [ "spec/#{$message.type}_spec.rb" ]  
end

def set_up_rspec( file )
  $stdout.reopen(file, "w")   # send results of test to new file
  $logger.info "Beginning testing of messages\n"
end

def introduce_record
    puts "\n#{"="*30}RECORD#{"="*30}\n"
    $message.view_segments
    puts "#{"="*66}\n"
end

def summarize
  $logger.info "Number of records with potential errors: #{$flagged_messages.size}\n"    

  $flagged_messages.each{ |msg,errs| 
    div = '*' * 60
    sz = errs.size
    err_text = "#{sz} errors found for record\n\n#{msg}\n"
    for i in (1..sz)
      err_text << "Error #{i}: ".rjust(10) << errs[i-1] << "\n\n" 
    end
    $logger.error err_text
  }
end