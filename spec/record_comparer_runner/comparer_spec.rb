$LOAD_PATH.unshift File.dirname(__FILE__)
require 'spec_helper'

describe Comparer do
  before(:each) do
    files = %w(file1.txt file2.txt file3.txt)
    Comparer.any_instance.stub(:search_records)
    Comparer.any_instance.stub(:get_records).and_return([1], [2], [3], []) 
    @comparer = Comparer.new(files)
  end
  
  it "has a list of records" do
    expect(@comparer.records).not_to be_nil  
  end
  
  it "analyzes the records" do    
    expect { @comparer.analyze }.not_to raise_exception  
  end
  
  describe "#analyze" do       
    it "searches all of the records available" do
      @comparer.analyze
      expect(@comparer.records).to be_empty
    end

    it "looks for the smallest, most diverse subset of records" do    
      @comparer.should_receive(:search_records).at_least(1).times
      @comparer.analyze
    end
      
    it "returns the best subset" do
      expect(@comparer.analyze).to be_a Array
    end
    
    context "when the records are broken into groups" do
      it "searches each of the groups independently" do 
        @comparer.should_receive(:search_records).exactly(3).times
        @comparer.analyze
      end
    end
  end
end