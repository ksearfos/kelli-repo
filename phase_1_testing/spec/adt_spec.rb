require 'shared_examples'
require 'spec_helper'

describe "Ohio Health Encounter HL7" do
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

  list = [:MSH,:EVN,:PID,:PV1]
  it "has the correct segments", :pattern => "only #{list.join(', ')}" do
    logic = Proc.new{ |msg|
      msg.segments.each_key{ |k| list.include?(k) }
    }
    @failed = pass?( @messages, logic )
    @failed.should be_empty    
  end
  
  # == MSH tests
  context "MSH segment" do
    it_behaves_like "a normal MSH segment" do
      let(:messages){ @messages }
    end
  end

  # == PID tests
  context "PID segment" do
    it_behaves_like "a normal PID segment" do 
      let(:messages){ @messages }
    end
  
    it_behaves_like "a PID segment in ADT messages" do 
      let(:messages){ @messages }
    end

    it "has a religion" do
      logic = Proc.new{ |msg| !msg[:PID].religion.empty? }
      @failed = pass?( @messages, logic )
      @failed.should be_empty  
    end
  end

  # == PV1 tests
  context "PV1 segment" do
    it_behaves_like "the PV1 visit number and PID account number" do
      let(:messages){ @messages }
    end
    
    it_behaves_like "a PV1 segment in Lab/ADT messages" do
      let(:messages){ @messages }
    end

    it "has a valid patient location" do
      logic = Proc.new{ |msg| !msg[:PV1].patient_location.empty? }
      @failed = pass?( @messages, logic )
      @failed.should be_empty 
    end

    it "has a valid date/time of admission" do
      logic = Proc.new{ |msg| HL7Test.is_datetime? msg[:PV1].admit_date_time }
      @failed = pass?( @messages, logic )
      @failed.should be_empty 
    end

    it "has a valid discharge date/time" do
      logic = Proc.new{ |msg| HL7Test.is_datetime? msg[:PV1].discharge_date_time }
      @failed = pass?( @messages, logic )
      @failed.should be_empty 
    end

    it "has a valid patient class", :pattern => "one character" do
      logic = Proc.new{ |msg| msg[:PV1].patient_class.size == 1 }
      @failed = pass?( @messages, logic )
      @failed.should be_empty 
    end

    it "has a valid Attending Doctor" do
      logic = Proc.new{ |msg|
        att = msg[:PV1].field(:attending_doctor)
        listed = ( att[1] =~ /\d+/ && HL7Test.is_name?(att.components[1..4]) )
        att.to_s.size > 2 ? listed && att[9] =~ /^\w+PROV$/ : listed && att[12].empty?
      }
      @failed = pass?( @messages, logic )
      @failed.should be_empty 
    end

    it "has a valid Hospital Service", :pattern => "up to three characters" do
      logic = Proc.new{ |msg| msg[:PV1].hospital_service.size <= 3 }
      @failed = pass?( @messages, logic )
      @failed.should be_empty 
    end

    it "has an Admit Source" do
      logic = Proc.new{ |msg| !msg[:PV1].admit_source.empty? }
      @failed = pass?( @messages, logic )
      @failed.should be_empty 
    end
      
    it "does not have a VIP Indicator" do
      logic = Proc.new{ |msg| msg[:PV1][16].empty? }
      @failed = pass?( @messages, logic )
      @failed.should be_empty  
    end
      
    it "has a Patient Type" do
      logic = Proc.new{ |msg| !msg[:PV1].patient_type.empty? }
      @failed = pass?( @messages, logic )
      @failed.should be_empty 
    end

    it "has a Financial Class" do
      logic = Proc.new{ |msg| !msg[:PV1].financial_class.empty? }
      @failed = pass?( @messages, logic )
      @failed.should be_empty 
    end

    it "has a Discharge Disposition" do
      logic = Proc.new{ |msg| !msg[:PV1].discharge_disposition.empty? }
      @failed = pass?( @messages, logic )
      @failed.should be_empty 
    end
  end

  after(:each) do
    log_result( @failed, example )
  end
end