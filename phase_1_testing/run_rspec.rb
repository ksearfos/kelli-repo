#!/bin/env ruby

require "spec/spec_helper"
require 'logger'

def run_rspec( messages, file )
  $stdout.reopen(file, "w")   # send results of test to new file
  type = messages[0].type
  $test_descriptions = []
  $flagged_messages = {}

  $logger.info "Beginning testing of #{type} messages"
  messages.each{ |msg|
    $message = msg
    $logger.info "Beginning test of message: #{$message.id}\n"
 
    RSpec::Core::Runner.run [ "spec/#{type}_spec.rb" ]
  }  
  
  summarize
  
end

def summarize
  $logger.info "Number of records with potential errors: #{$flagged_messages.size}\n"    
  $logger.info "#{'*'*80}\nElements Tested For:\n"
  $test_descriptions.each{ |desc| $logger.info desc }
  $logger.info "*"*80 + "\n"    
  $flagged_messages.each_value{ |errs| errs.each{ |err_data| $logger.error err_data } }
end