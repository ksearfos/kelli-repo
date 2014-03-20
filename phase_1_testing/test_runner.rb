#!/bin/env ruby

$LOAD_PATH.unshift File.dirname __FILE__    # phase_1_testing directory
require 'test_runner_helper'

# command-line argument assignment
case ARGV[0]
when '-c'
  RUN_RCOMP = true
  RUN_RSPEC = false
when '-s'
  RUN_RSPEC = true
  RUN_RCOMP = false
when '-r'
  RUN_RSPEC = true
  RUN_RCOMP = true
when '-t'
  RUN_RSPEC = false
  RUN_RCOMP = false  
when '--help'
  puts "test_runner.rb requires one commandline argument:"
  puts "   -c: run record [c]omparer only"
  puts "   -s: run r[s]pec only"
  puts "   -r: run both"
  puts "   -t: run in [t]est mode (basic output only)"
  exit 0
else
  raise "Unrecognized argument '#{ARGV[0]}' in test_runner.rb"
  exit 1
end

dt = Time.now.strftime "%H%M_%m-%d-%Y"      # HHMM_MM-DD-YYYY
ftp = $LOAD_PATH[0]  # testing  
# ftp = "d:/FTP"
$LOG_DIR = "#{ftp}/logs"
LOG_FILE = "#{$LOG_DIR}/#{dt}_testrunner.log"

# create the directory, if needed
`mkdir "#{$LOG_DIR}"` unless File.exists?( $LOG_DIR )

lab_file = "C:/Users/Owner/Documents/manifest_lab_out.txt"  # testing only
rad_file = "C:/Users/Owner/Documents/manifest_rad_out.txt"  # testing only
enc_file = "C:/Users/Owner/Documents/enc_post.dat"  # testing only
bad_file = "C:/Users/Owner/Documents/dinosaur.txt"  # testing only
hl7_files = [ rad_file ]  # testing only  
# hl7_files = Dir.entries( FTP ).select{ |f| File.file? "#{FTP}/#{f}" }

# set up - create logger and read in records from files
$logger = set_up_logger(LOG_FILE)
all_recs = get_records( hl7_files )

unless all_recs.empty?   # if there are no records, don't want useless and confusing logger output
  run_record_comparer( "#{$LOG_DIR}/#{dt}_results.txt", all_recs ) if RUN_RCOMP
  run_rspec( "#{$LOG_DIR}/#{dt}_rspec.log", all_recs ) if RUN_RSPEC
end

$logger.info "Exiting..."
$logger.close