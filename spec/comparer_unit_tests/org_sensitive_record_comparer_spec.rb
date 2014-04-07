# passed testing 4/7
$LOAD_PATH.unshift File.expand_path("../../..", __FILE__)   # project directory
$LOAD_PATH.unshift File.dirname(__FILE__)
require 'spec_helper'
require 'shared_examples'

describe "OrgSensitiveRecordComparer" do

  before(:all) do
    @comparer = OrgSensitiveRecordComparer.new($messages.values, $criteria)
  end
  
  it_behaves_like "RecordComparer" do
    let(:comparer){ @comparer }
  end
 
  context "redundant records exist" do
    before(:all) do
      @comparer.reset
    end
      
    context "records are removed and added strategically" do           
      it "chooses which records to remove based on organization distribution" do
        @comparer.call_remove_records_with_duplicate_criteria
        @comparer.chosen.should_not include $messages["Palmer^Lois^DUPLICATE"]  # a series record
      end  

      it "chooses supplemental records based on organizational distribution" do
        @comparer.minimum_size = 3
        @comparer.call_unchoose($messages["Palmer^Lois^REDUNDANT"],$messages["Palmer^Lois^DUPLICATE"])
        @comparer.call_supplement_chosen
        @comparer.chosen.should_not include $messages["Palmer^Lois^REDUNDANT"]  # a nonseries record
      end 
    end  
  end
    
  describe "#fix_proportions" do
    before(:all) do
      @comparer.reset
      @comparer.analyze
    end
    
    it "tries to return a data set that matches the desired distribution" do
      @comparer.fix_proportions
      used = @comparer.chosen
      used.should include $messages["Smith^John^W"]
      used.should include $messages["Palmer^Lois^G"]
      used.should include $messages["Palmer^Lois^DUPLICATE"]      
      used.should_not include $messages["Palmer^Lois^REDUNDANT"]
    end
  end
  
  describe "#analyze" do   
    before(:all) do
      @comparer.reset
      @comparer.analyze
    end
    
    it "returns the smallest statistically-significant subset of records" do
      used = @comparer.chosen
      used.should include $messages["Smith^John^W"]
      used.should include $messages["Palmer^Lois^G"]
      used.should_not include $messages["Palmer^Lois^REDUNDANT"]
      used.should_not include $messages["Palmer^Lois^DUPLICATE"]
    end
  end
end