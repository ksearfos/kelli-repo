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
  context "ORC segment", :pattern => 'any two characters' do
    it "has a Control ID of two characters" do
      $message[:ORC].order_control.size.should == 2
    end
  end

  # == OBR tests    
  context "OBR segment" do
    $message[:OBR].each do |obr|
      include_examples "OBR segment", obr

      it "has a valid procedure ID", :pattern => 'begins with capital letters/numbers and ends with ECAREEAP or OHHOREAP' do
        obr.procedure_id[1].should =~ /^[A-Z0-9]+/
        obr.procedure_id[-1].should == ( $message[:MSH][3] =~ /MGH/ ? 'ECAREEAP' : 'OHHOREAP' )
      end

      it "has the same observation date and result status date", :pattern => '' do
        obr.results_date_time.as_date.should == obr.observation_date_time_as_date
      end
    end #each
  end 

  # == OBX tests
  context "OBX segment" do
    
    before(:each) do
      @obx = $message[:OBX]
    end

    it "has Component Id in the correct format", :pattern => 'LA01' do
      comp_ids = @obx.all_fields[component_id]
      comp_ids.each{ |id| id[-1].should == 'LA01'  }
    end

    it "has an observation value of the appropriate type", :pattern => 'type is listed in OBX.2' do
      vals = @obx.all_fields(:value)
      types = @obx.all_fields(:value_type)
      
      for i in (0...vals.size)
        HL7Test.has_correct_format?(vals[i],types[i]).should be_true
      end
    end

      context "with value type of SN or NM" do
        if obx.value_type != 'TX'
          it "has valid Units", :pattern => '' do
            HL7Test::UNITS.should include obx.units
          end

          it "has a valid reference range", :pattern => '' do
            range = obx.reference_range
            nums = range.split('-')
            
            nums.size.should eq 2
            HL7Test.is_numeric?(nums.first).should be_true
            HL7Test.is_numeric?(nums.last).should be_true
          end

          it "has a valid Abnormal Flag", :pattern => '' do
            HL7Test::ABNORMAL_FLAGS.should include obx.abnormal_flag
          end
        end #if
      end #context - SN or NM
    # end #each
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

    it "has a valid attending doctor", :pattern => 'begins with an optional P + digits, ends with something-PROV' do
      att = pv1.attending_doctor
      att[0].should =~ /^P?\d+/
      HL7Test.is_name?(att[1..3]).should be_true
      att[-1].should =~ /\w+PROV$/
    end

    it "has a valid patient class", :pattern => 'not a single-digit number' do
      pv1.patient_class.should !~ /^\d{1}$/
    end

    it "has a valid Patient Type", :pattern => 'one or two digits' do
      pv1.patient_type.should =~ /^\d{1,2}$/
    end

    it "does not have a VIP Indicator", :pattern => '' do
      pv1[16].should be_empty
    end
  end

end