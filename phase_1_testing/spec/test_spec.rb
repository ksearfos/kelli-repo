require 'shared_examples'
require 'spec_helper'

describe "Ohio Health Lab HL7" do
  
  before(:all) do
    @messages = $messages
  end 
  
  before(:each) do
    log_example( example )
    @failed = []
  end 

  # == General message tests
  it_behaves_like "every HL7 message" do
    let(:message){ @messages }
  end

  # == PV1 tests
  context "PV1 segment" do

    it "has a valid attending doctor", :pattern => 'begins with an optional P + digits, ends with (something)PROV' do
      logic = Proc.new{ |msg|
        att = msg[:PV1].field(:attending_doctor).components        
        att.first =~ /^P?\d+/ && HL7Test.is_name?(att[1..4]) && att[-1] =~ /\w+PROV$/
      }
      
      @failed = pass?( @messages, logic )
      @failed.should be_empty
    end

    it "has a valid patient class", :pattern => 'not a single-digit number' do
      logic = Proc.new{ |msg| msg[:PV1].patient_class !~ /^\d{1}$/ }
      @failed = pass?( @messages, logic )
      @failed.should be_empty
    end

    it "has a valid Patient Type", :pattern => 'one or two digits' do
      logic = Proc.new{ |msg| msg[:PV1].patient_type =~ /^\d{1,2}$/ }
      @failed = pass?( @messages, logic )
      @failed.should be_empty
    end

    it "does not have a VIP Indicator", :pattern => 'PV1.16 is empty' do
      logic = Proc.new{ |msg| msg[:PV1][16].empty? }
      @failed = pass?( @messages, logic )
      @failed.should be_empty
    end
  end

  after(:each) do
    log_result( @failed, example )
  end
end