require 'shared_examples'
require 'spec_helper'

describe "Ohio Health Encounter HL7" do
  
  it "only has MSH, PID, PV1, and ENC segments" do
    valid_segs = [:MSH,:PID,:PV1,:ENC]
    $message.segments.each_key{ |k| valid_segs.should include k }
  end
  
  # == General $message tests
  include_examples "General", $message

  # == MSH tests
  context "MSH segment" do
    msh = $message.header    
    include_examples "MSH segment", msh
    include_examples "Lab/ADT MSH segment", msh

    it "has the correct Event", :pattern => 'ADT^A08' do
      msh.event.should == "ADT^A08"
    end
  end

  # == PID tests
  context "PID segment" do
    pid = $message[:PID]
    include_examples "PID segment", pid
    include_examples "ADT PID segment", pid

    it "has a religion", :pattern => "non-empty" do
      pid.religion.should_not be_empty
    end
  end

  # == PV1 tests
  context "PV1 segment" do
    pv1 = $message[:PV1]
    include_examples "PV1 and PID segments", pv1, $message[:PID]
    include_examples "Lab/ADT PV1 segment", pv1

    it "has a valid patient location", :pattern => "non-empty" do
      pv1.patient_location.should_not be_empty
    end

    it "has a valid date/time of admission", :pattern => "YYYYMMDDHHMM" do
      HL7Test.is_datetime?( pv1.admit_date_time ).should be_true
    end

    it "has a valid discharge date/time", :pattern => "YYYYMMDDHHMM" do
      HL7Test.is_datetime?( pv1.discharge_date_time ).should be_true
    end

    it "has a valid patient class", :pattern => "one character" do
      pv1.patient_class.size.should == 1
    end

    it "has a valid Attending Doctor", :pattern => "more than 2 characters" do
      att = pv1.field(:attending_doctor)
      if att.to_s.size > 2 then att[8].should =~ /^\w+PROV$/
      else att[12].should be_empty
      end
    end

    it "has a Hospital Service with max length of 3", :pattern => "up to three characters" do
      pv1.hospital_service.size <= 3
    end

    it "has an Admit Source", :pattern => "" do
      pv1.admit_source.should_not be_empty
    end
      
    it "does not have a VIP Indicator", :pattern => "" do
      pv1.vip_indicator.should be_empty
    end
      
    it "has a Patient Type", :pattern => "" do
      pv1.patient_type.should_not be_empty
    end

    it "has a Financial Class", :pattern => "" do
      pv1.financial_class.should_not be_empty
    end

    it "has a Discharge Disposition", :pattern => "" do
      pv1.discharge_disposition.should_not be_empty
    end
  end

end