require 'shared_examples'
require 'spec_helper'

describe "OhioHealth Encounter record" do
  before(:all) do
    @messages = $messages
  end 
  
  before(:each) do
    log_example( example )
    @failed = []
  end 
      
  it_behaves_like "every record" do
    let(:messages){ @messages }
  end

  it_behaves_like "ADT and rad records" do
    let(:messages){ @messages }
  end

  context "when converted to HL7" do   
    list = [:MSH,:EVN,:PID,:PV1]
    it "has the correct segments", :pattern => "only #{list.join(', ')}" do
      logic = Proc.new{ |msg| 
        msg.segments.each_key{ |k| list.include?(k) }
      }
      @failed = pass?( @messages, logic )
      @failed.should be_empty    
    end

    it "has the correct HL7 version", :pattern => "2.4" do
      logic = Proc.new{ |msg| msg[:MSH].version == "2.4" }
      @failed = pass?( @messages, logic )
      @failed.should be_empty      
    end
  end
  
  context "the patient" do 
    # it "has a race" do
      # logic = Proc.new{ |msg| !msg[:PID].race.empty? }
      # @failed = pass?( @messages, logic )
      # @failed.should be_empty  
    # end
    
    it "has an address" do
      logic = Proc.new{ |msg| !msg[:PID].address.empty? }
      @failed = pass?( @messages, logic )
      @failed.should be_empty  
    end
    
    # it "has a language" do
      # logic = Proc.new{ |msg| !msg[:PID].language.empty? }
      # @failed = pass?( @messages, logic )
      # @failed.should be_empty  
    # end
    
    # it "has a marital status" do
      # logic = Proc.new{ |msg| !msg[:PID].marital_status.empty? }
      # @failed = pass?( @messages, logic )
      # @failed.should be_empty  
    # end
    
    # it "has a religion" do
      # logic = Proc.new{ |msg| !msg[:PID].religion.empty? }
      # @failed = pass?( @messages, logic )
      # @failed.should be_empty  
    # end  
    
    it "has the correct country code", :pattern => "if there is one" do
      logic = Proc.new{ |msg|
        pid = msg[:PID]
        pid[12].to_s == pid.field(11)[8].to_s
      }
      @failed = pass?( @messages, logic )
      @failed.should be_empty  
    end                    
  end

  context "the encounter" do
    it "has a valid patient location", :pattern => "a 3- or 4-letter abbreviation" do
      logic = Proc.new{ |msg| msg[:PV1].patient_location =~ /^[A-Z]{3,4}$/ }
      @failed = pass?( @messages, logic )
      @failed.should be_empty 
    end

    it "has an admission type" do
      logic = Proc.new{ |msg| !msg[:PV1].admission_type.empty? }
      @failed = pass?( @messages, logic )
      @failed.should be_empty 
    end
    
    it "has an admission date and time" do
      logic = Proc.new{ |msg| HL7Test.is_datetime? msg[:PV1].admit_date_time }
      @failed = pass?( @messages, logic )
      @failed.should be_empty 
    end

    it "has a discharge date and time" do
      logic = Proc.new{ |msg| HL7Test.is_datetime? msg[:PV1].discharge_date_time }
      @failed = pass?( @messages, logic )
      @failed.should be_empty 
    end

    it "has a hospital service" do
      logic = Proc.new{ |msg| !msg[:PV1].hospital_service.empty? }
      @failed = pass?( @messages, logic )
      @failed.should be_empty 
    end

    it "has a valid admit source", :pattern => "one digit" do
      logic = Proc.new{ |msg| msg[:PV1].admit_source =~ /^\d$/ }
      @failed = pass?( @messages, logic )
      @failed.should be_empty 
    end

    # it "has a financial class" do
      # logic = Proc.new{ |msg| !msg[:PV1].financial_class.empty? }
      # @failed = pass?( @messages, logic )
      # @failed.should be_empty 
    # end

    # it "has a discharge disposition" do
      # logic = Proc.new{ |msg| !msg[:PV1].discharge_disposition.empty? }
      # @failed = pass?( @messages, logic )
      # @failed.should be_empty 
    # end
  end

  after(:each) do
    log_result( @failed, example )
  end
end