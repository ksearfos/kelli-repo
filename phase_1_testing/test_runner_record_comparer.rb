#!/bin/env ruby

$LOAD_PATH.unshift File.dirname __FILE__    # phase_1_testing directory
require 'test_runner_helper'

# command-line argument assignment
case ARGV[0]
when '-d'   # non-delete mode
  DELETE = false
  RUN = true
when '-t'   # test mode
  DELETE = false
  RUN = false 
when '-r'   # full run
  DELETE = true
  RUN = true
when '--help'
  puts "test_runner_record_comparer.rb takes one optional commandline argument:"
  puts "   -r: [r]un full script (deletes processed files)"
  puts "   -d: run in non-[d]elete mode (runs full script but doed not delete files)"
  puts "   -t: run in [t]est mode (basic output only, does not delete files)"
  exit 0
else
  raise "Unrecognized argument '#{ARGV[0]}' in test_runner.rb"
  exit 1
end

dt = Time.now.strftime "%H%M_%m-%d-%Y"      # HHMM_MM-DD-YYYY
TESTING = true  # make some changes if this is being run for testing
FTP = TESTING ? "C:/Users/Owner/Documents" : "d:/FTP"
FPATT = TESTING ? /[a-z]{3}_pre\.dat/ : /^\w+_pre_\d+\.dat$/
$LOG_DIR = TESTING ? "#{$LOAD_PATH[0]}/logs" : "#{FTP}/logs"
LOG_FILE = "#{$LOG_DIR}/#{dt}_testrunner.log"

# create the directory, if needed
`mkdir "#{$LOG_DIR}"` unless File.exists?( $LOG_DIR )

# set up - create logger and read in records from files
$logger = set_up_logger( LOG_FILE )
$logger.info "Checking #{FTP} for files..."

# find files, store in hl7_files with full pathname
hl7_files = Dir.entries( FTP ).select{ |f| File.file?("#{FTP}/#{f}") && f =~ FPATT }
hl7_files.map!{ |f| "#{FTP}/#{f}" }

# now turn those files into parsable hl7 messages
all_recs = get_records( hl7_files )

RUN &&= !all_recs.empty?     # avoid running setup for record comparer if there are no records to compare
if RUN
  recs = run_record_comparer( "#{$LOG_DIR}/#{dt}_results.txt", all_recs )
  make_csv( recs, "#{$LOG_DIR}/#{dt}_records.csv" )
  remove_files( hl7_files ) if DELETE
end

$logger.info "Exiting..."
$logger.close