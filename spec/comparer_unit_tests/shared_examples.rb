shared_examples "RecordComparer" do
  
  describe "a new object" do
    it "connects a list of records to a list of criteria" do
      @comparer.should be_a RecordComparer
      @comparer.records_and_criteria.keys.should eq $messages.values
      @comparer.records_and_criteria.values.each { |criterion| criterion.should be_a Array }
    end
  
    it "connects a record to all criteria matched" do
      record = $messages["Palmer^Lois^G"]
      @comparer.records_and_criteria[record].should == [:obx_sodium, :obx_chloride, :female]
    end
  end
  
  describe "#reset" do
    before(:all) do
      @comparer.analyze   # make sure things actually got changed!
      @comparer.reset
    end
    
    it "sets the comparer to its original state" do     
      @comparer.used_records.size.should eq 4
      @comparer.unused_records.should be_empty
      @comparer.minimum_size.should eq 1
    end
  end 
  
  describe "#chosen" do
    before(:all) do
      @comparer.analyze
    end
    
    it "returns a list of the records chosen" do
      @comparer.chosen.each { |record| record.should be_a HL7::Message }
    end
  end

  describe "#matched" do
    it "returns a list of criteria that were matched" do
      @comparer.matched.should eq [:female, :male, :obx_chloride, :obx_potassium, :obx_sodium]
    end
  end 

  describe "#unmatched" do
    it "returns a list of criteria that were not matched", :detail => "the descriptions, not the procs" do
      @comparer.unmatched.should == [:obx_fake]
    end
  end 
  
  describe "#summary" do  
    it "indicates the number of matched criteria and records chosen" do
      summary = @comparer.summary
      summary.should include "5 of 6 criteria"
      summary.should include "2 records"
    end
  end
  
  describe "#analyze" do
    context "all records are desired", :detail => "@minimum_size is big" do
      before(:all) do
        @comparer.reset
      end
      
      it "uses all records" do
        @comparer.minimum_size = $messages.size + 1
        @comparer.analyze
        @comparer.chosen.size.should == $messages.size
      end      
    end
    
    context "a small number of diverse results is desired", :detail => "@minimum_size is small" do 
      before(:all) do
        @comparer.reset
        @comparer.analyze
      end
      
      it "chooses the smallest number of records that meet all criteria" do
        @comparer.chosen.size.should == 2    # in this case, there are 2 records required
      end
    
      it "does not choose records that duplicate data" do
        @comparer.chosen.should_not include $messages["Palmer^Lois^REDUNDANT"]
        should_only_use_one_of_the_duplicates(@comparer.chosen)
      end
    end

    context "redundant records exist" do
      before(:each) do
        @comparer.reset
      end
      
      it "removes records that match the same criteria" do
        @comparer.call_remove_records_with_duplicate_criteria
        remaining = @comparer.chosen
        remaining.size.should eq 3
        should_only_use_one_of_the_duplicates(remaining)
      end            

      it "removes records that aren't needed to match all criteria" do
        deselect(@comparer, :DUPLICATE)
        @comparer.call_remove_redundancies
        remaining = @comparer.chosen
        remaining.size.should eq 2
        remaining.should_not include $messages["Palmer^Lois^REDUNDANT"]  
      end   

      it "supplements chosen records until the minimum size is met" do
        deselect(@comparer, :DUPLICATE, :REDUNDANT)
        @comparer.minimum_size = 3
        @comparer.call_supplement_chosen
        @comparer.chosen.size.should == 3 
      end   
    end
  end
  
end