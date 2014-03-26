#!/bin/env ruby

$LOAD_PATH.unshift File.dirname __FILE__    # phase_1_testing directory
require 'test_runner_helper'

# command-line argument assignment
case ARGV[0]
when '-d'   # non-delete mode
  DELETE = false
  run = true
when '-t'   # test mode
  DELETE = false
  run = false
when '-r'   # full run
  DELETE = true
  run = true
when '--rspec'
  DELETE = true
  run = :rspec
when '--rspec-test'
  DELETE = false
  run = :rspec
when '--comparer'
  DELETE = true
  run = :comparer
when '--comparer-test'
  DELETE = false
  run = :comparer
when '--help'
  puts "test_runner_record_comparer.rb takes one commandline argument:"
  puts "   -r: [r]un full script (runs rspec and comparer, and deletes processed files)"
  puts "   -d: run in non-[d]elete mode (runs full script but does not delete files)"
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
MAX_RECS = 10
TESTING = true  # make some changes if this is being run for testing
TYPE = :enc
FTP = TESTING ? "C:/Users/Owner/Documents/script_input" : "d:/FTP"

if TESTING
  case run
  when :comparer then FPATT = /^#{TYPE}_pre/ #_\d/
  when :rspec then FPATT = /^#{TYPE}_post/
  else FPATT = /^#{TYPE}_[a-z]+/
  end
else
  case run
  when :comparer then FPATT = /^\w+_pre_\d+\.dat$/
  when :rspec then FPATT = /^\w+_post_\d+\.dat$/
  else FPATT = /^\w+_[a-z]+_\d+\.dat$/
  end
end

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
file_subset = hl7_files[0...MAX_RECS]
file_subset.map!{ |f| "#{FTP}/#{f}" }

if file_subset
  $logger.info "Found #{hl7_files.size} new file(s)\n"
else   # no subset
  $logger.info "No new files found.\n"
  run = false  
end

if run
  $logger.info "Using the first #{MAX_RECS}:\n  " + file_subset.join("\n  ") + "\n"

  unless !run || run == :rspec   
    tmp = PFX + "temp_results"
      
    # first time: reads each file, finds best records, saves all chosen records to temp file
    file_subset.each{ |f|  
      all_recs = get_records( f )
      
      begin
        recs = all_recs.shift( 20000 )
        run_record_comparer( tmp, recs, false )
      end until all_recs.empty?
    }
    remove_files( file_subset ) if DELETE
    
    # now: read tmp to get all chosen records, compare those to eliminate duplication, save results to csv
    all_recs = get_records( tmp )
    run_record_comparer( PFX + "records.csv", all_recs, true )
    remove_files( [tmp] ) if DELETE
  end
  
  unless !run || run == :comparer
    ct = 1
    file_subset.each{ |f|
      m = f.match( /\d+/ )    # date/time from this file
      fdt = m ? m[0] : dt
      pfx = "#{$LOG_DIR}/#{fdt}_"
      
      all_recs = get_records( f )
      run_rspec( pfx + "rspec.log", pfx + "flagged_recs.csv", all_recs )
      ct += 1
    }
    remove_files( file_subset ) if DELETE
  end
end

$logger.info "Exiting..."
$logger.close