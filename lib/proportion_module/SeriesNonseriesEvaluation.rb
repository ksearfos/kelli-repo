# last tested 4/16
require 'lib/hl7/HL7'
require 'lib/proportion_module/ProportionEvaluation'

module SeriesNonseriesEvaluation
  extend ProportionEvaluation
  
  class HL7::Message
    def series?
      @segments[:PID].account_number[0] == 'A'
    end
  end
  
  SERIES_RATIO = 0.02
  SERIES_IDENTIFIER = proc { |record| record.series? }
  SERIES_PROPORTION = ProportionEvaluation::Proportion.new(SERIES_RATIO, SERIES_IDENTIFIER)
  
  def self.make_new_evaluator(records)
    ProportionEvaluation::Evaluator.new(SERIES_PROPORTION, records)
  end
end