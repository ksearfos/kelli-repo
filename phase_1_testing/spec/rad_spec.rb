require 'shared_examples'
require 'spec_helper'

describe "Ohio Health Rad HL7" do
  
  # == General message tests
  include_examples "General", $message

  # == MSH tests
  context "MSH segment" do
    msh = $message.header    
    include_examples "MSH segment", msh

    it "has the correct Processing ID", :pattern => "T" do
      msh.processing_id.should == "T"
    end
    
    it "has the correct version", :pattern => "2.3" do
      msh.version.should == "2.3"
    end
  end

  # == ORC tests
  context "ORC segment" do
    $message[:ORC].each do |orc|
      it "has a valid transaction date/time" do
        HL7Test.is_datetime?( orc.transaction_date_time ).should be_true
      end
    end #each
  end

  # == OBR tests  
  context "OBR segment" do
    obr = $message[:OBR]
    include_examples "OBR segment", obr
        
    it "only appears once per message" do
      obr.size.should == 1 
    end
    
    it "shows the correct set ID", :pattern => "1" do
      obr.set_id.should == '1'
    end

    it "has a valid result interpreter", :pattern => "OBR.8 is (something)PROV, OBR.12 is empty" do
      res_int = obr.field(32)
      res_int[8].should =~ /\w+PROV$/
      res_int[12].should be_empty
    end

    it "has a valid observation date/time", :pattern => "OBR.8" do
      dt = obr.observation_date_time
      HL7Test.is_datetime?( dt ).should be_true if dt
    end

    it "has a valid end exam date/time", :pattern => "OBR.27" do
      dt = obr[27]
      HL7Test.is_datetime?( dt ).should be_true if dt
    end

    it "has a corresponding ORC segment", :pattern => "ORC listed directly before OBR, with same date/time" do
      $message.segment_before(:OBR).should eq :ORC
      $message[:ORC].transaction_date_time.should == obr.observation_date_time
    end
  end

  # == OBX tests
  context "OBX segment" do
    $message[:OBX].each do |obx|
      it "has a valid value type", :pattern => "TX" do
        obx.value_type.should == 'TX'
      end

      it "has a valid Observation ID", :pattern => "one of &GDT, &IMP, or &ADT" do
        ['&GDT','&IMP','&ADT'].should include obx.observation_id
      end
    end #each
  end

  # == PID tests
  context "PID segment" do
    pid = $message[:PID]
    include_examples "PID segment", pid
  end

  # == PV1 tests
  context "PV1 and PID segments" do
    include_examples "PV1 and PID segments", $message[:PV1], $message[:PID]
  end
  
  context "PV1 segment" do
    pv1 = $message[:PV1]
    
    it "has a valid patient location", :pattern => "'ED' if patient class is 'E', and components 2/3 are empty" do
      loc = pv1.field(:patient_location)  
      loc[1].should == "ED" if pv1.patient_class == "E"
      loc[2].should be_empty
      loc[3].should be_empty
    end

    context "provider type", :pattern => "components 8 and 12 are the same" do
      att = pv1.field(:attending_doctor)
      type = att[8]
      
      it "is correct for the attending physician", :pattern => "PV1.7" do
        att[12].should eq type  # att[8] IS the type
      end
      
      it "is correct for the referring physician", :pattern => "PV1.8" do
        ref = pv1.field(:referring_doctor)
        ref[8].should eq type
        ref[12].should eq type
      end
      
      it "is correct for the consulting physician", :pattern => "PV1.9" do
        cons = pv1.field(:consulting_doctor)
        cons[8].should eq type
        cons[12].should eq type
      end
      
      it "is correct for the admitting physician", :pattern => "PV1.17" do
        adm = pv1.field(:admitting_doctor) 
        adm[8].should eq type
        adm[12].should eq type
      end
    end # provider type context
  
    it "has a valid Patient Class", :pattern => "one of Outpatient, Inpatient, Emergency, Observation, Q, or O" do
      ['Outpatient','Emergency','Inpatient','Observation','Q','O'].should include pv1.patient_class
    end
    
    it "does not have a VIP Indicator", :pattern => "no value for PV1.16" do
      pv1[16].should be_empty
    end

    it "has a Patient Type", :pattern => "a number in a list" do
      pv1.patient_type.should_not =~ /\D/
    end
  end
end