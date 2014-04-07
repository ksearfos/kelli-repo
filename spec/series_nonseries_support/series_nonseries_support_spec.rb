# passed testing 4/7
$LOAD_PATH.unshift File.expand_path("../../..", __FILE__)   # project directory
$LOAD_PATH.unshift File.dirname(__FILE__)
require 'spec_helper'
require 'series_nonseries_shared.rb'

describe "SeriesNonseriesSupport" do
  
  before(:all) do
    @records = $messages.values
    @series_record = $messages["Palmer^Lois^DUPLICATE"]
    messages = $messages.clone
    messages.delete("Palmer^Lois^DUPLICATE")
    @nonseries_records = messages.values
  end
  
  describe "HL7::Message#series?" do
    it "determines whether record is a series record" do
      @series_record.should be_series
      @nonseries_records.first.should_not be_series
    end
  end
  
  context "series records" do
    it_behaves_like "SeriesNonseriesSupport" do
      let(:type) { :series }
    end
  end
  
  context "nonseries records" do
    it_behaves_like "SeriesNonseriesSupport" do
      let(:type) { :nonseries }
    end
  end
  
  describe "#series_proportion" do
    it "finds the number of series records, as a percentage of all records" do 
      SeriesNonseriesSupport.series_proportion(@records).should == 0.25
    end
  end
  
  describe "#needed_type" do
    it "determines which type of record to add to even out the proportions" do
      SeriesNonseriesSupport.needed_type(@records).should eq :nonseries
      SeriesNonseriesSupport.needed_type(@nonseries_records).should eq :series 
    end
  end

end