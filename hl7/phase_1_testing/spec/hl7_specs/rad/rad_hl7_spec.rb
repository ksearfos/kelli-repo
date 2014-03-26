#!/bin/env ruby
@@proj_dir = File.expand_path( "../../../../", __FILE__ )   # phase_1_testing directory
require 'rspec'
require 'rspec/expectations'
require 'spec_helper'
require "#{@@proj_dir}/lib/extended_base_classes"

# == Describe the tests

def test_message( message )

  describe "Ohio Health Rad HL7" do
  
# == General message tests

    include_examples "General", message

# == MSH tests
    # Field names do not work unless converted to HL7::Segment::MSH
    context "MSH segment" do
      msh = message[0]    
      include_examples "MSH segment", msh
      include_examples "Lab/Rad MSH segment", msh

      it "has the correct Processing ID",
      :pattern => "the Processing ID must be 2.3" do
        msh.e11.should match /^2.3$/
      end
    end

# == ORC tests

    context "ORC segment", 
    :pattern => 'any two characters' do
      message[:ORC].each do |orc|

        it "has a Date/Time of Transaction in the correct format",
        :pattern => "a timestamp in yyyyMMddHHmm format" do
          orc.date_time_of_transaction.should match /^(19|20)\d\d(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])((0|1)[0-9]|2[0-3])(0[0-9]|[1-5][0-9])$/
        end

      end
    end

# == OBR tests
    
    context "OBR segment" do
      message[:OBR].each do |obr|
        include_examples "OBR segment", obr, message

        it "has Principal Result Interpreter in the correct format",
        :pattern => "field 8 (something)PROV, field 12 is empty" do
          obr.principal_result_interpreter.should_not be_nil
          obr_pri_fields = obr.principal_result_interpreter.split "^", -1
          obr_pri_fields[8].should match /\w+PROV/
          obr_pri_fields[12].should be_empty
        end

        it "has Observation Date/Time in the correct format", 
        :pattern => 'a timestamp in yyyyMMddHHmm format' do
          obr.observation_date.should match /^(19|20)\d\d(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])((0|1)[0-9]|2[0-3])(0[0-9]|[1-5][0-9])$/
        end

        it "has End Exam Date/Time in the correct format", 
        :pattern => 'a timestamp in yyyyMMddHHmm format' do
          obr.results_status_change_date.should match /^(19|20)\d\d(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])((0|1)[0-9]|2[0-3])(0[0-9]|[1-5][0-9])$/
        end

        it "has the correct Set ID",
        :pattern => "the Set ID must be '1'" do
          obr.set_id.should eq "1"
        end

        it "has a corresponding ORC segment",
        :pattern => "" do
          orc = message[:ORC][0]
          orc.date_time_of_transaction.should eq obr.observation_date
        end
   
# == OBX tests

        context "-- OBX child" do
          obx_children = get_obx_of_obr( obr )
          obx_children.each do |obx|
            include_examples "OBX child", obx, obx.value_type

            it "has a valid Value Type",
            :pattern => "Value Type of Rad OBX must be TX" do
              obx.value_type.should match /^TX$/
            end

            it "has a valid Observation ID",
            :pattern => "Observation ID can be &GDT or &IMP or &ADT" do
              obx.observation_id.should match /^(&GDT|&IMP|&ADT)$/
            end
          
          end # End of obx_children.each
        end  # End of OBX context

      end # End of message[:OBR].each
    end # End of OBR context

# == PID tests

    context "PID segment" do

      pid = message[:PID][0]
      include_examples "PID segment", pid
      include_examples "Rad/ADT PID segment", pid

    end # End of PID Context

# == PV1 tests

    context "PV1 segment" do
      pv1 = message[:PV1][0]
      include_examples "PV1 segment", pv1, message[:PID][0]

      it "has a valid Assigned Location",
      :pattern => "Either assigned location is 'ED' or empty" do
        assigned_location_fields = pv1.assigned_location.split "^", 3
        if pv1.patient_class[0] == "E"
          assigned_location_fields[0].should eq "ED"
        else
          assigned_location_fields[1].should be_empty
          assigned_location_fields[2].should be_empty
        end
      end

      it "has matching provider types",
      :pattern => "The provider type should be consistent" do
        attending_doctor_fields = pv1.attending_doctor.split "^"
        provider_type = attending_doctor_fields[8]
        attending_doctor_fields[12].should eq provider_type
        pv1.referring_doctor[/#{provider_type}/].should_not be_empty
        pv1.consulting_doctor[/#{provider_type}/].should_not be_empty
        pv1.admitting_doctor[/#{provider_type}/].should_not be_empty
      end

      it "has a valid Patient Class",
      :pattern => "a word" do
        pv1.patient_class.should match /^\w+$/
      end

      it "does not have a VIP Indicator",
      :pattern => "" do
        pv1.vip_indicator.should be_empty
      end

      it "has a Patient Type",
      :pattern => "" do
        pv1.patient_type.should_not be_empty
      end

    end # End of PV1 Context

    after(:each) do
      add_description( example.metadata[:full_description] )
      log_example_exception( example, message ) unless example.exception.nil?
    end

  end # End of Describe Ohio Health HL7 Message
end

# == Set up and run the tests

file_to_open = ENV["FILE"]
msg_list = get_test_data file_to_open
make_logger file_to_open, msg_list.size
run_hl7_tests msg_list
