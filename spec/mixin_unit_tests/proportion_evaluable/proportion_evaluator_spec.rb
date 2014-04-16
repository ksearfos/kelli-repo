# passed testing 4/
$LOAD_PATH.unshift File.expand_path('../..',__FILE__)   # mixins directory
require 'spec_helper'

describe ProportionEvaluable::ProportionEvaluator do
  before(:each) do
    @ratio = 0.5
    @inverse_ratio = 1 - @ratio    # yes, it's the same number, but ultimately this is clearer
    
    proportion = double("proportion")
    proportion.stub(:inverse_ratio) { @inverse_ratio }
    proportion.stub(:apply) { |number| number * @ratio }
    low_proportion = proportion
    low_proportion.stub(:elements_in_set) { [1, 2, 3] }
    high_proportion = proportion
    high_proportion.stub(:elements_in_set) { [1, 2, 3, 4, 5] }
    all_elements = [1, 2, 3, 4, 5, 6, 7, 8]
    
    @evaluator = ProportionEvaluable::ProportionEvaluator.new(low_proportion, all_elements)
    @reverse_evaluator = ProportionEvaluable::ProportionEvaluator.new(high_proportion, all_elements)
    @evaluator.stub(:enough_elements?) { false }
  end
  
  it "represents a proportion" do
    expect(@evaluator.proportion).not_to be_nil
  end
  
  it "represents a set of elements to evaluate" do
    expect(@evaluator.all_elements).not_to be_nil
  end

  describe "#take_proportionately" do
    before(:all) do
      @size = 4
      @returned_elements = @evaluator.take_proportionately(@size)
      @qualifying = @returned_elements.select { |element| @evaluator.qualifying_elements.include?(element) }
      @nonqualifying = @returned_elements.select { |element| @evaluator.nonqualifying_elements.include?(element) }
    end
  
    it "returns the requested number of elements" do
      expect(@returned_elements.size).to eq(@size)
    end
    
    it "takes qualifying elements to reach ideal proportion" do
      new_number_of_type = new_size(@evaluator.qualifying.size, @qualifying.size)
      new_total_size = new_size(@evaluator.all_elements.size, @size)
      ratio_of_qualifying = new_number_of_type.to_f / new_total_number_of_type
      expect(ratio_of_qualifying).to eq(@ratio)
    end
    
    it "takes nonqualifying elements to reach ideal proportion" do
      new_number_of_type = new_size(@evaluator.nonqualifying.size, @nonqualifying.size)
      new_total_size = new_size(@evaluator.all_elements.size, @size)
      ratio_of_nonqualifying = new_number_of_type.to_f / new_total_number_of_type
      expect(ratio_of_nonqualifying).to eq(@inverse_ratio)
    end
  end

  describe "#take_from_single_set" do
    before(:all) do
      @number = 1
      @positive_result = @evaluator.take_from_correct_set(@number)
      @negative_result = @evaluator.take_from_correct_set(-@number)
    end
  
    it "returns the requested number of elements", detail => "based on the absolute value" do
      expect(@positive_result.size).to eq(@number)
    end

    context "when given a positive number" do    
      it "returns elements from the qualifying set only" do
        expect(@evaluator.qualifying_elements).to include @positive_result
        end
      end
    end
    
    context "when given a negative number" do
    
      it "returns elements from the nonqualiying set only" do
        @negative_results.each do |element|
          expect(@evaluator.nonqualifying_elements).to include element
        end
      end
    end
  end
  
  describe "#amount_that_fixes_proportions" do
    before(:all) do
      @positive_result = @evaluator.amount_that_fixes_proportions
      @negative_result = @reverse_evaluator.amount_that_fixes_proportions
    end
    
    context "when the set is short qualifying elements" do   
      it "determines how many additional elements will fix the set's proportions" do
        new_qualifying_size = @evaluator.qualifying_elements.size + @positive_result
        new_set_size = @evaluator.all_elements.size + @positive_result
        expect(new_qualifying_size / new_set_size).to eq(@ratio) 
      end

      it "returns a positive number" do
        expect(@positive_result).to be > 0
      end
    end
    
    context "when the set is short nonqualifying elements" do 
      it "determines how many additional elements will fix the set's proportions" do
        new_nonqualifying_size = @reverse_evaluator.nonqualifying_elements.size + @negative_result.abs
        new_set_size = @reverse_evaluator.all_elements.size + @negative_result.abs
        expect(new_nonqualifying_size / new_set_size).to eq(@ratio) 
      end

      it "returns a negative number" do
        expect(@negative_result).to be < 0
      end
    end
    
    context "when given a limiting value", :detail => "a postive integer" do
      context "that is larger in magnitude than the calculated amount" do
        before(:all) do
          @limited_positive_result = @evaluator.amount_that_fixes_proportions(10)
          @limited_negative_result = @reverse_evaluator.amount_that_fixes_proportions(10)
        end
        
        context "and the calculated amount is positive" do
          it "returns the calculated amount" do
            expect(@limited_positive_result).to eq(@positive_result)
          end
        end
      
        context "and the calculated amount is negative" do
          it "returns the calculated amount" do
            expect(@limited_negative_result).to eq(@negative_result)
          end
        end
      end #context: larger in magnitude
        
      context "that is smaller in magnitude than the caluclated amount" do
        before(:all) do
          @limit = 1
          @limited_positive_result = @evaluator.amount_that_fixes_proportions(@limit)
          @limited_negative_result = @reverse_evaluator.amount_that_fixes_proportions(@limit)
        end
        
        context "and the calculated amount is positive" do
          it "returns the limit" do
            expect(@limited_positive_result).to eq(@limit)
          end
        end
      
        context "and the calculated amount is negative" do
          it "returns the calculated amount" do
            expect(@limited_negative_result).to eq(@limit)
          end
        end
      end # context: smaller in magnitude
    end # context: limiting value
  end
end