require 'rspec'
require 'hl7module/HL7.rb'

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
$field = HL7Test::Field.new($str)
$date_field = HL7Test::Field.new($date_str)
$time_field = HL7Test::Field.new($time_str)
$dt_field = HL7Test::Field.new($date_time_str)
$name_field = HL7Test::Field.new($name_str)
$sm_name_field = HL7Test::Field.new($sm_name_str)

# segment
$seg_str = "||04172769^^^ST01||Follin^Amy^C||19840402|F|||^^^^^^^|||||||1133632194^^^^STARACC|275823686"
$seg_str2 = "||14159265^^^ST01||Doe^John^^^Mr.||19561217|M|||^^^^^^^|||||||3289472383^^^^STARACC|48711289"
$pid_cl = HL7Test.new_typed_segment(:PID)
$pid_fields = HL7Test::PID_FIELDS
$segment = HL7Test::Segment.new($seg_str)
$seg_2_line = HL7Test::Segment.new( $seg_str + "\n" + $seg_str2 )
$pid = $pid_cl.new( "PID|" + $seg_str )

RSpec.configure do |c|
  c.fail_fast = true
end