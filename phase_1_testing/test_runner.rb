#!/bin/env ruby

$LOAD_PATH.unshift File.dirname __FILE__    # phase_1_testing directory
ADT_TEST = "spec/hl7_specs/adt/adt_hl7_spec.rb"
LAB_TEST = "spec/hl7_specs/lab/lab_hl7_spec.rb"
RAD_TEST = "spec/hl7_specs/rad/rad_hl7_spec.rb"

require "record_comparer/RecordComparer.rb"
require "lib/hl7module/HL7.rb"
require ADT_TEST
require LAB_TEST
require RAD_TEST
require 'logger'

FTP = "d:/FTP"
LOG_DIR = "#{FTP}/logs"

dt = Time.now.strftime "%b%d_%H%M"                        # MmmDD_HHMM

LOG_FILE = "#{LOG_DIR}/logfile_#{dt}.log"
RECS_FILE = "#{LOG_DIR}/records_chosen_#{dt}.txt"

# set up and prettify the logger
logger = Logger.new LOG_FILE
logger.datetime_format = "%H:%M:%S"   # HH:MM:SS
logger.formatter = Proc.new{ |severity,datetime,prog,msg|
  "#{datetime} #{severity}:\n" +   # HH:MM:SS SEVERITY:
  "  #{msg}" +                     #   stuff happened
  "  while running #{prog}" }      #   while running prog
  
files = Dir.entries( FTP ).select{ |f| File.file? "#{FTP_DIR}/#{f}" }

if files.empty?
  logger.info "No new files found in #{FTP}."
  logger.info "Exiting."  
  exit 0
end

logger.info "Found #{files.size} new files:\n  " + files.join("\n  ")

hdlers = files.map{ |f| HL7Test::MessageHandler.new(f) }
all_recs = []
hdlers.each{ |mh| all_recs << mh.recs }
do comparison:
find_records(mhs)
save results
send summary in email
do test:
test(mhs)
save results
send summary in email
send email