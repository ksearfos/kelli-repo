# passed testing 4/16
$LOAD_PATH.unshift File.expand_path('../..',__FILE__)   # mixins directory
require 'spec_helper'

describe SeriesNonseriesEvaluation do
  before(:each) do
    @ratio = SeriesNonseriesEvaluation::SERIES_RATIO
    @series_proc = SeriesNonseriesEvaluation::SERIES_IDENTIFIER
    @proportion = SeriesNonseriesEvaluation::SERIES_PROPORTION
    @evaluator = SeriesNonseriesEvaluation.make_new_evaluator([])
    @series_record = double
    @series_record.stub(:series?) { true }
    @nonseries_record = double
    @nonseries_record.stub(:series?) { false }
  end
  
  describe "::SERIES_RATIO" do
    it "is 0.02", :detail => "2%" do
      expect(@ratio).to eq(0.02)
    end
  end
  
  describe "::SERIES_IDENTIFER" do
    it "is executable code" do
      expect(@series_proc).to be_a Proc
    end
    
    it "is true for series records" do   
      expect(@series_proc.call(@series_record)).to be_true
    end
    
    it "is false for nonseries records" do
      expect(@series_proc.call(@nonseries_record)).to be_false
    end
  end  

  describe "::SERIES_PROPORTION" do
    it "is a Proportion" do
      expect(@proportion).to be_a ProportionEvaluation::Proportion
    end
    
    it "has a ratio equal to the series ratio" do
      expect(@proportion.ratio).to eq(@ratio)
    end
    
    it "can identify series elements" do
      expect(@proportion.identify_elements([@series_record, @nonseries_record])).to eq([@series_record])
    end
  end

  describe "::make_new_evaluator" do
    it "returns a new Evaluator" do
      expect(@evaluator).to be_a ProportionEvaluation::Evaluator
    end
    
    it "makes an Evaluator that looks at Series record distribution" do
      expect(@evaluator.distribution).to eq(@proportion)
    end
  end
end