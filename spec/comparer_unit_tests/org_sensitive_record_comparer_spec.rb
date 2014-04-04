$LOAD_PATH.unshift File.expand_path("../../..", __FILE__)   # project directory
$LOAD_PATH.unshift File.dirname(__FILE__)
require 'spec_helper'
require 'shared_examples'

describe "OrgSensitiveRecordComparer" do

  before(:all) do
    @comparer = OrgSensitiveRecordComparer.new($messages.values, $criteria)
  end
  
  it_behaves_like "a generic RecordComparer" do
    let(:comparer){ @comparer }
  end
 
  context "redundant records exist" do
    before(:all) do
      @comparer.reset
    end
      
    context "records are removed and added strategically" do           
      it "chooses which records to remove based on organization distribution" do
        @comparer.call_remove_records with duplicate criteria
        @comparer.chosen.should_not include $messages["Palmer^Lois^DUPLICATE"]  # a series record
      end  

      it "chooses supplemental records based on organizational distribution" do
        @comparer.minimum_size = 3
        @comparer.call_unchoose($messages["Palmer^Lois^REDUNDANT"],$messages["Palmer^Lois^DUPLICATE"])
        @comparer.call_supplement_chosen
        @comparer.chosen.should_not include $messages["Palmer^Lois^REDUNDANT"]  # a nonseries record
      end 
      
      describe "#fix_proportions" do
        it "tries to returns a data set that matches the desired distribution" do
          @comparer.analyze
          @comparer.fix_proportions
          @comparer.chosen.size.should eq 3
          @comparer.chosen.should_not include $messages["Palmer^Lois^REDUNDANT"]
        end
      end
    end
  end
  
end