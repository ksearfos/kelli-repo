# last tested 4/7
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
    return if !records_left_to_take? || series_proportion_is_correct?  

    type = needed_type
    ideal_amount = SeriesNonseriesSupport.amount_that_fixes_proportion(@used_records, type)
    size_cap = (@used_records.size * 0.10).ceil   # don't add too many records - 10% is arbitrary
    realistic_amount = [ideal_amount, size_cap].min
    choose_random_records_of_type(realistic_amount, type)
  end
  
  private

  # called by remove_records_with_duplicate_criteria
  def unchoose_all_but_one(records)
    needed_type_records = records_of_needed_type(records)
    records_to_remove = records    
    kept_record = needed_type_records.empty? ? records.shuffle.shift : needed_type_records.shuffle.shift 
    records_to_remove.delete(kept_record)
    unchoose(*records_to_remove)
  end  

  # called by analyze
  def supplement_chosen
    supplement_chosen_with_type(:series)
    supplement_chosen_with_type(:nonseries)
  end
 
  def supplement_chosen_with_type(type)
    desired_amount = @minimum_size * SeriesNonseriesSupport.const_get("#{type.upcase}_PROPORTION")
    current_amount = SeriesNonseriesSupport.number_of_records_of_type(@used_records, type)
    amount_to_reach_desired = (desired_amount - current_amount).ceil
    realistic_amount = [amount_to_reach_desired, amount_to_reach_minimum_size].min
    choose_random_records_of_type(realistic_amount, type)
  end
  
  def choose_random_records_of_type(amount, type)
    return if amount <= 0
    pool = records_of_needed_type(@unused_records)
    choose(*pool.shuffle.take(amount))
  end

  # aliasing for SeriesNonseriesSupport methods
  def records_of_needed_type(records)
    SeriesNonseriesSupport.get_records_of_type(records, needed_type)
  end

  def series_proportion_is_correct?
    SeriesNonseriesSupport.series_proportion(@used_records) == SERIES_PROPORTION
  end  
  
  def needed_type
    SeriesNonseriesSupport.needed_type(@used_records)
  end

end  