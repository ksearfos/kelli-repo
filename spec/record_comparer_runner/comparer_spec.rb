$LOAD_PATH.unshift File.dirname(__FILE__)
require 'spec_helper'

describe Comparer do
  before(:all) do
    @files = %w(file1.txt file2.txt file3.txt)
    @comparer = Comparer.new(@files)
  end
  
  it "has a list of records" do
    expect(@comparer.records).not_to be_nil  
  end
  
  it "analyzes the records" do
    @comparer.stub(:search_records) { [] }
    expect { @comparer.analyze }.not_to raise_exception  
  end
  
  describe "#analyze" do
    before(:each) do
      @comparer.stub(:search_records) { [] }
    end
    
    it "searches for the smallest, most diverse subset of records" do
      @comparer.should_receive(:search_records)
      @comparer.analyze
    end
 
    it "returns that subset" do
      expect(@comparer.analyze).to be_a Array
    end
  end
end