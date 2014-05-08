require 'comparer/spec_helper'
require 'working_folder/mixins/comparison_result'

describe ComparisonResult do
  before(:all) do
    ComparisonResult.set_counts(100, 50, [22], [43])
  end
  
  describe "@record_count" do
    it "has a total number of records" do
      expect(ComparisonResult.record_count).to eq(100)
    end
  end
  
  describe "@criteria_count" do
    it "has a total number of criteria" do
      expect(ComparisonResult.criteria_count).to eq(50)
    end
  end
  
  describe "@subset_record_counts" do
    it "has the size of the record subset" do
      expect(ComparisonResult.subset_record_counts).to eq([22])
    end
  end
  
  describe "@matched_criteria_counts" do
    it "has the number of matched criteria for all files" do
      expect(ComparisonResult.matched_criteria_counts).to eq([43])
    end
  end
    
  context "when there is more than one file" do
    before(:all) do
      ComparisonResult.set_counts(100, 50, [56, 78], [44, 42])
    end
    
    it "has a matched_criteria_size and subset_size for each file" do
      expect(ComparisonResult.matched_criteria_counts.size).to eq(2)
      expect(ComparisonResult.subset_record_counts.size).to eq(2)
    end
    
    describe "#subset_size" do
      it "returns the first value in subset_sizes" do
        expect(ComparisonResult.subset_record_count).to eq(56)
      end
    end
    
    describe "#matched_criteria_size" do
      it "returns the first value in matched_criteria_sizes" do
        expect(ComparisonResult.matched_criteria_count).to eq(44)
      end
    end
    
    describe "#subset_sizes" do
      it "returns all subset sizes" do
        expect(ComparisonResult.subset_record_counts).to eq([56, 78])
      end
    end
    
    describe "#matched_criteria_sizes" do
      it "returns all matched criteria sizes" do
        expect(ComparisonResult.matched_criteria_counts).to eq([44, 42])
      end
    end
  end
  
  describe "#to_hash" do
    it "returns the counts as a hash" do
      counts_hash = { record_count:100, criteria_count:50, subset_size:56, matched_criteria:44 }
      expect(ComparisonResult.to_hash).to eq(counts_hash)
    end
  end
  
  describe "#reset" do
    before(:all) do
      ComparisonResult.reset
    end

    it "resets @record_count to 0" do
      expect(ComparisonResult.record_count).to eq(0)      
    end
    
    it "resets @criteria_count to 0" do
      expect(ComparisonResult.criteria_count).to eq(0)      
    end
    
    it "resets @subset_record_counts to []" do
      expect(ComparisonResult.subset_record_counts).to eq([])      
    end
    
    it "resets @matched_criteria_counts to []" do
      expect(ComparisonResult.matched_criteria_counts).to eq([])      
    end            
  end
  
  describe "#set_counts" do
    before(:all) do
      ComparisonResult.set_counts(100, 200, [300], [400])
    end

    it "resets @record_count to the first argument" do
      expect(ComparisonResult.record_count).to eq(100)      
    end
    
    it "resets @criteria_count to the second argument" do
      expect(ComparisonResult.criteria_count).to eq(200)      
    end
    
    it "resets @subset_record_counts to the third argument" do
      expect(ComparisonResult.subset_record_counts).to eq([300])      
    end
    
    it "resets @matched_criteria_counts to the fourth argument" do
      expect(ComparisonResult.matched_criteria_counts).to eq([400])      
    end
  end
end