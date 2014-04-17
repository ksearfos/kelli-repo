# passed testing 4/15
$LOAD_PATH.unshift File.dirname(__FILE__)
require 'spec_helper'
require 'shared_examples'
require 'spec/mixin_unit_tests/size_restrictable_spec'

describe ProportionateRecordComparer do
  before(:each) do
    mock_list = double("mock_list")
    mock_list.stub(:find_redundancies) { [$redundant_record, $duplicate_record] } 
    mock_list.stub(:maps) { $all_records }
    mock_list.stub(:matched_criteria) { $criteria }
    @mock_evaluator = double("mock_evaluator")
    @mock_evaluator.stub(:evaluate_up_to_limit) { [$series_record] }
    @mock_evaluator.stub(:take) { [$series_record] }
    @comparer = ProportionateRecordComparer.new(mock_list)
  end
    
  it_behaves_like RecordComparer do
    let(:comparer) { @comparer }
  end

  it_behaves_like SizeRestrictable do
    let(:object) { @comparer }
  end
  
  it_behaves_like SizedRecordComparer do
    let(:comparer) { @comparer }
  end

  context "extends SizedRecordComparer functionality" do
    describe "#analyze" do
      it "supplements with records that improve the Series::Nonseries ratio" do
        @comparer.set_size(3)
        @comparer.analyze
        expect(@comparer.chosen).to include $series_record
      end
      
      it "also adds extra records to improve the Series::Nonseries ratio" do
        expect(@comparer).to receive(:fix_proportions)
        @comparer.analyze
      end
    end   
  end
end