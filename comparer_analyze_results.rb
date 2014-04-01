#!/bin/env ruby

$LOAD_PATH.unshift File.dirname __FILE__    # phase_1_testing directory
require 'test_runner_helper'

dt = Time.now.strftime "%H%M_%m-%d-%Y"      # HHMM_MM-DD-YYYY
TESTING = true  # make some changes if this is being run for testing
SET_SIZE = 1024
FTP = "D:/FTP"
LOG_DIR = TESTING ? "#{$LOAD_PATH[0]}/logs" : "#{FTP}/logs"
PFX = "#{LOG_DIR}/#{dt}_"
LOG_FILE = PFX + "comparer_analyze_testrunner.log"

# set up - create logger and read in records from files
$logger = set_up_logger( LOG_FILE )
$logger.info "Checking #{LOG_DIR} for result files..."

# find files, store in hl7_files with full pathname
hl7_files = Dir.entries( LOG_DIR ).select{ |f| File.file?("#{LOG_DIR}/#{f}") && f =~ /^results_/ }

if hl7_files.empty?
  $logger.error "No results files found in #{LOG_DIR.chomp('/')}\n"
else
  hl7_files.map!{ |f| "#{LOG_DIR}/#{f}" } 
  tmp = PFX + "temp_results"   
  $logger.info "Found #{hl7_files.size} result file(s)\n"

  begin
    batch = hl7_files.shift(10)
    all_recs = []
    batch.each{ |f| all_recs += get_records(f).records }
    run_record_comparer( tmp, all_recs, false, false )
    # remove_files( batch ) unless TESTING
  end until hl7_files.empty?
    
  # now: read tmp to get all chosen records, compare those to eliminate duplication, save results to csv  
  msg_hdlr = get_records( tmp )
  $logger.info "Comparing #{msg_hdlr.records.size} records"
  run_record_comparer( PFX + "records.csv", msg_hdlr.records, true, true, SET_SIZE )
  remove_files( [tmp] )
end

$logger.info "Exiting..."
$logger.close