#!/bin/env ruby

require 'rspec'
require 'require_relative'
require_relative "../../HL7ProcsMod.rb"
# require "C:/Users/Owner/Documents/Code/kelli-repo/phase-1-testing/hl7_utils.rb"

describe HL7Procs do
before(:all) do
    msg_txt <<END
0000000954MSH|^~\&|HLAB|RMH|||20140128041144||ORU^R01|201401280411441474|T|2.4
PID|||04172773^^^ST01||Edwards^Christopher^S||19820528|M|||^^^^^^^|||||||1131830065^^^^STARACC|412414356
PV1||Null value detected|||||12417^Jennings^Michael^R^^^MD^^^^^^STARPROV|||||||||||12|1131830065^^^^STARACC|||||||||||||||||
ORC|RE
OBR|||11321218590|47615^^OHHOREAP|||201111171011||||||||BLD|12417^Jennings^Michael^R^^^MD^^STARPROV||||||201111171011|||F
OBX|1|NM|PT^Protime (PT)^LA01|1|25.2|seconds|11.8-14.3|H|||F
OBX|2|NM|INR^INR^LA01|1|2.4||0.8-1.1|H|||F
NTE|1||During the induction phase of oral anticoagulation, the INR may not
NTE|2||reflect the anticoagulation status of the patient. Therapeutic ranges
NTE|3||for INR's are: 
NTE|4||Most clinical situations:INR 2.0-3.0
NTE|5||Mechanical Prosthetic Valve:INR 2.5-3.5
NTE|6||Critical:INR >5.0
NTE|7
NTE|8||The above 2 analytes were performed by Mcconnell Heart Health Clinic
NTE|9||3773 Olentangy River Rd,Columbus,OH 43214
END
    @msg = HL7::Message.new(msg_txt)
  end
    
  context "SN_PROC" do
    before(:all) do
      pass_str = "<34"
      fail_str = "34"
    end
    
    it 'correctly matches SN type' do
      puts pass_str
      SN_PROC.call( pass_str ).should be_true
    end
    
    it "fails when passed just a regular number" do
      SN_PROC.call( fail_str ).should be_false
    end   
  end
end