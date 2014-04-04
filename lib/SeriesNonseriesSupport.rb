require 'lib/hl7/HL7'

module SeriesNonseriesSupport
  
  SERIES_PROPORTION = 0.02   # 2% of records should be SERIES records
  NONSERIES_PROPORTION = 1 - SERIES_PROPORTION
  
  class HL7::Message
    def is_series?
      @segments[:PID].account_number[0] == 'A'
    end
  end
  
  def records_of_needed_type(records)
    type_to_take = needed_type(records)
    get_records_of_type(records, type_to_take)
  end
  
  def needed_type(records_to_evaluate)
    series_percent = current_series_proportion(records_to_evaluate)
    series_percent < SERIES_PROPORTION ? :series : :nonseries
  end
  
  # I determined the formula to use here algebraically
  #+ (records_of_type + x_more) / (total_records + x_more) = type_proportion
  #+ x_more = (type_proportion * total_records - records_of_type) / (1 - type_proportion)  
  def amount_that_fixes_proportion(current_chosen_records, type)
    proportion = SeriesNonseriesSupport.const_get("#{type.upcase}_PROPORTION")
    ideal_amount = (proportion * current_chosen_records.size).ceil
    number_needed = ideal_amount - number_of_records_of_type(current_chosen_records, type)
    (number_needed / (1 - proportion)).round
  end
  
  def get_records_of_type(records, type)
    records.select { |record| type == :series ? record.is_series? : !record.is_series? }
  end
  
  def number_of_records_of_type(all_records, type)
    get_records_of_type(all_records, type).size
  end
 
  def current_series_proportion(records)
    number_of_records_of_type(records, :series).to_f / records.size
  end
   
end