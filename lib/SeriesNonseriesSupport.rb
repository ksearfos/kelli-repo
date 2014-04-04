require 'lib/hl7/HL7'

module SeriesNonseriesSupport
  
  SERIES_PROPORTION = 0.02   # 2% of records should be SERIES records
  NONSERIES_PROPORTION = 1 - SERIES_PROPORTION
  
  class HL7::Message
    def is_series?
      @segments[:PID].account_number[0] == 'A'
    end
  end
  
  def self.records_of_needed_type(records)
    type_to_take = needed_type(records)
    get_records_of_type(records, type_to_take)
  end
  
  def self.needed_type(records_to_evaluate)
    series_percent = current_series_proportion(records_to_evaluate)
    series_percent < SERIES_PROPORTION ? :series : :nonseries
  end
  
  # exclusively called by needed_type  
  def self.current_series_proportion(records)
    number_of_records_of_type(records, :series).to_f / records.size
  end
  
  # I determined the formula to use here algebraically
  #+ (records_of_type + x_more) / (total_records + x_more) = type_proportion
  #+ x_more = (type_proportion * total_records - records_of_type) / (1 - type_proportion)  
  def self.amount_that_fixes_proportions(current_pool_of_records, type)
    proportion = self.const_get("#{type.upcase}_PROPORTION")
    ideal_amount = proportion * current_pool_of_records.size
    number_needed = ideal_amount - number_of_records_of_type(current_pool_of_records, type)
    number_needed / (1 - proportion)
  end
  
  def self.get_records_of_type(records, type)
    records.select { |record| type == :series ? record.is_series? : !record.is_series? }
  end
  
  def self.number_of_records_of_type(all_records, type)
    get_records_of_type(all_records, type).size
  end
 
end