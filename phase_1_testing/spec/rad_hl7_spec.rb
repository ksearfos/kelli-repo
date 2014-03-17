require 'shared_examples'
require 'spec_helper'

describe "Ohio Health Lab HL7" do
  
  # == General message tests
  include_examples "General", $message

  # == MSH tests
  context "MSH segment" do
    msh = $message.header    
    include_examples "MSH segment", msh
    include_examples "Lab/Rad MSH segment", msh

    it "has the correct Processing ID" do
      msh.processing_id.should == "T"
    end
    
    it "has the correct version" do
      msh.version.should == "2.3"
    end
  end

  # == ORC tests
  context "ORC segment", :pattern => 'any two characters' do
    $message[:ORC].each do |orc|
      it "has a valid transaction date/time", :pattern => '' do
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
    
    it "shows the correct set ID", :pattern => "set ID is 1" do
      obr.set_id.should == '1'
    end

    it "has a valid result interpreter", :pattern => "field 8 is (something)PROV, field 12 is empty" do
      res_int = obr.field(32)
      res_int[8].should =~ /\w+PROV$/
      res_int[12].should be_empty
    end

    it "has a valid observation date/time", :pattern => '' do
      HL7Test.is_datetime?( obr.observation_date_time ).should be_true
    end

    it "has a valid end exam date/time", :pattern => '' do
      HL7Test.is_datetime?( obr[27] ).should be_true    # end exam date/time = field 27
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
    include_examples "Rad/ADT PID segment", pid
  end

  # == PV1 tests
  context "PV1 segment" do
    pv1 = $message[:PV1]
    include_examples "PV1 segment", pv1, $message[:PID]

    it "has a valid patient location", :pattern => "'ED' if patient class is 'E', and components 2/3 are empty" do
      loc = pv1.field(:patient_location)  
      pv1[1].should == "ED" if pv1.patient_class == "E"
      pv1[2].should be_empty
      pv1[3].should be_empty
    end

    context "provider type" do
      att = pv1.field(:attending_doctor)
      type = att[8]
      
      it "is correct for the attending physician" do
        att[12].should eq type  # att[8] IS the type
      end
      
      it "is correct for the referring physician" do
        ref = pv1.field(:referring_doctor)
        ref[8].should eq type
        ref[12].should eq type
      end
      
      it "is correct for the consulting physician" do
        cons = pv1.field(:consulting_doctor)
        cons[8].should eq type
        cons[12].should eq type
      end
      
      it "is correct for the admitting physician" do
        adm = pv1.field(:admitting_doctor) 
        adm[8].should eq type
        adm[12].should eq type
      end
    end # provider type context
  
    it "has a valid Patient Class", :pattern => "one of Outpatient, Inpatient, Emergency, Observation, Q, or O" do
      ['Outpatient','Emergency','Inpatient','Observation','Q','O'].should include pv1.patient_class
    end
    
    it "does not have a VIP Indicator", :pattern => "" do
      pv1.vip_indicator.should be_empty
    end

    it "has a Patient Type", :pattern => "a number corresponding to a list value" do
      pv1.patient_type.should_not !~ /\D/
    end
  end
end