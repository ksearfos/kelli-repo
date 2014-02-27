#!/bin/env ruby

require 'rspec'
require 'hl7_utils'
require 'extended_base_classes'

describe "Ohio Health HL7" do
  before(:all) do
    raw_hl7 = ""
    File.open( "../../resources/manifest_lab_out_short", 'rb' ) do |f|
      #blank lines cause HL7 Parse Error...
      #and ASCII line endings cause UTF-8 Error..
      while s = f.gets do
        t = s.force_encoding("binary").encode('utf-8', 
            :invalid => :replace, :undef => :replace)
        raw_hl7 << t.chomp + "\n"
      end
    end

    @msg_list = hl7_by_record raw_hl7
  end
  
  it 'has MSH segments with the correct Event format' do
    @msg_list.each do |message|
      message[0].e8.should match /^ORU\^R01$/
    end
  end

  it 'has only one PID per message' do
    @msg_list.each do |message|
      message.children[:PID].size.should == 1
    end
  end

  it 'has only one PV1 per message' do
    @msg_list.each do |message|
      message.children[:PV1].size.should == 1
    end
  end
  
  it 'has PID segments with the correct Patient ID format' do
    @msg_list.each do |message|
      pid = message.children[:PID][0]
      pid.patient_id_list.should match /^\d*\^/
      pid.patient_id_list.should match /\^\w+01$/
    end
  end

  it 'has ORC segments with Control ID of two characters' do
    @msg_list.each do |message|
      message[:ORC].each do |orc|
        orc.order_control.should match /^\w{2}$/
      end
    end
  end

  it 'has OBR Control Code containing only letters, numbers, and spaces' do
    @msg_list.each do |message|
      message[:OBR].each do |obr|
        obr.filler_order_number.should match /^[A-Za-z0-9 ]+/
      end
    end
  end

  it 'has OBR Procedure ID in the correct format' do
    @msg_list.each do |message|
      message.children[:OBR].each do |obr|
        obr.universal_service_id.should match /^[A-Z0-9]+\^/
        if message[0].e3 =~ /MGH/
          obr.universal_service_id.should match /\^ECAREEAP$/
        else
          obr.universal_service_id.should match /\^OHHOREAP$/
        end
      end
    end
  end

  # Consider adding test for provider title e.g. MD, DO, etc...
  it 'has OBR Ordering Provider in the correct format' do
    @msg_list.each do |message|
      message.children[:OBR].each do |obr|
        obr.ordering_provider.should match /^[A-Z0-9]+\^/
        obr.ordering_provider.should match /\^[A-Z a-z]+\^[A-Z a-z]+\^/
        obr.ordering_provider.should match /\^[A-Z]{1}\^/
        obr.ordering_provider.should match /\^\w+PROV$/
      end
    end
  end

  # Make sure all possible status markers are in regex
  it 'has OBR Result Status in the correct format' do
    @msg_list.each do |message|
      message.children[:OBR].each do |obr|
        obr.result_status.should match /^[DFNOSWPCXRUI]$/
      end
    end
  end

  # Consider checking elements 1 and 2 of this segment
  it 'has OBX Component Id in the correct format' do
    @msg_list.each do |message|
      message.children[:OBR].each do |obr|
        obx_children = get_obx_of_obr( obr )
        obx_children.each do |obx|
          obx.observation_id.should match /\^LA01$/
        end
      end
    end
  end

  it 'has OBX Observation Values in the correct format' do
    @msg_list.each do |message|
      message.children[:OBR].each do |obr|
        obx_children = get_obx_of_obr( obr )
        obx_children.each do |obx|
          # Only check numerical observation values
          if obx.value_type =~ /^(SN|NM)$/
            obx.observation_value.should match /^[<>]?\d+\.?\d?{1,3}$/
          end
        end
      end
    end
  end

  it 'has PIDs with Patient Name in the correct format' do
    @msg_list.each do |message|
      pid = message.children[:PID][0]
      # Lastname^Firstname^I^JR.|SR.|RomanNumeral
      pid.patient_name.should match /^\w+\^\w+(\^[A-Z]{1})?(\^((JR|SR)\.|((II|III|IV|V))))?$/
    end
  end

  it 'has PIDs with Date of Birth in the correct format' do
    @msg_list.each do |message|
      pid = message.children[:PID][0]
      # YYYYMMDD
      pid.patient_dob.should match /^(19|20)\d\d(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])$/
    end
  end

  it 'has PIDs with Sex in the correct format' do
    @msg_list.each do |message|
      pid = message.children[:PID][0]
      # F|M|O|U|A|N|C
      pid.admin_sex.should match /^[FMOUANC]$/
    end
  end

  it 'has PIDs wiht Visit ID in the correct format' do
     @msg_list.each do |message|
      pid = message.children[:PID][0]
      pid.account_number.should match /^[A-Z]?\d+\^/
      pid.account_number.should match /\^\w+ACC$/
    end
  end

  it 'has PV1s wiht Visit ID in the correct format' do
     @msg_list.each do |message|
      pv1 = message.children[:PV1][0]
      pv1.visit_number.should match /^[A-Z]?\d+\^/
      pv1.visit_number.should match /\^\w+ACC$/
    end
  end

  it 'has PID and PV1 Visit IDs that match' do
    @msg_list.each do |message|
      pid = message.children[:PID][0]
      pv1 = message.children[:PV1][0]
      pid.account_number.should eq pv1.visit_number
    end
  end

  it 'has PIDs with SSN in the correct format' do
    @msg_list.each do |message|
      pid = message.children[:PID][0]
      pid.social_security_num.should match /^\d{9}$/
    end
  end

  after(:each) do
    puts "\nTest executed!"
  end
end


#### Helper methods ####

def get_obx_of_obr( obr )
  obr.children.select { |s|
          s.is_a? HL7::Message::Segment::OBX }
end
