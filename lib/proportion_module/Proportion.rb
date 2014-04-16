# last tested 4/15
require 'lib/hl7/HL7'

module ProportionEvaluation

  class Proportion    
    attr_reader :ratio
    
    def initialize(ratio, identifier)
      @ratio = ratio
      @identifier = identifier
    end
    
    def identify_elements(full_set)
      full_set.select { |element| @identifier.call(element) }
    end
    
    def inverse
      1 - @ratio
    end
  end
 
end