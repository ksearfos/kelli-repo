# passed testing 4/16
$LOAD_PATH.unshift File.expand_path('../..',__FILE__)   # mixins directory
require 'spec_helper'

describe ProportionEvaluation::Evaluator do
  before(:each) do   
    @elements = [1, 2, 3, 4, 5, 6, 7, 8]
    @ratio = 0.5
    
    equal_proportion = double("equal proportion")
    equal_proportion.stub(:ratio) { @ratio }
    equal_proportion.stub(:inverse) { 1 - @ratio }
    equal_proportion.stub(:identify_elements) { [1, 2, 3, 4] }
    @evaluator = ProportionEvaluation::Evaluator.new(equal_proportion, @elements)
    
    smaller_proportion = double("smaller proportion")
    smaller_proportion.stub(:ratio) { @ratio }
    smaller_proportion.stub(:inverse) { 1 - @ratio }
    smaller_proportion.stub(:identify_elements) { [1, 2, 3] }
    @small_evaluator = ProportionEvaluation::Evaluator.new(smaller_proportion, @elements)
    
    bigger_proportion = double("larger proportion")
    bigger_proportion.stub(:ratio) { @ratio }
    bigger_proportion.stub(:inverse) { 1 - @ratio }
    bigger_proportion.stub(:identify_elements) { [1, 2, 3, 4, 5] }
    @big_evaluator = ProportionEvaluation::Evaluator.new(bigger_proportion, @elements)
  end

  it "has a group of elements" do
    expect(@evaluator.elements).to be_a Array
  end
  
  it "has rules governing distribution of the elements" do
    expect(@evaluator.distribution).not_to be_nil
  end
    
  describe "#correctly_distributed?" do
    context "when elements are correctly distributed" do
      it "is true" do
        expect(@evaluator).to be_correctly_distributed
      end
    end

    context "when elements are not correctly distributed" do
      it "is false" do
        expect(@small_evaluator).not_to be_correctly_distributed
      end
    end
  end

  describe "#take" do
    before(:each) do
      proportion = double("proportion")
      proportion.stub(:ratio) { @ratio }
      proportion.stub(:identify_elements) { [1, 2, 3, 4, 5] }
      @size = 2
      @taken = @evaluator.take(@size)
      @fixed_evaluator = ProportionEvaluation::Evaluator.new(proportion, @elements + @taken)
    end
    
    it "returns the specified number of elements" do
      expect(@taken.size).to eq(@size)
    end
    
    it "returns elements that correct the distribution" do
      expect(@fixed_evaluator).to be_correctly_distributed
    end
    
    context "when qualified records are needed" do
      it "returns only qualified records" do
        @small_evaluator.take(@size).each do |element|
          expect(@evaluator.qualifying_elements).to include element
        end
      end
    end
    
    context "when nonqualified records are needed" do
      it "returns only nonqualified records" do
        @big_evaluator.take(@size).each do |element|
          expect(@evaluator.nonqualifying_elements).to include element
        end
      end
    end
    
    context "when both types of record are needed" do
      before(:each) do
        @is_qualified_proc = proc { |element| @evaluator.qualifying_elements.include?(element) }
      end
      
      it "returns a proportionate number of qualified records" do
        qualified = @taken.select { |element| @is_qualified_proc.call(element) }
        expect(qualified.size).to eq(1)
      end
      
      it "returns a proportionate number of nonqualified records" do
        nonqualified = @taken.select { |element| !@is_qualified_proc.call(element) }
        expect(nonqualified.size).to eq(1)
      end
    end
  end
  
  describe "#evaluate" do
    it "returns the number of elements to add to correct distribution" do
      expect(@evaluator.evaluate).to eq(0)
      expect(@small_evaluator.evaluate).to eq(2)
      expect(@big_evaluator.evaluate).to eq(2)
    end
  end
  
  describe "#evaluate_up_to_limit" do 
    context "when given a limit that is smaller than the result" do
      it "returns the limit" do
        expect(@small_evaluator.evaluate_up_to_limit(1)).to eq(1)
      end
    end
      
    context "when given a limit that is larger than the result" do
      it "returns the total" do
        expect(@small_evaluator.evaluate_up_to_limit(4)).to eq(2)
      end
    end    
  end
end
