module ProportionEvaluation
    
  class Evaluator
    attr_reader :distribution, :elements, :qualifying_elements, :nonqualifying_elements
    
    def initialize(distribution, elements)
      @distribution = distribution
      @elements = elements
      @qualifying_elements = @distribution.identify_elements(@elements)
      @nonqualifying_elements = @elements - @qualifying_elements
    end
    
    def correctly_distributed?
      my_distribution == ideal_distribution
    end
    
    def take(number)
      qualifying_number = number_of_qualifying_elements_to_take(number)
      nonqualifying_number = number - qualifying_number
      take_from_qualifying(qualifying_number) + take_from_nonqualifying(nonqualifying_number)
    end
    
    def evaluate
      add_how_many?.abs
    end
    
    def evaluate_up_to_limit(limit)
      [evaluate, limit].min
    end
    
    private
    
    def my_distribution
      amount_of_qualifying_elements / amount_of_total_elements
    end
    
    def ideal_distribution
      @distribution.ratio
    end

    # returns a float, for convenience when caluclating ratios
    #+ which is mostly what this is used for....    
    def amount_of_qualifying_elements
      @qualifying_elements.size.to_f
    end
    
    def amount_of_total_elements
      @elements.size
    end
    
    # this formula was determined algebraically:
    #+ (qualifying_elements + x) / (total_elements + x) = ideal_distribution
    #+ x = ((ideal_distribution * total_elemets) - qualifying_elements) / (1 - ideal_distribution)
    #+ or in better English, (amount_of_qualifying_elements_we_want - amount_we_have) / inverse_of_ideal_distribution
    def add_how_many?
      (ideal_amount_of_qualifying_elements - amount_of_qualifying_elements) / @distribution.inverse
    end
    
    def ideal_amount_of_qualifying_elements(size_of_set = amount_of_total_elements)
      ideal_distribution * size_of_set
    end
    
    def number_of_qualifying_elements_to_take(amount)
      new_set_size = amount_of_total_elements + amount
      ideal_amount_of_qualifying_elements(new_set_size) - amount_of_qualifying_elements
    end
    
    def take_from_qualifying(amount)
      take_random(@qualifying_elements, amount)
    end
    
    def take_from_nonqualifying(amount)
      take_random(@nonqualifying_elements, amount)
    end
    
    def take_random(set, amount)
      set.shuffle.take(amount)
    end
  end
  
end