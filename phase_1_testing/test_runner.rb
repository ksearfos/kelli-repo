#!/bin/env ruby

$LOAD_PATH.unshift File.dirname __FILE__    # phase_1_testing directory
require 'test_runner_helper'

dt = Time.now.strftime "%H%M_%m-%d-%Y"      # HHMM_MM-DD-YYYY
ftp = $LOAD_PATH[0]  # testing  
# ftp = "d:/FTP"
LOG_DIR = "#{ftp}/logs"
LOG_FILE = "#{LOG_DIR}/#{dt}_logfile.log"
RECS_FILE = "#{LOG_DIR}/#{dt}_results.txt"

# create the directory, if needed
`mkdir "#{LOG_DIR}"` unless File.exists?( LOG_DIR )

set_up_logger( LOG_FILE )
get_records
# run_record_comparer( RECS_FILE )
run_rspec

$logger.close