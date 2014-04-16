# last tested 4/7
require 'lib/hl7/HL7'

module ProportionEvaluable
  
  class ProportionEvaluator
    def initialize(proportion, set)
      @proportion = proportion
      @all_elements = set
      @qualifying_elements = @proportion.elements_in_set(@all_elements)
      @nonqualifying_elements = @all_elements - @qualifying_elements 
    end
      
    def take_proportionately(amount)
      qualifying_amount = how_many_qualifying_elements?(amount)
      nonqualifying_amount = amount - qualifying_amount
      take(qualifying_amount, nonqualifying_amount)
    end  
    
    # takes from @qualifying_elements if amount is positive, otherwise takes from @nonqualifying_elements
    def take_from_single_set(amount)
      subset(which_set?(amount), amount)
    end 

    # returning a negative number means to take that amount from the nonqualifying set
    def evaluate(limit = 0)
      return 0 if enough_elements?
      recommended = how_many_will_fix_proportion?
      limit = 0 ? recommended : smaller_magnitude(recommended, limit)
    end  
    
    private
    
    # ----- size-related methods ----- #
    
    # called by how_many_will_fix_proportion?, number_of_qualifying_to_add
    def current_size
      @qualifying_elements.size
    end 
    
    # called by evaluate
    def enough_elements?
      @proportion.exemplified_by?(@all_elements)  
    end 
    
    # ----- calculation methods ----- #
    
    # called by evaluate
    # (records_of_type + x_more) / (total_records + x_more) = type_proportion
    #+  ==>  x_more = (type_proportion * total_records - records_of_type) / (1 - type_proportion) 
    #+  result may be positive or negative
    def how_many_will_fix_proportion?
      (@proportion.apply(@all_elements.size) - current_size) / @proportion.inverse_ratio
    end 
    
    # called by take_proportionately
    def how_many_qualifying_elements?(amount_to_add)
      larger_set_size = @all_elements.size + amount_to_add
      return_as_a_usable_number(number_of_qualifying_to_add(larger_set_size))
    end

    # called by how_many_qualifying_elements?
    def number_of_qualifying_to_add(set_size)
      desired_amount = @proportion.apply(set_size)
      desired_amount - current_size
    end
    
    # ----- methods that manipulate @qualified_elements/@nonqualified_elements
    # called by take_from_single_set
    def which_set?(number)
      number.negative? ? @nonqualifying_elements : @qualifying_elements
    end
    
    # called by take_proportonately
    def take(qualifying_amount, nonqualifying_amount)
      subset(@qualifying_elements, qualifying_amount) + subset(@nonqualifying_elements, nonqualifying_amount)
    end
    
    # called by take, take_from_single_set
    def subset(set, amount)
      set.shuffle.take(amount)
    end

    # ----- numeric result manipulation ----- #
    # called by how_many_qualifying_elements?
    def return_as_a_usable_number(amount)
      amount.negative? ? 0 : amount.ceil
    end
    
    # called by evaluate
    # compares absolute values, but returns actual value (positive or negative)
    def smaller_magnitude(amount1, amount2)
      amount1.abs > amount2.abs ? amount1 : amount2
    end   
  end
      
  class Proportion    
    attr_reader :ratio
    
    def initialize(ratio, identifier)
      @ratio = ratio
      @identifier = identifier
    end
    
    def exemplified_by?(set)
      target_number = apply(set.size).round    # likely to be a decimal
      number_of_elements_in_set(set) == target_number
    end
    
    def number_of_elements_in_set(set)
      elements_in_set(set).size
    end
    
    def elements_in_set(set)
      my_elements(set)
    end
    
    def apply(number)
      number * @ratio
    end
    
    def inverse_ratio
      1 - @ratio
    end
    
    private
    
    # called by initialize
    def my_elements(all_elements)
      all_elements.select { |element| @identifier.call(element) }
    end
  end

  class TypedSet
    attr_reader :size, ratio
    
    def initialize(elements, ratio)
      @elements = elements
      @size = @elements.size
      @ratio = ratio
    end
  end
 
end