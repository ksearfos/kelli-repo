# passed testing 4/7
$LOAD_PATH.unshift File.expand_path("../../..", __FILE__)   # project directory
$LOAD_PATH.unshift File.dirname(__FILE__)
require 'spec_helper'
require 'shared_examples'

describe "RecordComparer" do

  before(:all) do
    @comparer = RecordComparer.new($messages.values, $criteria)
  end
  
  it_behaves_like "RecordComparer" do
    let(:comparer){ @comparer }
  end
 
  describe "#analyze" do
    before(:all) do
      @comparer.reset
      @comparer.analyze
    end
    
    it "returns the smallest statistically-significant subset of records" do
      used = @comparer.chosen
      used.should include $messages["Smith^John^W"]
      used.should_not include $messages["Palmer^Lois^REDUNDANT"]
      should_only_use_one_of_the_duplicates(used)
    end
  end
end