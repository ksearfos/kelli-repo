require 'require_relative'
require 'hl7_utils'
require_relative './hl7_specs/support/hl7_shared_examples'
require 'logger'
require 'set'

# == Methods and Objects we will use

$proj_dir = File.expand_path( "../../", __FILE__ )

$test_descriptions = Set.new

def known_units
  ["","%","%/L","% of total Hb","/hpf","/lpf","/mcL",
   "cells/mcL","copies/mL","IU/mL","K/mcL","log copies/mL",
   "M/mcL","PG","U","U/L","U/mL","fL","g","g/dL","g/24 hr",
   "h","hours","lbs","log IU/mL","mIU/mL","mL","mL/min/1.73 m2",
   "mcIU/mL","mcg/dL","mcg/mL FEU","mg/24 h","mg/L","mg/dL",
   "mg/g crea","mlU/mL","mm Hg","mm/hr","mmol/L","mOsm/kg",
   "ng/dL","ng/mL","nmol/L","pH units","pg/mL","ratio","seconds",
   "titer","weeks","years"]
end

def abnormal_flags
  ["","I","CH","CL","H","L","A","U","N","C"]
end

def get_obx_of_obr( obr )
  obr.children.select { |s|
          s.is_a? HL7::Message::Segment::OBX }
end

def full_description( example )
  example.metadata[:full_description]
end

def log_example_exception( example, message )
  exception_message = ""
  if example.exception.to_s[/Diff:/]
    exception_message = example.exception.to_s.split("Diff:")[0]
  else
    exception_message = example.exception.to_s
  end

  $logger.error "#{'*'*80}\n    Error found in:
#{example.metadata[:full_description]}\n
    Example Exception:\n#{cap_first( exception_message )}
    Pattern translation:\n#{cap_first( example.metadata[:pattern] )}\n
    Message Tested:\n#{message.to_s}\n#{'*'*80}\n"
end

def cap_first( string )
  if string.size > 1
    string.slice(0,1).capitalize + string.slice(1..-1)
  else
    string.capitalize
  end
end

def add_description( description )
  $test_descriptions.add( description )
end

# == Get data to test
def clean_file( filename )
  raw_data = ""
  File.open( filename, "rb" ) do |f|
    while s = f.gets do
      s.gsub!(/\r\n?/, "\n")
      s.gsub!(/\n\n/, "\n")
      raw_data << s.chomp
    end
  end
  raw_data
end

def get_test_data( filename )
  if filename.nil? # check that a filename was passed in
    raise "Could not load test data; filename was nil."
  end
  raw_hl7 = clean_file filename
  orig_hl7_by_record raw_hl7
end

# == Set up the logger

def make_logger( filename, record_size )
  time = DateTime.now.strftime("%F at %T")
  logfilename = ( File.basename(filename) + '_' + time.gsub('at', '-') ).gsub(' ', '').gsub(':', '-')
  $logger = Logger.new("#{File.join($proj_dir, "log", logfilename)}.log")

  $logger.formatter = proc do |severity, datetime, progname, msg|
    "#{severity}: #{msg}\n"
  end
  
  $logger.info "Automated Testing Log for #{File.basename(filename)}\n"

  $logger.info "Number of records tested: #{record_size}\n"
end

# == Configure RSpec

RSpec.configure do |config|
  config.after(:suite) do
    $logger.info "#{'*'*80}\nElements Tested For:\n"
    $test_descriptions.each do |desc|
      $logger.info desc
    end
  end
end

# == Run the tests
def run_hl7_tests( msg_list )
  # Large data sets cause memory problems...
  # ... so divide and conquer!
  records_left = msg_list.size
  while records_left > 0
    if records_left >= 1000
      start_record = msg_list.size - records_left
      msg_list[start_record...1000].each { |message| test_message( message ) }
    else
      start_record = msg_list.size - records_left
      msg_list[start_record..-1].each { |message| test_message( message ) }
    end
    records_left -= 1000
  end
end
