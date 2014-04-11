$:.unshift(File.dirname(__FILE__))
require 'spec_helper'

describe RecordCriteriaMap do
	let(:map) { TestRecordCriteriaMap.new(criteria) }
	let(:duplicate_map) { TestRecordCriteriaMap.new(duplicate_criteria) }
	let(:better_map) { TestRecordCriteriaMap.new(all_criteria) }
	let(:different_map) { TestRecordCriteriaMap.new(redundant_criteria) }
	
  it "has a record" do
    expect(map).to respond_to :record
  end
  
  it "knows which criteria are matched" do
    expect(map.criteria).to eq(criteria.to_set)
  end
  
  describe "#==" do
    it "identifies RecordCriteriaMaps with identical criteria" do
      expect(map).to eq(duplicate_map)
    end
  end
  
  describe "#duplicated_by?" do
    it "is the same as #==" do
      expect(map).to be_duplicated_by duplicate_map
    end
  end
  
  describe "#made_redundant_by?" do
    context "when another map's criteria are identical" do
      it "is true" do
        expect(map).to be_made_redundant_by duplicate_map
      end
    end
    
    context "when another map's criteria contain this map's criteria" do
      it "is true" do
        expect(map).to be_made_redundant_by better_map
      end
    end
    
    context "when other criteria are different" do
      it "is false" do
        expect(map).not_to be_made_redundant_by different_map   
      end
    end  
  end
end