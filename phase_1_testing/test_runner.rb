#!/bin/env ruby

$LOAD_PATH.unshift File.dirname __FILE__    # phase_1_testing directory
require "Record_Comparer/RecordComparer.rb"
require "Record_Comparer/OHProcs.rb"
require "lib/hl7module/HL7.rb"
require 'logger'

DT = Time.now.strftime "%H%M_%m-%d-%Y"      # HHMM_MM-DD-YYYY

# testing only
FTP = $LOAD_PATH[0]  #"d:/FTP"
LOG_DIR = "#{FTP}/logs"
LOG_FILE = #{LOG_DIR}/#{DT}_logfile.log"
RECS_FILE = "#{LOG_DIR}/#{DT}_records_to_use.txt"
MAX = 1000

# create the directories, or it will complain
unless File.exists?( LOG_DIR )
  `mkdir "#{LOG_DIR}"`
end

# testing only
FILE = "resources/manifest_lab_short_unix.txt"
#####

# set up and prettify the $logger
$stdout.reopen(LOG_FILE, "w")
$logger = Logger.new LOG_FILE
$logger.datetime_format = "%H:%M:%S"   # HH:MM:SS
$logger.formatter = Proc.new{ |severity,datetime,msg,prog|
  "\n#{datetime} #{severity}:\n" +   # HH:MM:SS SEVERITY:
  "  #{msg}\n" +                     #   stuff happened
  "  Found while running #{prog}" }  #   Found while running prog

# testing only  
files = [FILE] #Dir.entries( FTP ).select{ |f| File.file? "#{FTP}/#{f}" }

if files.empty?
  $logger.info "No new files found in #{FTP}."
  $logger.info "Exiting."  
  exit 0
end

$logger.info "Found #{files.size} new files:\n  " + files.join("\n  ")

hdlers = files.map{ |f| HL7Test::MessageHandler.new(f) }
all_recs = []
hdlers.each{ |mh| all_recs << mh.records }
all_recs.flatten!(1)    # only flatten first layer -- otherwise it will flatten the messages, segments, and fields!!!
type = all_recs[0].type
rspec = "spec/hl7_specs/#{type}_spec.rb"

# find records
$logger.prog = "RecordComparer"
comparer = RecordComparer.new(all_recs,type)
comparer.analyze
$logger.info comparer.summary
$logger.warn "The unmatched criteria are:\n#{comparer.unmatched}" 
File.open( RECS_FILE, "w" ) { |f| f.puts comparer.used_records }
$logger.info "Complete list of records can be found in #{RECS_FILE}."
$logger.close
exit 0
# begin testing
begin
  test_set = files.pop( MAX )
  rspec = Object.co|nst_get("#{type.upcase}_FILE")
  test_set.each{ |f| exec "#{f} rspec #{rspec}" } 
end until files.empty?

$logger.info "Rspec testing completed. Results can be viewed in #{rspec_file}."
$logger.close