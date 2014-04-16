# last tested 4/7
require 'lib/hl7/HL7'

module ProportionEvaluation

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
    
    def number_of_identified_elements(set)
      elements(set).size
    end
    
    def identified_elements(set)
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
 
end