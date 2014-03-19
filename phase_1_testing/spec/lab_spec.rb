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
    let(:messages){ @messages }
  end

  # == MSH tests
  context "MSH segment" do
    it_behaves_like "a normal MSH segment" do
      let(:messages){ @messages }
    end
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
  context "OBR segments" do
    it_behaves_like "normal OBR segments" do
      let(:messages){ @messages }
    end

    it "have a valid procedure ID", :pattern => 'capital letters + numbers' do
      logic = Proc.new{ |obr| obr.field(:procedure_id).first =~ /[A-Z0-9]+/ }
      @failed = pass_for_each?( @messages, logic, :OBR )
      @failed.should be_empty
    end

    it "have the same observation date and result status date" do
      logic = Proc.new{ |obr| obr.field(:result_date_time).as_date == obr.field(:observation_date_time).as_date }
      @failed = pass_for_each?( @messages, logic, :OBR )
      @failed.should be_empty
    end
  end 

  # == OBX tests
  context "OBX segments" do
    it "have the correct component ID", :pattern => 'LA01' do
      logic = Proc.new{ |obx| obx.field(:component_id)[-1] == 'LA01' }
      @failed = pass_for_each?( @messages, logic, :OBX )
      @failed.should be_empty
    end

    it "has an observation value of the appropriate type" do
      logic = Proc.new{ |obx| HL7Test.has_correct_format?(obx.value,obx.value_type) }
      @failed = pass_for_each?( @messages, logic, :OBX )
      @failed.should be_empty
    end
    
    context "with SN or NM values" do
      it "have valid Units" do
        logic = Proc.new{ |obx|
          if obx.type[0] == 'T'   # not a TX or TS, e.g. a NM or SN
            true
          else
            u = obx.units
            u.empty? || HL7Test::UNITS.include?(u)
          end
        }
        @failed = pass_for_each?( @messages, logic, :OBX )
        @failed.should be_empty
      end

      it "have a valid reference range", :pattern => "number - number" do
        logic = Proc.new{ |obx|
          if obx.type[0] == 'T'   # not a TX or TS, e.g. a NM or SN
            true
          else
            range = obx.reference_range
            nums = range.split('-')
            nums.size == 2 && HL7Test.is_numeric?(nums.first) && HL7Test.is_numeric?(nums.last)
          end
        }
        @failed = pass_for_each?( @messages, logic, :OBX )
        @failed.should be_empty
      end

      it "have a valid Abnormal Flag" do
        logic = Proc.new{ |obx|
          if obx.type[0] == 'T'   # not a TX or TS, e.g. a NM or SN
            true
          else
           flag = obx.abnormal_flag
           flag.empty? || HL7Test::ABNORMAL_FLAGS.include?(flag)
          end    
        }
        @failed = pass_for_each?( @messages, logic, :OBX )
        @failed.should be_empty
      end
    end #context - SN or NM
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
    
    it_behaves_like "a PV1 segment in Lab/ADT messages" do
      let(:messages){ @messages }
    end

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

    it "does not have a VIP Indicator" do
      logic = Proc.new{ |msg| msg[:PV1][16].empty? }
      @failed = pass?( @messages, logic )
      @failed.should be_empty  
    end
  end

  after(:each) do
    log_result( @failed, example )
  end
end