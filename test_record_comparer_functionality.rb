#!/bin/env ruby
# reek, excellent, flay
$LOAD_PATH.unshift File.dirname __FILE__    # phase_1_testing directory
require 'test_runner_helper'

dt = Time.now.strftime "%H%M_%m-%d-%Y"      # HHMM_MM-DD-YYYY
TYPE = :rad
DIR = "C:/Users/Owner/Documents/script_input/"
FPATT = /^#{TYPE}_pre_testing/
LOG_DIR = "#{DIR}/logs/"
PFX = "#{LOG_DIR}/#{dt}_"
LOG_FILE = PFX + "comparer_parse_testrunner.log"
MAX_RECS = 10000

# create the directory, if needed
`mkdir "#{LOG_DIR}"` unless File.exists?( LOG_DIR )

# set up - create logger and read in records from files
orig_stdout = $stdout.clone
orig_stderr = $stderr.clone
$logger = set_up_logger( LOG_FILE )
$logger.info "Checking #{DIR} for files..."
$stdout.reopen( orig_stdout )
$stderr.reopen( orig_stderr )

# find files, store in hl7_files with full pathname
hl7_files = Dir.entries(DIR).select{ |f| File.file?(DIR+f) && f =~ FPATT }

if hl7_files.empty?
  $logger.info "No new files found.\n"
else
  $logger.info "Found #{hl7_files.size} new file(s)\n"
  hl7_files.each{ |fname|
    file = DIR + fname
    outfile = LOG_DIR + "results_#{fname}"
    tmp = PFX + "temp_results"
  
    $logger.info "Reading #{file}"
    msg_hdlr = get_records( file, MAX_RECS )
    
    if msg_hdlr.nil?   # will be nil if file was empty
      remove_files( [file] )   # remove even if we are testing! it's empty!!
    else    
      $logger.info "Comparing records..."
      begin    
        run_record_comparer( tmp, msg_hdlr.records, true )
        msg_hdlr.next     # get the next however-many records -- @records will be empty if we got them all
      end until msg_hdlr.records.empty?
    end
  }
end