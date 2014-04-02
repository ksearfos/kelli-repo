require 'shared_examples'
require 'spec_helper'

describe "OhioHealth Rad record" do
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
  
  it_behaves_like "lab and rad records" do
    let(:messages){ @messages }
  end  

  context "when converted to HL7" do   
    it "has the correct HL7 version", :pattern => "2.3" do
      logic = Proc.new{ |msg| msg[:MSH].version == "2.3" }
      @failed = pass?( @messages, logic )
      @failed.should be_empty      
    end
    
    it "puts related segments next to each other" do
      logic = Proc.new{ |msg| msg.segment_before(:OBR) == :ORC }
      @failed = pass?( @messages, logic )
      @failed.should be_empty            
    end
  end
  
  context "the encounter" do 
    it "has the correct patient location", :pattern => "if there is one" do
      logic = Proc.new{ |msg|
        loc = msg[:PV1].field(:patient_location)
        loc[2] == 'E' ? loc[3] == 'ED' : true
      }
      @failed = pass?( @messages, logic )
      @failed.should be_empty      
    end
  end

  context "the order" do   # ORC segment
    it "has a valid transaction date and time" do
      logic = Proc.new{ |msg| HL7.is_datetime? msg[:ORC].transaction_date_time }
      @failed = pass?( @messages, logic )
      @failed.should be_empty
    end
    
    it "has a valid entering physician", :pattern => "if there is one" do
      logic = Proc.new{ |msg|
        phys = msg[:ORC].entered_by
        phys.empty? || is_physician?(phys)
      }
      @failed = pass?( @messages, logic )
      @failed.should be_empty
    end    
  end

  context "the order request" do
    it "has a valid result interpreter" do      
      logic = Proc.new{ |msg| is_physician? msg[:OBR].ordering_provider }
      @failed = pass?( @messages, logic )
      @failed.should be_empty
    end
    
    it "has a valid assistant result interpreter", :pattern => "if there is one" do      
      logic = Proc.new{ |msg|
        phys = msg[:OBR][33]
        phys.empty? || is_physician?(phys)
      }
      @failed = pass?( @messages, logic )
      @failed.should be_empty
    end

    it "has an end exam date/time" do
      logic = Proc.new{ |msg|
        dt = msg[:OBR][27]
        dt.empty? || HL7.is_datetime?(dt)
      }
      @failed = pass?( @messages, logic )
      @failed.should be_empty
    end
  end

  context "the observation/results" do
    it "are not discrete", :pattern => "TX value type" do
      logic = Proc.new{ |obx| obx.value_type == 'TX' }
      @failed = pass_for_each?( @messages, logic, :OBX )
      @failed.should be_empty
    end

    list = OHProcs::RAD_OBS_IDS
    it "have valid component IDs",
    :pattern => "one of #{list.join(', ')}, corresponding to the value" do        
      logic = Proc.new{ |obx| 
        comp = obx.component_id
        val = obx.value
        
        if val.include?("IMPRESSION:") then comp == '&IMP'
        elsif val.include?("ADDENDUM:") then comp == '&ADT'
        else list.include?(comp)
        end
      }
      @failed = pass_for_each?( @messages, logic, :OBX )
      @failed.should be_empty
    end   
  end
  
  after(:each) do
    log_result( @failed, example )
  end
end