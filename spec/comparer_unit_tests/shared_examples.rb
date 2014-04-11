shared_examples "RecordComparer" do
  
  it "has a list of records" do
    expect(comparer.records_and_criteria.keys).not_to be_empty
  end
  
  it "has a list of criteria" do
    expect(comparer.records_and_criteria.values).not_to be_empty
  end
  
  it "connects a record to all criteria matched" do
    record = $messages["Palmer^Lois^G"]
    expect(comparer.records_and_criteria[record]).to eq([:obx_sodium, :obx_chloride, :female])
  end
  
  describe "#reset" do
    before(:each) do
      comparer.analyze   # make sure things actually got changed!
      comparer.reset
    end
    
    it "chooses all records" do     
      expect(comparer.used_records.size).to eq(comparer.records_and_criteria.size)
    end
    
    it "has no unused records" do
      expect(comparer.unused_records).to be_empty
    end
    
    it "sets the minimum size back to 1" do
      expect(comparer.minimum_size).to eq(1)
    end
  end 
  
  describe "#chosen" do    
    it "returns a list of the records chosen" do
      comparer.analyze
      expect(comparer.chosen).not_to be_empty
    end
  end

  describe "#matched" do
    it "returns a list of criteria that were matched" do
      expect(comparer.matched).not_to be_empty
    end
  end 

  describe "#unmatched" do
    it "returns a list of criteria that were not matched", :detail => "the descriptions, not the procs" do
      expect(comparer.unmatched).not_to be_empty
    end
  end 
  
  describe "#summary" do  
    it "indicates the number of matched criteria and records chosen" do
      summary = comparer.summary
      summary.should include "5 of 6 criteria"
      summary.should include "2 records"
    end
  end
  
  describe "#analyze" do
    before(:each) do
      comparer.reset
    end
    
    context "when all records are desired", :detail => "@minimum_size is big" do     
      it "uses all records" do
        comparer.minimum_size = $messages.size + 1
        comparer.analyze
        expect(comparer.chosen.size).to eq($messages.size)
      end      
    end
    
    context "when a small number of diverse results is desired", :detail => "@minimum_size is small" do 
      it "chooses the smallest number of records that meet all criteria" do
        comparer.analyze
        expect(comparer.chosen.size).to eq(2)
      end
    
      it "does not choose records that meet the same criteria" do
        comparer.analyze
        should_only_use_one_of_the_duplicates(@comparer.chosen)
      end
      
      it "does not choose records whose criteria are met elsewhere" do
        comparer.analyze
        expect(comparer.chosen).not_to include $messages["Palmer^Lois^REDUNDANT"]
      end
      
      it "ignores specific records" do
        records_to_avoid = [%w(04089927^^^STAR^^1 Palmer^Lois^DUPLICATE 19330102 A1134833697 46504 201112141232)]
        comparer.reset        
        comparer.records_to_avoid = records_to_avoid
        comparer.analyze
        expect(comparer.chosen).not_to include $messages["Palmer^Lois^DUPLICATE"]
      end
      
      it "supplements chosen records until the minimum size is met" do
        comparer.minimum_size = 3
        comparer.analyze
        expect(comparer.chosen.size).to eq(3) 
      end 
    end
  end
end