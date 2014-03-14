#!/bin/env ruby

$LOAD_PATH.unshift File.dirname __FILE__    # phase_1_testing directory
require 'test_runner_helper'

dt = Time.now.strftime "%H%M_%m-%d-%Y"      # HHMM_MM-DD-YYYY
ftp = $LOAD_PATH[0]  # testing  
# ftp = "d:/FTP"
LOG_DIR = "#{ftp}/logs"
LOG_FILE = "#{LOG_DIR}/#{dt}_testrunner.log"
RECS_FILE = "#{LOG_DIR}/#{dt}_results.txt"
RSPEC_LOG = "#{LOG_DIR}/#{dt}_rspec.log"

# create the directory, if needed
`mkdir "#{LOG_DIR}"` unless File.exists?( LOG_DIR )

test_file = "resources/manifest_lab_short_unix.txt"  # testing only
hl7_files = [test_file]  # testing only  
# hl7_files = Dir.entries( FTP ).select{ |f| File.file? "#{FTP}/#{f}" }

$logger = set_up_logger(LOG_FILE)
all_recs = get_records( hl7_files )
run_record_comparer( RECS_FILE, all_recs )
run_rspec( all_recs, RSPEC_LOG )
$logger.close