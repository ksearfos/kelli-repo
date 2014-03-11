require 'rspec'
require 'hl7module/HL7.rb'

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
$field = HL7Test::Field.new($str)
$date_field = HL7Test::Field.new($date_str)
$time_field = HL7Test::Field.new($time_str)
$dt_field = HL7Test::Field.new($date_time_str)
$name_field = HL7Test::Field.new($name_str)
$sm_name_field = HL7Test::Field.new($sm_name_str)

RSpec.configure do |c|
  c.fail_fast = true
end