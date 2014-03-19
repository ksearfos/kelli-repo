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

  # == MSH tests
  it_behaves_like "MSH segment" do
    let(:message){ @messages }
  end

  # == ORC tests
  context "ORC segment" do
    it "has a Control ID of two characters" do
      logic = Proc.new{ |msg| msg[:ORC].order_control.size == 2 }
      @failed = pass?( @messages, logic )
      @failed.should be_empty
    end
  end

  # == OBR tests    
  context "OBR segment" do
    it_behaves_like "OBR segment" do
      let(:message){ @messages }
    end

    it "has a valid procedure ID", :pattern => 'capital letters + numbers' do
      logic = Proc.new{ |msg|
        msg[:OBR].each{ |obr| obr.field(:procedure_id)[1] =~ /^[A-Z0-9]+/ }
      }
      @failed = pass?( @messages, logic )
      @failed.should be_empty
    end

    it "has the same observation date and result status date" do
      logic = Proc.new{ |msg|
        msg[:OBR].each{ |obr| obr.field(:result_date_time).as_date == obr.field(:observation_date_time).as_date }
      }
      @failed = pass?( @messages, logic )
      @failed.should be_empty
    end
  end 

  # == OBX tests
  context "OBX segment" do
    it "has the correct component ID", :pattern => 'LA01' do
      logic = Proc.new{ |msg|
        msg[:OBX].each{ |obx| obx.field(:component_id)[-1] == 'LA01' }
      }
      @failed = pass?( @messages, logic )
      @failed.should be_empty
    end

    it "has an observation value of the appropriate type" do
      logic = Proc.new{ |msg|
        msg[:OBX].each{ |obx| HL7Test.has_correct_format?(obx.value,obx.value_type) }
      }
      @failed = pass?( @messages, logic )
      @failed.should be_empty
    end
    
    context "with value type of SN or NM" do
      it "has valid Units" do
        logic = Proc.new{ |obx|
          if obx.type[0] != 'T'   # not a TX or TS, e.g. a NM or SN
            u = obx.units
            u.empty? || HL7Test::UNITS.include?(u)
          end
        }
        @failed = pass_for_each?( @messages, logic, :OBX )
        @failed.should be_empty
      end

          it "has a valid reference range", :pattern => "number - number" do
            range = obx.reference_range
            nums = range.split('-')
            
            nums.size.should eq 2
            HL7Test.is_numeric?(nums.first).should be_true
            HL7Test.is_numeric?(nums.last).should be_true
                  logic = Proc.new{ |msg|
        msg[:OBR].each{ |obr| obr.field(:procedure_id)[1] =~ /^[A-Z0-9]+/ }
      }
      @failed = pass?( @messages, logic )
      @failed.should be_empty
          end

          it "has a valid Abnormal Flag" do
            flag = obx.abnormal_flag
            HL7Test::ABNORMAL_FLAGS.should include flag unless flag.empty?
                  logic = Proc.new{ |msg|
        msg[:OBR].each{ |obr| obr.field(:procedure_id)[1] =~ /^[A-Z0-9]+/ }
      }
      @failed = pass?( @messages, logic )
      @failed.should be_empty
          end
        end #if
      end #context - SN or NM
    end #each
  end

  # == PID tests
  context "PID segment" do
    include_examples "PID segment", msg[:PID] 
  end

  # == PV1 tests
  context "PV1 segment" do
    pv1 = msg[:PV1]
    include_examples "PV1 and PID segments", pv1, msg[:PID]
    include_examples "Lab/ADT PV1 segment", pv1

    it "has a valid attending doctor", :pattern => 'begins with an optional P + digits, ends with (something)PROV' do
      att = pv1.field(:attending_doctor).components
      att.first.should =~ /^P?\d+/

      HL7Test.is_name?(att[1..4]).should be_true
      att[-1].should =~ /\w+PROV$/
    end

    it "has a valid patient class", :pattern => 'not a single-digit number' do
      pv1.patient_class.should_not =~ /^\d{1}$/
    end

    it "has a valid Patient Type", :pattern => 'one or two digits' do
      pv1.patient_type.should =~ /^\d{1,2}$/
    end

    it "does not have a VIP Indicator", :pattern => 'PV1.16 is empty' do
      pv1[16].should be_empty
    end
  end

  after(:each) do
    log_result( @failed, example )
  end
end