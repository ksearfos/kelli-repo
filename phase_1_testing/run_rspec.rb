#!/bin/env ruby

require "spec/spec_helper"
require 'logger'
require 'lib/HL7CSV'

def run_rspec( log_file, messages, type )
  set_up_rspec( log_file, type )
  $messages = messages
  $flagged = {}
  RSpec::Core::Runner.run [ "spec/#{type}_spec.rb" ]
end

# $flagged should be a list of messages and each example they failed
def save_flagged( csv_file, type )
  csv_ary = organize_results( $flagged, type )
  HL7CSV.make_spreadsheet_from_array( csv_file, csv_ary )
  $logger.info "Testing completed. See #{csv_file}\n"
end

def set_up_rspec( file, type )
  $stdout.reopen(file, "w")   # send results of test to new file
  $logger.info "Beginning testing of #{type} messages\n"
end

def organize_results( flagged, type )
  all_errs = flagged.values
  all_errs.flatten!
  all_errs.uniq!
  type = flagged.keys.first.type
  
  err_headers = all_errs.map{ |e| e.upcase }
  ary = [ HL7CSV.get_header(type) + err_headers ]
  flagged.each{ |msg,errs|
    msg_ary = msg.to_row
    all_errs.each{ |err|
      msg_ary << ( errs.include?(err) ? "FAILED" : "PASSED" )
    }
    ary << msg_ary
  } 
  
  ary 
end