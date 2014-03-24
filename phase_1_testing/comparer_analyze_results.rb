#!/bin/env ruby

$LOAD_PATH.unshift File.dirname __FILE__    # phase_1_testing directory
require 'test_runner_helper'

dt = Time.now.strftime "%H%M_%m-%d-%Y"      # HHMM_MM-DD-YYYY
TESTING = true  # make some changes if this is being run for testing

LOG_DIR = TESTING ? "#{$LOAD_PATH[0]}/logs" : "#{FTP}/logs"
PFX = "#{LOG_DIR}/#{dt}_"
LOG_FILE = PFX + "comparer_analyze_testrunner.log"

# set up - create logger and read in records from files
$logger = set_up_logger( LOG_FILE )
$logger.info "Checking #{LOG_DIR} for result files..."

# find files, store in hl7_files with full pathname
hl7_files = Dir.entries( LOG_DIR ).select{ |f| File.file?("#{LOG_DIR}/#{f}") && f =~ /^results_/ }

if hl7_files.empty?
  $logger.error "No results files found in #{LOG_DIR}\n"
else
  hl7_files.map!{ |f| "#{LOG_DIR}/#{f}" } 
  # tmp = PFX + "temp_results"   
  $logger.info "Found #{hl7_files.size} result file(s)\n"

  all_recs = []
  hl7_files.each{ |f| all_recs += get_records( f ) }
  remove_files( hl7_files ) unless TESTING
    
  # now: read tmp to get all chosen records, compare those to eliminate duplication, save results to csv
  $logger.info "Comparing #{all_recs.size} records"  
  run_record_comparer( PFX + "records.csv", all_recs, true )
  # remove_files( [tmp] ) if DELETE
end

$logger.info "Exiting..."
$logger.close