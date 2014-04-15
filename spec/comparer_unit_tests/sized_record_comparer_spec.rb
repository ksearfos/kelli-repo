# passed testing 4/15
$LOAD_PATH.unshift File.dirname(__FILE__)
require 'spec_helper'
require 'shared_examples'
require 'spec/mixin_unit_tests/size_restrictable_spec'

describe RecordComparer do
  before(:each) do
    mock_list = double("mock_list")
    mock_list.stub(:find_redundancies) { [$redundant_record, $duplicate_record] } 
    mock_list.stub(:maps) { $all_records }
    mock_list.stub(:matched_criteria) { $criteria }
    @comparer = SizedRecordComparer.new(mock_list)
  end
    
  it_behaves_like RecordComparer do
    let(:comparer) { @comparer }
  end

  it_behaves_like SizeRestrictable do
    let(:object) { @comparer }
  end

  context "extends RecordComparer functionality" do
    describe "#reset" do
      it "also sets the minimum size to 1" do   
        @comparer.reset
        expect(@comparer.minimum_size).to eq(1)
      end
    end
  
    describe "#analyze" do
      it "also chooses random records until minimum size is reached" do
        expect(@comparer).to receive(:supplement)
        @comparer.analyze
      end
    end
  end
   
end