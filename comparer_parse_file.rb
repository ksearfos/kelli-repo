#!/bin/env ruby
# reek, excellent, flay
$LOAD_PATH.unshift File.dirname __FILE__    # phase_1_testing directory
require 'test_runner_helper'

dt = Time.now.strftime "%H%M_%m-%d-%Y"      # HHMM_MM-DD-YYYY
TESTING = false  # make some changes if this is being run for testing
TYPE = :lab
FTP = TESTING ? "C:/Users/Owner/Documents/script_input/" : "d:/FTP/"
FPATT = ( TESTING ? /^#{TYPE}_pre\./ : /^\w+_pre_\d+\.dat$/ )
LOG_DIR = TESTING ? "#{$LOAD_PATH[0]}/logs/" : "#{FTP}/logs/"
PFX = "#{LOG_DIR}/#{dt}_"
LOG_FILE = PFX + "comparer_parse_testrunner.log"
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
    outfile = LOG_DIR + "results_#{fname}"
    tmp = PFX + "temp_results"
  
    $logger.info "Reading #{file}"
    msg_hdlr = get_records( file, MAX_RECS )
    
    if msg_hdlr.nil?   # will be nil if file was empty files
      remove_files( [file] )   # remove even if we are testing! it's empty!!
    else   
      $logger.info "Found #{msg_hdlr.size} record(s)\n" 
      $logger.info "Comparing records..."
      begin    
        run_record_comparer( tmp, msg_hdlr.records, false )
        msg_hdlr.next     # get the next however-many records -- @records will be empty if we got them all
      end until msg_hdlr.records.empty?
  
      file_handler = get_records( tmp )
      run_record_comparer( outfile, file_handler.records, false )
      remove_files( [tmp] )  
      # remove_files( [file] ) unless TESTING
    end
  }  
end

$logger.info "Exiting..."
$logger.close