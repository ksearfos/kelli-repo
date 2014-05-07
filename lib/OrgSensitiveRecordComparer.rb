require 'OHmodule/OhioHealthUtilities'
require 'RecordComparer'

# this class is very very similar to the RecordComparer, except that it takes into account the proportions
# of the SERIES encounters versus non-SERIES among the organiation and tries to give results that also fit
# these proportions
class OrgSensitiveRecordComparer < RecordComparer
  include OhioHealthUtilities
  
  def initialize( recs, type, min_results_size=1 )
    super
  end
  
  def analyze
    return if @records_and_criteria.size <= @min_size   # we aren't going to need all the records
    
    remove_redundancies    
    if @used_records.size < @records_and_criteria.size
      fix_proportions
      supplement_chosen
    end
  end
  
  private

  # called by remove_records_with_duplicate_criteria
  def unchoose_all_but_one( records )
    type_to_keep = OhioHealthUtilities.series_or_nonseries( @used_records )
    record_to_keep = OhioHealthUtilities.pick_one_of_type( records, type_to_keep )
    records.delete( record_to_keep )
    unchoose( records )   
  end

  # called by analyze
  def fix_proportions
    size_cap = @used_records.size * 1.10   # don't add too many records -- we still want a small set
    choose_based_on_series( size_cap ) if OhioHealthUtilities.analyze_proportions( @used_records ) != OhioHealthUtilities::SERIES_PROPORTION
  end  
  
  # called by analyze
  def supplement_chosen
    choose_based_on_series( @min_size )
  end

  # called by supplement_chosen
  def choose_based_on_series( size )
    series_amount, nonseries_amount = OhioHealthUtilities.how_many_to_take?( @used_records, size )
    series_available, nonseries_available = OhioHealthUtilities.sort_records( @unused_records )
    series_amount = 0 if series_amount < 0
    nonseries_amount = 0 if nonseries_amount < 0
    records_to_add = series_available.shuffle.take(series_amount) + nonseries_available.shuffle.take(nonseries_amount)
    choose( records_to_add )
  end
end  