require 'shared_examples'
require 'spec_helper'

describe "Ohio Health Rad HL7" do
  before(:all) do
    @messages = $messages
  end 
  
  before(:each) do
    log_example( example )
    @failed = []
  end 
      
  # == General message tests
  it_behaves_like "every HL7 message" do
    let(:messages){ @messages }
  end

  # == MSH tests
  context "MSH segment" do
    it_behaves_like "a normal MSH segment" do
      let(:messages){ @messages }
    end

    it "has the correct Processing ID", :pattern => "T" do
      logic = Proc.new{ |msg| msg[:MSH].processing_id == "T" }
      @failed = pass?( @messages, logic )
      @failed.should be_empty
    end
    
    it "has the correct version", :pattern => "2.3" do
      logic = Proc.new{ |msg| msg[:MSH].version == "2.3" }
      @failed = pass?( @messages, logic )
      @failed.should be_empty
    end
  end

  # == ORC tests
  context "ORC segment" do
    it_behaves_like "a normal ORC segment" do
      let(:messages){ @messages }
    end
    
    it "has a valid transaction date/time" do
      logic = Proc.new{ |msg| HL7Test.is_datetime? msg[:ORC].transaction_date_time }
      @failed = pass?( @messages, logic )
      @failed.should be_empty
    end
  end

  # == OBR tests  
  context "OBR segment" do
    it_behaves_like "a normal OBR segment" do
      let(:messages){ @messages }
    end

    it "shows the correct set ID", :pattern => "1" do
      logic = Proc.new{ |msg| msg[:OBR].set_id == '1' }
      @failed = pass?( @messages, logic )
      @failed.should be_empty
    end

    it "has a valid result interpreter", :pattern => "ID first, then (something)PROV" do      
      logic = Proc.new{ |msg|
        int = msg[:OBR].field(32)
        int[1] =~ /\d+/ && int[9] =~ /PROV$/
      }
      @failed = pass?( @messages, logic )
      @failed.should be_empty
    end

    it "has a valid end exam date/time" do
      logic = Proc.new{ |msg|
        dt = msg[:OBR][27]
        dt.empty? || HL7Test.is_datetime?(dt)
      }
      @failed = pass?( @messages, logic )
      @failed.should be_empty
    end

    it "has a corresponding ORC segment", :pattern => "ORC listed directly before OBR, with same date/time" do
      logic = Proc.new{ |msg|
        ( msg.segment_before(:OBR) == :ORC ) &&
        ( msg[:ORC].transaction_date_time == msg[:OBR].observation_date_time )
      }
      @failed = pass?( @messages, logic )
      @failed.should be_empty
    end
  end

  # == OBX tests
  context "OBX segmentS" do
    it "have the correct value type", :pattern => "TX" do
      logic = Proc.new{ |obx| obx.value_type == 'TX' }
      @failed = pass_for_each?( @messages, logic, :OBX )
      @failed.should be_empty
    end

    list = ['&GDT','&IMP','&ADT']
    it "have a valid Observation ID", :pattern => "one of #{list.join(', ')}" do        
      logic = Proc.new{ |obx| list.include? obx.observation_id }
      @failed = pass_for_each?( @messages, logic, :OBX )
      @failed.should be_empty
    end
  end

  # == PID tests
  context "PID segment" do
    it_behaves_like "a normal PID segment" do 
      let(:messages){ @messages }
    end
  end

  # == PV1 tests
  context "PV1 segment" do
    it_behaves_like "the PV1 visit number and PID account number" do
      let(:messages){ @messages }
    end
    
    it "has a valid patient location", :pattern => "'ED' if patient class is 'E', and no other information" do
      logic = Proc.new{ |msg|
        pv1 = msg[:PV1]
        loc = pv1.field(:patient_location)  
        empty = ( loc[2].to_s.empty? && loc[3].to_s.empty? )
        pv1.patient_class == "E" ? loc[1] == "ED" && empty : empty
      }
      @failed = pass?( @messages, logic )
      @failed.should be_empty
    end

    context "provider type", :pattern => "appears twice for each provider" do
      it "is correct for the attending physician" do
        logic = Proc.new{ |msg| 
          att = msg[:PV1].field(:attending_doctor)
          att[8] = att[12]
        }
        @failed = pass?( @messages, logic )
        @failed.should be_empty
      end
      
      it "is correct for the referring physician" do
        logic = Proc.new{ |msg| 
          ref = msg[:PV1].field(:referring_doctor)
          ref[8] = ref[12]
        }
        @failed = pass?( @messages, logic )
        @failed.should be_empty
      end
      
      it "is correct for the consulting physician" do
        logic = Proc.new{ |msg| 
          cons = msg[:PV1].field(:consulting_doctor)
          cons[8] = cons[12]
        }
        @failed = pass?( @messages, logic )
        @failed.should be_empty
      end
      
      it "is correct for the admitting physician" do
        logic = Proc.new{ |msg| 
          adm = msg[:PV1].field(:admitting_doctor)
          adm[8] = adm[12]
        }
        @failed = pass?( @messages, logic )
        @failed.should be_empty
      end
    end # provider type context
  
    list = ['Outpatient','Emergency','Inpatient','Observation','Q','O']
    it "has a valid Patient Class", :pattern => "one of #{list.join(', ')}" do      
      logic = Proc.new{ |msg| list.include? msg[:PV1].patient_class }
      @failed = pass?( @messages, logic )
      @failed.should be_empty
    end
    
    it "does not have a VIP Indicator" do
      logic = Proc.new{ |msg| msg[:PV1][16].empty? }
      @failed = pass?( @messages, logic )
      @failed.should be_empty
    end

    it "has a Patient Type", :pattern => "a number in a list" do
      logic = Proc.new{ |msg| msg[:PV1].patient_type !~ /\D/ }
      @failed = pass?( @messages, logic )
      @failed.should be_empty
    end
  end
  
  after(:each) do
    log_result( @failed, example )
  end
end