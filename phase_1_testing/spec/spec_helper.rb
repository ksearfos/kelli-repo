<<<<<<< HEAD
require 'require_relative'
require 'hl7_utils'
require_relative './hl7_specs/support/hl7_shared_examples'
require 'logger'
require 'set'

# == Methods and Objects we will use

$proj_dir = File.expand_path( "../../", __FILE__ )

$test_descriptions = Set.new

$flagged_messages = Hash.new

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

def get_patient_info( message )
  pid = message[:PID][0]
  patient_mrn = pid.patient_id_list.split("^")[0]
  patient_acct_num = pid.account_number.split("^")[0]
  patient_dob = Date.parse(pid.patient_dob)
  encounter_date = DateTime.parse(message[:OBR][0].observation_date)

  "#{'='*30} Patient Information #{'='*30}\n
  Name               : #{pid.patient_name}
  MRN                : #{patient_mrn}
  Account Number     : #{patient_acct_num}
  Date of Birth      : #{patient_dob.strftime('%m/%d/%Y')}
  Encounter Date/Time: #{encounter_date.strftime('%m/%d/%Y, %r')}
\n#{'='*87}\n"
end

def log_example_exception( example, message )
  exception_message = ""
  if example.exception.to_s[/Diff:/]
    exception_message = example.exception.to_s.split("Diff:")[0]
  else
    exception_message = example.exception.to_s
  end

  error_message = "#{'*'*80}\n
    Error found in:\n#{example.metadata[:full_description]}\n
    Example Exception:\n#{cap_first( exception_message )}
    Pattern translation:\n#{cap_first( example.metadata[:pattern] )}\n
\n#{'*'*87}\n"

  if $flagged_messages.has_key? message[0]
    $flagged_messages[message[0]] =
      $flagged_messages.fetch(message[0]) << error_message
  else
    patient_info = get_patient_info( message )
    $flagged_messages[message[0]] = [patient_info, error_message] 
  end
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

def make_logger( filename, record_count )
  time = DateTime.now.strftime("%F at %T")
  logfilename = ( File.basename(filename) + '_' + time.gsub('at', '-') ).gsub(' ', '').gsub(':', '-')
  $logger = Logger.new("#{File.join($proj_dir, "log", logfilename)}.log")

  $logger.formatter = proc do |severity, datetime, progname, msg|
    "#{severity}: #{msg}\n"
  end
  
  $logger.info "Automated Testing Log for #{File.basename(filename)}\n"

  $logger.info "Number of records tested: #{record_count}\n"
end

# == Configure RSpec

RSpec.configure do |config|
  config.after(:suite) do
    $logger.info "Number of records with potential errors: #{$flagged_messages.size}\n"
    $logger.info "#{'*'*80}\nElements Tested For:\n"
    $test_descriptions.each do |desc|
      $logger.info desc
    end
    $logger.info "*"*80 + "\n"
    $flagged_messages.values.each do |message_errs|
      message_errs.each do |err_data|
        $logger.error err_data
      end
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
=======
$LOAD_PATH.unshift File.expand_path("../..",__FILE__)

require 'rspec'
require 'HL7'

# data of various types
$str = "20535^Watson^David^D^^^MD^^^^^^STARPROV"
$name_str = "Watson^David^D^IV^Dr.^MD"
$name_str_as_name = "Dr. David D Watson IV, MD"
$sm_name_str = "Watson^David^^Jr.^"
$sm_name_str_as_name = "David Watson Jr."
$date_str = "20140128"
$date_str_as_date = "01/28/2014"
$time_str = "141143"
$time_str_as_12hr = "2:11:43 PM"
$time_str_as_24hr = "14:11:43"
$date_time_str = $date_str + $time_str

# field
delim = '^'
$field = HL7::Field.new($str)
$date_field = HL7::Field.new($date_str)
$time_field = HL7::Field.new($time_str)
$dt_field = HL7::Field.new($date_time_str)
$name_field = HL7::Field.new($name_str)
$sm_name_field = HL7::Field.new($sm_name_str)

# segment
$seg_str = "||04172769^^^ST01||Follin^Amy^C||19840402|F|||^^^^^^^|||||||1133632194^^^^STARACC|275823686"
$seg_str2 = "||14159265^^^ST01||Doe^John^^^Mr.||19561217|M|||^^^^^^^|||||||3289472383^^^^STARACC|48711289"
$pid_cl = HL7.typed_segment(:PID)
$pid_fields = HL7::PID_FIELDS
$segment = HL7::Segment.new($seg_str)
$seg_2_line = HL7::Segment.new( $seg_str + "\n" + $seg_str2 )
$pid = $pid_cl.new( "PID|" + $seg_str )

# message
$lab_str =<<LAB
0000000729MSH|^~\&|HLAB|GMH|||20140128041143||ORU^R01|20140128041143833|T|2.4
PID|||00487630^^^ST01||Thompson^Richard^L||19641230|M|||^^^^^^^|||||||A2057219^^^^STARACC|291668118
PV1||Null value detected|||||20535^Watson^David^D^^^MD^^^^^^STARPROV|||||||||||12|A2057219^^^^STARACC|||||||||||||||||
ORC|RE
OBR|||4A  A61302526|4ATRPOC^^OHHOREAP|||201110131555|||||||||A00384^Watson^David^D^^^MD^^STARPROV||||||201110131555|||F
NTE|1||Testing performed by Grady Memorial Hospital, 561 West Central Ave., Delaware, Ohio, 43015, UNLESS otherwise noted.
NTE|2
NTE|3||Indeterminate for MI: 0.08-0.09 ng/mL
NTE|4||Possible MI, recommend follow-up serial testing: 0.1-0.59 ng/mL
NTE|5||Suggestive for MI: 0.6-1.5 ng/mL ; Positive for MI: >1.5 ng/mL
LAB

$rad_str =<<RAD
MSH|^~\&|CENRAD|RMH|||20140226123258||ORU^R01||P|2.4
PID|||03102519^^^ST01||Smith^Kevin^W||195908020000|M|||^^^^^^^|||||||1112431307^^^^STARACC|294645000
PV1||Outpatient|^^||||15677^Hofmeister^Joseph^K^^^MD^^STARPROV^^^^STARPROV|15677^Hofmeister^Joseph^K^^^MD^^STARPROV^^^^STARPROV|^^^^^^^^STARPROV^^^^STARPROV||||||||15677^Hofmeister^Joseph^K^^^MD^^STARPROV^^^^STARPROV|12|1112431307|||||||||||||||||||||||||201105041208|201105042359
ORC|||||||||201105041353||||
OBR|1||H19406393|IMG2027^CT CHEST AND ABDOMEN WITH CONTRAST|||20110501353|||||||||15677^^^^^^^^STARPROV^^^^STARPROV||||||201105041500|||F|||||||21134^^^^^^^^STARPROV^^^^
OBX|1|TX|&GDT||Clinical Information: lung ca 162.9
OBX|2|TX|&GDT||HISTORY:  Lung carcinoma.
OBX|3|TX|&GDT|| 
OBX|4|TX|&GDT||CT OF THE CHEST AND ABDOMEN WITH CONTRAST 05/04/2011:
OBX|5|TX|&GDT|| 
OBX|6|TX|&GDT||TECHNIQUE:  3 mm sections were obtained from the thoracic inlet through the iliac crest following
OBX|7|TX|&GDT||administration of 100 ml of Omnipaque 350.  Coronal and sagittal reformatted images were obtained.
RAD

$lab_message = HL7::Message.new( $lab_str )
$rad_message = HL7::Message.new( $rad_str )

file = "C:/Users/Owner/Documents/script_input/rad_post.txt"
$file_handler = HL7::FileHandler.new( file )

RSpec.configure do |c|
  c.fail_fast = true
end

# takes the code expected to print to stdout
# returns string that was written
# I copied this from one of the nice people on StackOverflow... I can't necessarily explain how it works
def capture_stdout(&blk)
  old = $stdout
  $stdout = fake = StringIO.new
  blk.call
  fake.string
ensure
  $stdout = old
end
>>>>>>> hl7
