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
when '--rspec'
  DELETE = true
  RUN = :rspec
when '--rspec-test'
  DELETE = false
  RUN = :rspec
when '--comparer'
  DELETE = true
  RUN = :comparer
when '--comparer-test'
  DELETE = false
  RUN = :comparer
when '--help'
  puts "test_runner_record_comparer.rb takes one commandline argument:"
  puts "   -r: [r]un full script (runs rspec and comparer, and deletes processed files)"
  puts "   -d: run in non-[d]elete mode (runs full script but doed not delete files)"
  puts "   -t: run in [t]est mode (basic output only, does not delete files)"
  puts "--rspec: run in rspec mode (basic output and rspec results, deletes files)"
  puts "--comparer: run in comparer mode (basic output and comparer results, deletes files)"
  puts "--rspec-test: run rspec in test mode (basic output and rspec results, but does not delete files)"
  puts "--comparer-test: run comparer in test mode (basic output and comparer results, does not delete files)"
  exit 0
else
  raise "Unrecognized argument '#{ARGV[0]}' in test_runner.rb"
  exit 1
end

dt = Time.now.strftime "%H%M_%m-%d-%Y"      # HHMM_MM-DD-YYYY
TESTING = true  # make some changes if this is being run for testing
TYPE = :rad
FTP = TESTING ? "C:/Users/Owner/Documents/script_input" : "d:/FTP"
FPATT = TESTING ? /#{TYPE}_pre/ : /^\w+_pre_\d+\.dat$/
$LOG_DIR = TESTING ? "#{$LOAD_PATH[0]}/logs" : "#{FTP}/logs"
PFX = "#{$LOG_DIR}/#{dt}_"
LOG_FILE = PFX + "testrunner.log"

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
   
unless !RUN || all_recs.empty?   # avoid running setup if we won't be running anything else
  run_record_comparer( PFX + "records.csv", all_recs ) unless RUN == :rspec
  run_rspec( PFX + "rspec.log", PFX + "flagged_recs.csv", all_recs ) unless RUN == :comparer
  remove_files( hl7_files ) if DELETE
end

$logger.info "Exiting..."
$logger.close