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
      
    def take_set_amount(amount)
      amount_of_proportion = amount_to_reach_ratio(amount)
      amount_of_inverse = amount - amount_of_a
      @proportion_set.take(amount_of_proportion) + @inverse_set.take(amount_of_inverse)
    end   

    # as takes_set_amount, except determines amount for you and allows for a size limit
    def take_enough_to_fix_proportions(limit)
      return [] if enough_elements?
      amount = [ideal_amount_to_take, limit].min
      take_set_amount(amount)
    end   
    
    private
    
    # called by take_enough_to_fix_proportions
    def enough_elements?
      current_ratio >= @proportion.ratio  
    end
   
    # called by enough_elements?
    def current_ratio
      @proportion_set.size / @all_elements.size
    end 
    
    # called by take_minimum
    # def ideal_amount_to_take
      # amount_of_a = amount_that_fixes_proportions(@proportion_a)
      # amount_of_b = amount_that_fixes_proportions(@proportion_b)
      # amount_of_a + amount_of_b
    # end
#     
    # # called by ideal_amount_to_take
    # def amount_that_fixes_proportions(proportion)
      # tentative_amount = proportion.amount_to_add
      # tentative_amount < 0 ? 0 : tentative_amount    # negatives don't really make sense here
    # end  
    
    # called by take_set_amount
    def amount_to_reach_ratio(amount_to_add)
      desired_amount = @proportion.apply(amount_to_add + @all_elements.size)
      current_amount = @proportion_set.size
      make_into_realistic_number(desired_amount - current_amount)
    end
    
    # called by amount_to_reach_ratio
    def make_into_realistic_number(amount)
      amount < 0 ? 0 : amount.ceil
    end 
  end
      
  class Proportion
    def initialize(ratio, &identifier)
      @ratio = ratio
      @identifier = identifier
    end
    
    def find_elements_in(set)
      my_elements(set)
    end
    
    def apply(amount)
      amount * @ratio
    end
    
    # I determined the formula to use here algebraically
    #+ (records_of_type + x_more) / (total_records + x_more) = type_proportion
    #+ x_more = (type_proportion * total_records - records_of_type) / (1 - type_proportion)  
    #+        = amount_we_need_to_fix_current_size / (inverse_proportion)
    # def calculate_amount_to_add
      # amount_to_add = ideal_size - my_size
      # amount_to_add < 0 ? 0 : amount_to_add / (1 - @ratio)
    # end
    
    # def amount_to_reach_ratio(amount_to_add)
      # desired_amount = scale(amount_to_add + @all_elements.size)
      # (desired_amount - my_size).ceil
    # end
    
    private
    
    # called by initialize
    def my_elements
      @elements.select { |element| @identifier.call(element) }
    end
  end
  
end