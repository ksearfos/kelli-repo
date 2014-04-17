$LOAD_PATH.unshift File.dirname(__FILE__)
require 'spec_helper'
require 'shared_examples'

describe RecordComparerRunner do
  before(:all) do
    @type = :lab
    @runner = RecordComparerRunner.new(@type)
  end
  
  it_behaves_like TestRunner do
    let(:record_type) { @type }
    let(:runner) { @runner }
  end
  
  it "has a list of files to compare" do
    expect(@runner.files).to be_a Array
  end
  
  it "runs the comparison" do
    expect(@runner).to respond_to(:run)
  end
  
  it "saves the results of the comparison" do
    expect(@runner).to respond_to(:save_results)
  end

end