#!/bin/env ruby

require 'run_rspec'
require 'run_record_comparer'

# set up and prettify the $logger
def set_up_logger( file )
  $stdout.reopen(file, "w")
  Logger.new file
end

def get_records( files )
  if files.empty?
    $logger.info "No new files found.\n"
    return []
  else
    $logger.info "Found #{files.size} new file(s):\n  " + files.join("\n  ") + "\n"
  end
  
  # now break into records - sets all_recs
  msg_list = []
  hdlers = files.map{ |f| HL7Test::MessageHandler.new(f) }
  hdlers.each{ |mh| msg_list << mh.records }
  
  msg_list.flatten!(1) unless msg_list.first.is_a? HL7Test::Message  # only flatten Arrays, not Messages/Segments etc.
  $logger.info "Found #{msg_list.size} messages to test\n"
  msg_list
end