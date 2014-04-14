# last tested 4/7
require 'lib/hl7/HL7'
require 'mixins/ProportionEvaluable'

module SeriesNonseriesSupport
  extend ProportionEvaluable
  
  class HL7::Message
    def series?
      @segments[:PID].account_number[0] == 'A'
    end
  end
  
  SERIES_RATIO = 2.0/100
  SERIES_IDENTIFIER = proc { |record| record.series? }
  
  class SeriesProportion < Proportion
    def initialize(elements)
      super(SERIES_PROPORTION, elements, SERIES_IDENTIFIER)
    end
  end

  def self.new_proportion(records)
    SeriesProportion.new(SERIES_RATIO, records, SERIES_IDENTIFIER)
  end
end