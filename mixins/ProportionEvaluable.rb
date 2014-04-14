# last tested 4/7
require 'lib/hl7/HL7'

module ProportionEvaluable
  
  class ProportionEvaluator
    def initialize(proportion, set)
      @proportion = proportion
      @all_elements = set
      @proportion_set = @proportion.find_elements_in(@all_elements)
      @inverse_set = @all_elements - @proportion_set 
    end
      
    def take_from_both_sets(amount)
      amount_of_proportion = amount_to_reach_ratio(amount)
      amount_of_inverse = amount - amount_of_a
      @proportion_set.take(amount_of_proportion) + @inverse_set.take(amount_of_inverse)
    end  
    
    # takes from @proportion_set if amount is positive, otherwise takes from @inverse_set
    def take_from_correct_set(amount)
      negative?(amount) ? @inverse_set.take(amount.abs) : @proportion_set.take(amount)
    end 

    # returning a negative number means to take that amount from the inverse set
    def amount_that_fixes_proportions(limit)
      return 0 if enough_elements?
      amount = ideal_amount_to_take
      smaller_amount(amount, limit)
    end  
    
    def current_size
      @proportion_set.size
    end 
    
    private
    
    # called by take_enough_to_fix_proportions
    def enough_elements?
      current_ratio >= @proportion  
    end
   
    # called by enough_elements?
    def current_ratio
      current_size / @all_elements.size
    end 
    
    # I determined the formula to use here algebraically:
    #+ (records_of_type + x_more) / (total_records + x_more) = type_proportion
    #+ x_more = (type_proportion * total_records - records_of_type) / (1 - type_proportion) 
    def calculate_amount_to_add
      amount_to_add = ideal_size - current_size
      (amount_to_add / @proportion.inverse_ratio)   # yes, do keep negative numbers negative
    end 
    
    # called by take_set_amount
    def amount_to_reach_ratio(amount_to_add)
      desired_amount = @proportion.apply(amount_to_add + @all_elements.size)
      current_amount = @proportion_set.size
      make_into_realistic_number(desired_amount - current_amount)
    end
    
    # called by amount_to_reach_ratio, calculate_amount_to_add
    def make_into_realistic_number(amount)
      negative?(amount) ? 0 : amount.ceil
    end 
    
    # called by calculate_amount_to_add
    def ideal_size
      @proportion.apply(@all_elements)
    end
    
    # compares absolute values, but returns actual value (positive or negative)
    def smaller_amount(amount1, amount2)
      amount1.abs > amount2.abs ? amount1 : amount2
    end
    
    def negative?(amount)
      amount < 0
    end
  end
      
  class Proportion
    include Comparable
    
    def initialize(ratio, &identifier)
      @ratio = ratio
      @identifier = identifier
    end
    
    def <=>(other_ratio)
      if @ration > other_ratio then 1
      elsif other_ratio > @ratio then -1
      else 0
      end  
    end
    
    def find_elements_in(set)
      my_elements(set)
    end
    
    def apply(amount)
      amount * @ratio
    end
    
    def inverse_ratio
      1 - @ratio
    end
    
    private
    
    # called by initialize
    def my_elements
      @elements.select { |element| @identifier.call(element) }
    end
  end
  
end