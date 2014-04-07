# last tested 4/7
require 'lib/hl7/HL7'

module SeriesNonseriesSupport
  
  SERIES_PROPORTION = 0.02   # 2% of records should be SERIES records
  NONSERIES_PROPORTION = 1 - SERIES_PROPORTION
  
  class HL7::Message
    def series?
      @segments[:PID].account_number[0] == 'A'
    end
  end
  
  # called by records_of_needed_type
  def self.needed_type(records_to_evaluate)
    series_percent = series_proportion(records_to_evaluate)
    series_percent < SERIES_PROPORTION ? :series : :nonseries
  end
  
  # I determined the formula to use here algebraically
  #+ (records_of_type + x_more) / (total_records + x_more) = type_proportion
  #+ x_more = (type_proportion * total_records - records_of_type) / (1 - type_proportion)  
  # negative return result represents number of records of type to take away from results, which
  #+ will generally mean that we want to ADD records of the OTHER type
  def self.amount_that_fixes_proportion(current_chosen_records, type)
    proportion = const_get("#{type.upcase}_PROPORTION")
    ideal_amount = proportion * current_chosen_records.size
    number_needed = ideal_amount - number_of_records_of_type(current_chosen_records, type)
    (number_needed / (1 - proportion)).ceil
  end
  
  # called by needed_type
  def self.series_proportion(all_records)
    number_of_records_of_type(all_records, :series).to_f / all_records.size
  end
  
  #called by current_series_proportions, amount_that_fixes_proportion
  def self.number_of_records_of_type(all_records, type)
    get_records_of_type(all_records, type).size
  end

  # called by number_of_records_of_type
  def self.get_records_of_type(records, type)
    records.select { |record| record.series? == (type == :series) }   
  end   
end