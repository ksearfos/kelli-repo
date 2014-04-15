$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'spec_helper'
require 'chooseable_spec'

describe RecordCriteriaMap do
  before(:all) do
	  @map = RecordCriteriaMap.new(nil, $criteria_with_procs)
	end
	
  it "has a record" do
    expect(@map).to respond_to :record
  end
  
  it "knows which criteria are matched" do
    expect(@map.criteria).to eq($criteria)
  end
  
  it_behaves_like Chooseable do
    let(:object) { @map }
  end
end