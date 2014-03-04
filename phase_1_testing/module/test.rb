#!/bin/env ruby

proj_dir = File.expand_path( "../..", __FILE__ )
FILE = "#{proj_dir}/resources/manifest_lab_out_short"
$msg = <<END
0000000599MSH|^~\&|HLAB|RMH|||20140128041144||ORU^R01|201401280411444405|T|2.4
PID|||00547448^^^ST01||Tanner^Michael||19510325|M|||^^^^^^^|||||||1134733972^^^^STARACC|291442286
PV1||Null value detected|||||11420^Eskin^Steven^J^^^MD^^^^^^STARPROV|||||||||||12|1134733972^^^^STARACC|||||||||||||||||
ORC|RE
OBR|||11348776858|46608^^OHHOREAP|||201112132347||||||||BLD|11420^Eskin^Steven^J^^^MD^^STARPROV||||||201112132347|||F
OBX|1|SN|TROP^Troponin T^LA01|1|<0.010|ng/mL|0.000-0.040||||F
NTE|1||The above 1 analytes were performed by Riverside Methodist Hospital
NTE|2||3535 Olentangy River Rd,Columbus,OH 43214
END
$seg = "NTE|1||The above 1 analytes were performed by Riverside Methodist Hospital"
$segs = "OBX||TX|APRESULT^.^LA01|1|.||||||F\nOBX||TX|BSRESULT^.^LA02|2|  REPORT||||||F"
$field = "Thompson^Richard^L^III"

require "#{proj_dir}/module/HL7"

msg = HL7::Message.new( $msg )
puts msg.important_details(:raisin)
puts msg.important_details(:patient_name)
