$LOAD_PATH.unshift File.expand_path("../../..", __FILE__)   # project directory
$LOAD_PATH.unshift File.dirname(__FILE__)
require 'spec_helper'

describe "OrgSensitiveOrgSensitiveRecordComparer" do
  
  before(:all) do
    @comparer = OrgSensitiveRecordComparer.new($messages.values, $criteria)
  end
  
  it "creates an object connecting a list of records to a list of criteria" do
    @comparer.should be_a OrgSensitiveRecordComparer
    @comparer.records_and_criteria.keys.should eq $messages.values
    @comparer.records_and_criteria.values.each { |criterion| criterion.should be_a Array }
  end
  
  it "connects a message to all criteria matched" do
    record = $messages["Palmer^Lois^G"]
    @comparer.records_and_criteria[record].should == [:obx_sodium, :obx_chloride, :female]
  end

  describe "#reset" do
    it "sets the comparer back to an un-analyzed state" do
      @comparer.analyze
      @comparer.reset
      @comparer.used_records.size.should eq 4
      @comparer.unused_records.should be_empty
      @comparer.matched_criteria.size.should eq 5
      @comparer.minimum_size.should eq 1
    end
  end

  describe "#analyze", :detail => "calls remove_duplicate_records(), remove_redundancies(), supplement_chosen()" do   
    context "when all records are required", :detail => "doesn't run through analyze()" do
      it "chooses all records" do
        @comparer.minimum_size = 10    # there are only 4 records, remember
        @comparer.analyze
        @comparer.chosen.size.should == $messages.size
      end      
    end
    
    context "when a small number of records is acceptable" do
      context "STEP 1:" do
        it "removes duplicate records", :details => "OrgSensitiveRecordComparer.remove_records_with_duplicate_criteria()" do
          @comparer.call_remove_records_with_duplicate_criteria
          remaining = @comparer.chosen
          remaining.size.should eq 3
          
          if remaining.include?($messages["Palmer^Lois^G"])
            remaining.should_not include $messages["Palmer^Lois^DUPLICATE"]
          else
            remaining.should include $messages["Palmer^Lois^DUPLICATE"]
          end
        end          
      end

      context "STEP 2:" do
        it "removes redundant records", :details => "OrgSensitiveRecordComparer.remove_redundancies()" do
          @comparer.call_remove_redundancies
          remaining = @comparer.chosen
          remaining.size.should eq 2
          remaining.should_not include $messages["Palmer^Lois^SHOULD_NOT_BE_USED"]  
        end   
      end

      context "STEP 3:" do
        it "fixes the ratio of SERIES to non-SERIES records",
        :details => "OrgSensitiveRecordComparer.fix_proportions()" do
          @comparer.minimum_size = 3
          @comparer.call_supplement_chosen
          @comparer.chosen.size.should == 3 
        end   
      end
            
      context "STEP 4:" do
        it "supplements chosen records until the minimum size is met",
        :details => "OrgSensitiveRecordComparer.supplement_chosen()" do
          @comparer.minimum_size = 3
          @comparer.call_supplement_chosen
          @comparer.chosen.size.should == 3 
        end   
      end
      
      context "the entire function" do
        before(:all) do
          @comparer.reset
          @comparer.analyze
        end    
            
        it "chooses the smallest number of records that meet all criteria",
        :detail => "which are accessed with chosen()" do
          @comparer.chosen.size.should == 2    # in this case, there are 2 records required
        end
    
        it "does not choose records that duplicate data" do
          chosen = @comparer.chosen
          chosen.should_not include $messages["Palmer^Lois^SHOULD_NOT_BE_USED"]
          if chosen.include?($messages["Palmer^Lois^G"])
            chosen.should_not include $messages["Palmer^Lois^DUPLICATE"]
          else
            chosen.should include $messages["Palmer^Lois^DUPLICATE"]
          end
        end
    
        it "keeps track of which criteria have been met",
        :detail => "which are accessed with matched()" do
          @comparer.matched.size.should == $criteria.size - 1   # in this case, all criteria are matched but one
        end

        it "keeps track of which criteria have not been met",
        :detail => "which are accessed with unmatched()" do
          @comparer.unmatched.size.should == 1
        end
      end
    end  
  end

  describe "chosen" do
    it "returns a list of records chosen" do
      @comparer.chosen.each { |record| record.should be_a HL7::Message }
    end
  end

  describe "matched" do
    it "returns a list of criteria that were matched", :detail => "the descriptions, not the procs" do
      @comparer.matched.should == [:female, :male, :obx_chloride, :obx_potassium, :obx_sodium]
    end
  end 

  describe "unmatched" do
    it "returns a list of criteria that were not matched", :detail => "the descriptions, not the procs" do
      @comparer.unmatched.should == [:obx_fake]
    end
  end 
  
  describe "summary" do  
    it "returns a message indicating what the results show",
    :detail => "the number of matched criteria and records chosen" do
      @comparer.summary.should == "I have successfully matched 5 of 6 criteria, for a total of 2 records."
    end
  end
  
end