#!/bin/env ruby

require "spec/spec_helper"
require 'logger'

def run_rspec( messages, file )
  $stdout.reopen(file, "w")   # send results of test to new file
  type = messages[0].type
  
  $logger.info "Beginning testing of #{type} messages"
  messages.each{ |msg|
    $message = msg
    RSpec::Core::Runner.run [ "spec/#{type}_spec.rb" ]
  }
  
end