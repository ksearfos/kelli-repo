$LOAD_PATH.unshift File.expand_path("../../..", __FILE__)   # project directory
$LOAD_PATH.unshift File.dirname(__FILE__)
require 'spec_helper'
require 'shared_examples'

describe "RecordComparer" do

  before(:all) do
    @comparer = RecordComparer.new($messages.values, $criteria)
  end
  
  it_behaves_like "any RecordComparer" do
    let(:comparer){ @comparer }
  end
  
  describe "#analyze" do
    before(:each) do
      @remaining = @comparer.chosen
    end
    
    context "when a small number of records is acceptable" do
      it "removes records chosen at random" do
        removal_is_random.should be_true        
      end
      
      context "the entire function" do
        before(:all) do
          @comparer.reset
          @comparer.analyze
        end    
        
        it "removes records chosen at random" do
          removal_is_random.should be_true
        end
      end #context - the entire function
    end #context - a small number of records
  end #describe - analyze
end #describe - class