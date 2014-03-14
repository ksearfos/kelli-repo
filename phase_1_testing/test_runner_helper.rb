#!/bin/env ruby

require "Record_Comparer/RecordComparer.rb"
require "Record_Comparer/OHProcs.rb"
require "lib/hl7module/HL7.rb"
require 'rspec'
require 'logger'

$all_recs = []
$type = nil

# set up and prettify the $logger
def set_up_logger( file )
  $stdout.reopen(file, "w")
  $logger = Logger.new file
  $logger.datetime_format = "%H:%M:%S.%L"   # HH:MM:SS
  $logger.formatter = Proc.new{ |severity,datetime,prog,msg|
    str = "#{datetime} #{severity}"
    str << "(#{prog})" if prog
    str << ":\n"
    str << " #{msg}\n\n"
    str
  }
end

def get_records
  # testing only
  test_file = "resources/manifest_lab_short_unix.txt"
  
  files = [test_file]  # testing only  
  # files = Dir.entries( FTP ).select{ |f| File.file? "#{FTP}/#{f}" }

  if files.empty?
    $logger.info "No new files found in #{FTP}."
    $logger.info "Exiting."  
    exit 0
  else
    $logger.info "Found #{files.size} new files:\n  " + files.join("\n  ")
  end
  
  # now break into records - sets all_recs
  hdlers = files.map{ |f| HL7Test::MessageHandler.new(f) }
  hdlers.each{ |mh| $all_recs << mh.records }
  $all_recs.flatten!(1) unless $all_recs.first.is_a? HL7Test::Message  # only flatten Arrays, not Messages/Segments etc.
  $type = $all_recs[0].type
  $logger.info "Found #{$all_recs.size} #{$type} messages to test."
end

def run_record_comparer( results_file )
  comparer = RecordComparer.new($all_recs,$type)
  comparer.analyze

  # the following goes into results_file
  File.open( results_file, "w" ) { |f|
    f.puts "==========MATCHED=========="
    f.puts comparer.matched
    f.puts ""
    f.puts "==========UNMATCHED=========="
    f.puts comparer.unmatched
    f.puts ""
    f.puts "==========RECORDS=========="
    f.puts comparer.used_records
  }

  # log completing in the logger
  $logger.info comparer.summary
  $logger.info "Record search completed.\n Results can be viewed in #{results_file}."
end

def run_rspec
  $all_recs.each{ |msg|
    $message = msg
    RSpec::Core::Runner.run [ "spec/#{$type}_spec.rb" ] }
  $logger.info "Rspec testing completed."
end