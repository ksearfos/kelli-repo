#!/bin/env ruby
@@proj_dir = File.expand_path( "../../../../", __FILE__ )   # phase_1_testing directory
require 'rspec'
require 'rspec/expectations'
require 'spec_helper'
require "#{@@proj_dir}/lib/extended_base_classes"

# == Describe the tests

def test_message( message )

  describe "Ohio Health ADT HL7" do
  
# == General message tests

    include_examples "General", message

# == MSH tests
    # Field names do not work unless converted to HL7::Segment::MSH
    context "MSH segment" do
      msh = message[0]    
      include_examples "MSH segment", msh
      include_examples "Lab/ADT MSH segment", msh

      it "has MSH segments with the correct Event format",
      :pattern => 'ADT^A08' do
        msh.e8.should eq "ADT^A08"
      end
    end

# == PID tests

    context "PID segment" do

      pid = message[:PID][0]
      include_examples "PID segment", pid
      include_examples "Rad/ADT PID segment", pid

      it "has a valid Religion",
      :pattern => "" do
        pid.religion.should match /^[A-Za-z ]+$/
      end

    end # End of PID Context

# == PV1 tests

    context "PV1 segment" do
      pv1 = message[:PV1][0]
      include_examples "PV1 segment", pv1, message[:PID][0]
      include_examples "Lab/ADT PV1 segment", pv1

      it "has an acceptable Patient Location",
      :pattern => "some text" do
        pv1.assigned_location.should match /^[a-zA-Z ]+$/
      end

      it "has Admit Date in the correct format",
      :pattern => "a timestamp of yyyyMMddHHmm" do
        pv1.admit_date.should match /^(19|20)\d\d(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])((0|1)[0-9]|2[0-3])(0[0-9]|[1-5][0-9])$/
      end

      it "has Discharge Date in the correct format",
      :pattern => "a timestamp of yyyyMMddHHmm" do
        pv1.discharge_date.should match /^(19|20)\d\d(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])((0|1)[0-9]|2[0-3])(0[0-9]|[1-5][0-9])$/
      end

      it "has a Patient Class of one character" do
        pv1.patient_class.should match /^\w{1}$/
      end

      it "has Attending Doctor in the correct format",
      :pattern => "The provider type should be consistent" do
        if pv1.attending_doctor.size > 2
          attending_doctor_fields = pv1.attending_doctor.split "^", -1
          provider_type = attending_doctor_fields[8]
          provider_type.should match /^\wPROV$/
          attending_doctor_fields[12].should eq provider_type
        end
      end

      it "has a Hospital Service with max length of 3",
      :pattern => "up to three characters" do
        pid.hospital_service.should match /^\w{0,3}$/
      end

      it "has an Admit Source",
      :pattern => "" do
        pid.admit_source.should_not be_empty
      end
      
      it "does not have a VIP Indicator",
      :pattern => "" do
        pid.vip_indicator.should be_empty
      end
      
      it "has a Patient Type",
      :pattern => "" do
        pid.patient_type.should_not be_empty
      end

      it "has a Financial Class",
      :pattern => "" do
        pid.financial_class.should_not be_empty
      end

      it "has a Discharge Disposition",
      :pattern => "" do
        pid.discharge_disposition.should_not be_empty
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
