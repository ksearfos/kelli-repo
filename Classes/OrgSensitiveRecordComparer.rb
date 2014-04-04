require 'lib/SeriesNonseriesSupport'
require 'classes/RecordComparer'

# this class is very very similar to the RecordComparer, except that it takes into account the proportions
# of the SERIES encounters versus non-SERIES among the organiation and tries to give results that also fit
# these proportions
class OrgSensitiveRecordComparer < RecordComparer
  include SeriesNonseriesSupport
  
  def initialize(recs, type)
    super
  end
  
  def fix_proportions
    return if !records_left_to_take? || current_series_proportion(@used_records) == SERIES_PROPORTION   # perfect as-is  
 
    type = needed_type(@used_records)
    ideal_amount = amount_that_fixes_proportion(@used_records, type)
    size_cap = (@used_records.size * 0.10).ceil   # don't add too many records - 10% is arbitrary
    realistic_amount = [ideal_amount, size_cap].min
    choose_random_records_of_type(realistic_amount, type)
  end
  
  private

  # called by remove_records_with_duplicate_criteria
  def unchoose_all_but_one(records)
    subset_of_records = records_of_needed_type(records)
    one_to_keep = subset_of_records.shuffle.shift
    records.delete(one_to_keep)
    unchoose(*records)   
  end  

  # called by analyze
  def supplement_chosen
    supplement_chosen_with_type(:series)
    supplement_chosen_with_type(:nonseries)
  end
 
  def supplement_chosen_with_type(type)
    desired_number_of_type = (@minimum_size * SeriesNonseriesSupport.const_get("#{type.upcase}_PROPORTION")).ceil
    amount_to_reach_desired = desired_number_of_type - number_of_records_of_type(@used_records, type)
    amount_to_reach_desired = 0 if amount_to_reach_desired < 0
    realistic_amount = [amount_to_reach_desired, amount_to_reach_minimum_size].min
    choose_random_records_of_type(realistic_amount, type)
  end
  
  def choose_random_records_of_type(amount, type)
    pool = get_records_of_type(@unused_records, type)
    choose_random_records(amount, pool)
  end
end  