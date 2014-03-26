#!/bin/env ruby

$LOAD_PATH.unshift File.dirname __FILE__    # phase_1_testing directory
require 'test_runner_helper'

dt = Time.now.strftime "%H%M_%m-%d-%Y"      # HHMM_MM-DD-YYYY
TESTING = true  # make some changes if this is being run for testing
TYPE = :enc
FTP = TESTING ? "C:/Users/Owner/Documents/script_input/" : "d:/FTP/"
FPATT = ( TESTING ? /^#{TYPE}_post\./ : /^\w+_post_\d+\.dat$/ )
LOG_DIR = TESTING ? "#{$LOAD_PATH[0]}/logs/" : "#{FTP}/logs/"
PFX = "#{LOG_DIR}/#{dt}_"
LOG_FILE = PFX + "rspec_testrunner.log"
MAX_RECS = 10000

# create the directory, if needed
`mkdir "#{LOG_DIR}"` unless File.exists?( LOG_DIR )

# set up - create logger and read in records from files
$logger = set_up_logger( LOG_FILE )
$logger.info "Checking #{FTP} for files..."

# find files, store in hl7_files with full pathname
hl7_files = Dir.entries( FTP ).select{ |f| File.file?(FTP+f) && f =~ FPATT }

if hl7_files.empty?
  $logger.info "No new files found.\n"
else
  $logger.info "Found #{hl7_files.size} new file(s)\n"
  hl7_files.each{ |fname|
    file = FTP + fname
    match = fname[/\d+/]    # date/time from the file
    file_dt = ( match ? match[0] : dt )
    new_file_pfx = "#{LOG_DIR}/#{file_dt}_"     
    $flagged = {}  # used by rspec to track failed examples
    
    $logger.info "Reading #{file}"
    msg_hdlr = get_records( file, MAX_RECS )    
    if msg_hdlr.nil?   # will be nil if file was empty
      remove_files( [file] )   # remove even if we are testing! it's empty!!
    else    
      $logger.info "Testing records..."
      ct = 1      
      until msg_hdlr.records.empty?
        run_rspec( new_file_pfx + "rspec_#{ct}.log", msg_hdlr.records, TYPE ) 
        msg_hdlr.next     # get the next however-many records -- @records will be empty if we got them all
        ct += 1
      end   
    
      save_flagged( new_file_pfx + "flagged_recs.csv", TYPE ) unless $flagged.empty?
      remove_files( [file] ) unless TESTING
    end 
  }  
end

$logger.info "Exiting..."
$logger.close