require 'shared_examples'
require 'hl7_spec_helper'

describe "OhioHealth Lab record" do
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
  
  it_behaves_like "lab and rad records" do
    let(:messages){ @messages }
  end  

  context "when converted to HL7" do  
    it "has the correct message processing ID", :pattern => "P for MGH, T otherwise" do
      logic = Proc.new{ |msg| 
        msh = msg.header
        prid = msh.processing_id
        msh[3] == 'MGH' ? prid == 'P' : prid == 'T'
      }
      @failed = pass?( @messages, logic )
      @failed.should be_empty      
    end
         
    it "has the correct HL7 version", :pattern => "2.3 for MGH, 2.4 otherwise" do
      logic = Proc.new{ |msg| 
        msh = msg.header
        vsn = msh.version
        msh[3] == 'MGH' ? vsn == '2.3' : vsn == '2.4'
      }
      @failed = pass?( @messages, logic )
      @failed.should be_empty      
    end
  end

  context "the order" do
    it "has a valid control ID", :pattern => "RE, for order [re]sults" do
      logic = Proc.new{ |msg| msg[:ORC].order_control == 'RE' }
      @failed = pass?( @messages, logic )
      @failed.should be_empty
    end
  end
   
  context "order request" do
    it "has a valid specimen source",
    :pattern => 'all letters, but only required if there are results' do
      logic = Proc.new{ |msg|
        obx = msg[:OBX]
        return true if obx.nil?
        msg[:OBR].specimen_source !~ /[^A-z]/
      }
      @failed = pass?( @messages, logic )
      @failed.should be_empty
    end
  end 

  context "observation/results" do
    it "have a valid component ID", :pattern => "ends with LA01" do
      logic = Proc.new{ |obx| obx.field(:component_id).last == 'LA01'
      }
      @failed = pass_for_each?( @messages, logic, :OBX )
      @failed.should be_empty
    end

    it "has an observation value of the correct type",
    :pattern => "either numeric, structured numeric, textual, or a timestamp" do
      logic = Proc.new{ |obx| HL7.has_correct_format?(obx.value,obx.value_type) }
      @failed = pass_for_each?( @messages, logic, :OBX )
      @failed.should be_empty
    end
    
    list = HL7::RESULT_STATUS
    it "has a valid result status", :pattern => "one of #{list.join(', ')}" do
      logic = Proc.new{ |obx| list.include? obx.result_status }
      @failed = pass_for_each?( @messages, logic, :OBX )
      @failed.should be_empty
    end
    
    context "with discrete values" do   # NM/SN types
      discrete = ['NM','SN']
      
      it "have valid Units" do
        logic = Proc.new{ |obx|
          discrete.include?(obx.type) ? HL7::UNITS.include?(obx.units) : true
        }
        @failed = pass_for_each?( @messages, logic, :OBX )
        @failed.should be_empty
      end

      it "have valid reference ranges", :pattern => "a numeric range, e.g. 'X-Y'" do
        logic = Proc.new{ |obx|
          if discrete.include?(obx.type)
            range = obx.reference_range
            nums = range.split('-')
            nums.size == 2 && HL7.is_numeric?(nums.first) && HL7.is_numeric?(nums.last)
          else
            true
          end
        }
        @failed = pass_for_each?( @messages, logic, :OBX )
        @failed.should be_empty
      end

      it "have valid Abnormal Flags" do
        logic = Proc.new{ |obx|
          if discrete.include?(obx.type)
            HL7::ABNORMAL_FLAGS.include? obx.abnormal_flag
          else
            true
          end  
        }
        @failed = pass_for_each?( @messages, logic, :OBX )
        @failed.should be_empty
      end
    end
  end

  after(:each) do
    log_result( @failed, example )
  end
end