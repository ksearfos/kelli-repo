#!/bin/env ruby

require 'run_rspec'
require 'run_record_comparer'
require 'CSV'

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

def remove_files( files )
  dir = File.expand_path("..",files.first)
  old_size = Dir.entries( dir ).size
  f_size = files.size
  
  $logger.info "Deleting #{f_size} files"
  files.each{ |f| File.delete( f ) }
  
  new_size = Dir.entries( dir ).size
  diff = new_size - (old_size - f_size)    # number of files we have minus number of files we should have
  if diff == 0 then $logger.info "#{f_size} files successfully deleted\n"
  else $logger.error "Failed to delete #{diff} file(s)\n"
  end
end

def make_csv( ary, file )
  # CSV.open( file, "wb" ) do |csv|
    # ary.each{ |row| csv.puts row }
  # end
  puts ary
  $logger.info "See #{file}"
end
