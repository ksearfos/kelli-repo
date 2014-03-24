#!/bin/env ruby

$LOAD_PATH.unshift File.dirname __FILE__    # phase_1_testing directory
require 'test_runner_helper'

dt = Time.now.strftime "%H%M_%m-%d-%Y"      # HHMM_MM-DD-YYYY
TESTING = true  # make some changes if this is being run for testing
TYPE = :lab
FTP = TESTING ? "C:/Users/Owner/Documents/script_input" : "d:/FTP"
FPATT = ( TESTING ? /^#{TYPE}_pre_\d/ : /^\w+_pre_\d+\.dat$/ )

LOG_DIR = TESTING ? "#{$LOAD_PATH[0]}/logs" : "#{FTP}/logs"
PFX = "#{LOG_DIR}/#{dt}_"
LOG_FILE = PFX + "comparer_parse_testrunner.log"

# create the directory, if needed
`mkdir "#{LOG_DIR}"` unless File.exists?( LOG_DIR )

# set up - create logger and read in records from files
$logger = set_up_logger( LOG_FILE )
$logger.info "Checking #{FTP} for files..."

# find files, store in hl7_files with full pathname
hl7_files = Dir.entries( FTP ).select{ |f| File.file?("#{FTP}/#{f}") && f =~ FPATT }

if hl7_files.empty?
  $logger.info "No new files found.\n"
else
  fname = hl7_files[0]
  file = FTP + "/" + fname
  outfile = LOG_DIR + "/results_#{fname}"
  tmp = PFX + "temp_results"
  summary = "Found #{hl7_files.size} new file(s)"
  
  $logger.info summary
  $logger.info "Reading the first file: #{file}\n"

  all_recs = get_records( file )
  $logger.info "Comparing records..."
      
  begin
    recs = all_recs.shift( 20000 )
    run_record_comparer( tmp, recs, false )
  end until all_recs.empty?
  remove_files( [file] ) unless TESTING
  
  all_recs = get_records( tmp )
  run_record_comparer( outfile, recs, false )
  remove_files( [tmp] )  
end

$logger.info "Exiting..."
$logger.close

`echo #{summary}`
