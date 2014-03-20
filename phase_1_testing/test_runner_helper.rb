#!/bin/env ruby

require 'run_rspec'
require 'run_record_comparer'

# set up and prettify the $logger
def set_up_logger( file )
  $stdout.reopen(file, "w")
  $stderr.reopen(file, "w")
  logger = Logger.new file
  
  logger.datetime_format = "%H:%M:%S.%L"   # HH:MM:SS
  logger.formatter = Proc.new{ |severity,datetime,prog,msg|
    str = "#{datetime} #{severity}: #{msg}\n"
    str
  }
  
  logger
end

def get_records( files )
  if files.empty?
    $logger.info "No new files found.\n"
    return []
  else
    $logger.info "Found #{files.size} new file(s):\n  " + files.join("\n  ") + "\n"
  end
  
  # now break into records - sets all_recs
  $logger.info "Beginning file input..."
  msg_list = []
  files.each{ |f| 
    $logger.info "Opening #{f}"
    mh = HL7Test::MessageHandler.new(f)
    msg_list << mh.records
  }
  
  msg_list.flatten!(1) unless msg_list.first.is_a? HL7Test::Message  # only flatten Arrays, not Messages/Segments etc.
  $logger.info "Found #{msg_list.size} messages to test\n"
  msg_list
end