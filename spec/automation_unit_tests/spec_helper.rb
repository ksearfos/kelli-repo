require 'classes/AutomatedTestsRunner'
require 'rspec'
require 'rspec/expectations'

message_text =<<LAB
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
$lab_message = HL7::Message.new(message_text)

RSpec.configure do |c|
  c.fail_fast = true
end

class SpecHelperClass
  include TestRunnerMixIn
  attr_reader :logger
  
  def initialize
    set_common_instance_variables(:rad, true)
  end
end

class SpecHelperComparerClass < SpecHelperClass
  include ComparerMixIn  
  attr_reader :comparer
end

class SpecHelperRspecClass < SpecHelperClass
  include RSpecMixIn
end