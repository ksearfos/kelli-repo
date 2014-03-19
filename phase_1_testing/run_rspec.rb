#!/bin/env ruby

require "spec/spec_helper"
require 'logger'

def run_rspec( file, messages )
  set_up_rspec( file )
  $messages = messages
  RSpec::Core::Runner.run [ "spec/#{$messages[0].type}_spec.rb" ]
end

def set_up_rspec( file )
  $stdout.reopen(file, "w")   # send results of test to new file
  $logger.info "Beginning testing of messages\n"
end