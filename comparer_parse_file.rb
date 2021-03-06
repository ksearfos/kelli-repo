#!/bin/env ruby
# reek, excellent, flay
$LOAD_PATH.unshift File.dirname __FILE__    # phase_1_testing directory
require 'test_runner_helper'

dt = Time.now.strftime "%H%M_%m-%d-%Y"      # HHMM_MM-DD-YYYY
TESTING = true  # make some changes if this is being run for testing
TYPE = :enc
FTP = TESTING ? "C:/Users/Owner/Documents/script_input" : "d:/FTP"
FPATT = ( TESTING ? /^#{TYPE}_pre\./ : /^\w+_pre_\d+\.dat$/ )
LOG_DIR = "#{FTP}/logs"
PFX = LOG_DIR + "/#{dt}_"
LOG_FILE = PFX + "comparer_parse_testrunner.log"
MAX_RECS = 10000

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
  $logger.info "Found #{hl7_files.size} new file(s)\n"
  until hl7_files.empty?   # I am hoping that doing it this way will clear up memory as we go along
    fname = hl7_files.shift
    file = "#{FTP}/#{fname}"
    outfile = LOG_DIR + "/results_#{fname}"
    tmp = PFX + "temp_results"
    file_handler = nil    # reset
    
    file_handler = get_records( file, MAX_RECS )    
    if file_handler.nil?   # will be nil if file was empty
      remove_files( [file] )   # remove even if we are testing! it's empty!!
    else   
      begin
        $logger.info "Found #{file_handler.size} record(s)\n" 
        $logger.info "Comparing records..."    
        run_record_comparer( tmp, file_handler.records, false, false )
        file_handler.next     # get the next however-many records -- @records will be empty if we got them all
      end until file_handler.records.empty?

      tmp_file_handler = get_records( tmp )
      $logger.info "Found #{tmp_file_handler.size} record(s)\n" 
      $logger.info "Comparing records..."       
      run_record_comparer( outfile, tmp_file_handler.records, false, true )
      remove_files( [tmp] )  
      # remove_files( [file] ) unless TESTING
    end
  end  
end

$logger.info "Exiting..."
$logger.close