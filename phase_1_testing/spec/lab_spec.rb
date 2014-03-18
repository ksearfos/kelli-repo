require 'shared_examples'
require 'spec_helper'

describe "Ohio Health Lab HL7" do
    
  # == General message tests
  include_examples "General", $message

  # == MSH tests
  context "MSH segment" do
    msh = $message.header    
    include_examples "MSH segment", msh
  end

  # == ORC tests
  context "ORC segment" do
    it "has a Control ID of two characters" do
      $message[:ORC].order_control.size.should == 2
    end
  end

  # == OBR tests    
  context "OBR segment" do
    $message[:OBR].each do |obr|
      include_examples "OBR segment", obr

      it "has a valid procedure ID", :pattern => 'capital letters + numbers' do
        proc_id = obr.field(:procedure_id)      
        proc_id[1].should =~ /^[A-Z0-9]+/
      end

      it "has the same observation date and result status date", :pattern => 'OBR.7 == OBR.22' do
        obr.field(:result_date_time).as_date.should == obr.field(:observation_date_time).as_date
      end
    end #each
  end 

  # == OBX tests
  context "OBX segment" do
    $message[:OBX].each do |obx|
      
      it "has the correct component ID", :pattern => 'LA01' do
        obx.field(:component_id)[-1].should == 'LA01'
      end

      it "has an observation value of the appropriate type", :pattern => "a #{obx.value}" do
        HL7Test.has_correct_format?(obx.value,obx.value_type).should be_true
      end
    
      context "with value type of SN or NM" do
        if obx.value_type != 'TX'
          it "has valid Units", :pattern => "OBX.6" do
            u = obx.units
            HL7Test::UNITS.should include u unless u.empty? 
          end

          it "has a valid reference range", :pattern => "OBX.7" do
            range = obx.reference_range
            nums = range.split('-')
            
            nums.size.should eq 2
            HL7Test.is_numeric?(nums.first).should be_true
            HL7Test.is_numeric?(nums.last).should be_true
          end

          it "has a valid Abnormal Flag", :pattern => "OBX.8" do
            flag = obx.abnormal_flag
            HL7Test::ABNORMAL_FLAGS.should include flag unless flag.empty?
          end
        end #if
      end #context - SN or NM
    end #each
  end

  # == PID tests
  context "PID segment" do
    include_examples "PID segment", $message[:PID] 
  end

  # == PV1 tests
  context "PV1 segment" do
    pv1 = $message[:PV1]
    include_examples "PV1 and PID segments", pv1, $message[:PID]
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
    flag_example_exception( example, $message ) if example.exception   # store specifics for future logging
  end
end