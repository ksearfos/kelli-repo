#!/bin/env ruby

require "spec/spec_helper"
require 'logger'

def run_rspec( log_file, csv_file, messages )
  type = messages[0].type
  set_up_rspec( log_file, type )
  $messages = messages
  $flagged = {}
  RSpec::Core::Runner.run [ "spec/#{type}_spec.rb" ]
  
  # now $flagged should be a list of messages and each example they failed
  csv_ary = organize_results( $flagged, type )
  csv_ary.sort_by!{ |mrn,name,dob,acct,proc_visit| [name, acct, proc_visit] }
  
  # log completion in the logger 
  CSV.make_spreadsheet_from_array( csv_file, csv_ary )
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

  pt_headers = headers(type)
  fields = details_wanted(type)
  err_headers = all_errs.map{ |e| e.upcase }
  ary = [ pt_headers + err_headers ]
  flagged.each{ |msg,errs|
    msg_ary = msg.get_details( fields )
    all_errs.each{ |err|
      msg_ary << errs.include?(err)   # should be a series of [true,false,false,true,true,...]
    }
    ary << msg_ary
  } 
  
  ary 
end

def details_wanted(type)
  d = [:PT_ID,:PT_NAME,:DOB,:PT_ACCT]
  d += ( type == :adt ? [:VISIT_DATE] : [:PROC_NAME,:PROC_DATE] )
  d
end

def headers(type)
  hdr = [ "MRN", "PATIENT NAME", "DOB" ]
  hdr += ( type == :adt ? [ "VISIT #", "VISIT DATE/TIME" ] : [ "ACCOUNT #", "PROCEDURE NAME", "DATE/TIME" ] ) 
  hdr
end