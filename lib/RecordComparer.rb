require 'lib/OHmodule/OHProcs'

class RecordComparer
  include OHProcs
  
  attr_reader :records, :matches, :recs_to_use
  
  def initialize( recs, type, min_results_size=1 )
    @records_and_criteria = Hash.new_from_array( recs, [] )
    @used_records = recs
    @unused_records = []
    @min_size = min_results_size      # smallest number of records to return
    
    # items for tracking criteria
    @criteria = OHProcs.instance_variable_get( "@#{type}" )   # hash, :descriptive_symbol => {proc_to_call}
    @matched_criteria = []

    determine_record_criteria
    remove_records_with_duplicate_criteria
  end
  
  def analyze
    return if @records_and_criteria.size <= @min_size   # we are going to need all the records
    
    remove_duplicate_criteria
    remove_redundancies
    fix_proportions
    supplement_chosen if chosen.size < @min_size
  end

  def chosen
    @used_records
  end  
  
  def summary
    "I have successfully matched #{matched.size} of #{@criteria.size} criteria, for a total of #{chosen.size} records."
  end
  
  def unmatched  
    @criteria.keys - @matched_criteria
  end
  
  def matched
    @matched_criteria
  end
  
  private

  # called by initialize
  def determine_record_criteria
    @records_and_criteria.each_key{ |record|
      @records_and_criteria[record] = passing_criteria( record )
    }
    @matched_criteria = get_criteria
  end 

  # called by initialize
  def remove_records_with_duplicate_criteria
    criteria_to_record = @records_and_criteria.flip  # => [ [procname, record(s)] ]
    criteria_to_record.each_value{ |records|
      next unless records.is_a? Array   # don't do anything with unique sets of criteria

      type_to_keep = series_or_nonseries( @records_and_criteria.keys )
      record_to_keep = OHProcs.pick_best( records, type_to_keep )
      records_to_remove = records.delete( record_to_keep )
      unchoose( records_to_remove )   
    }
  end
 
  # called by analyze
  def remove_redundancies
    rec_crit_array = @records_and_criteria.sort_by{ |_,criteria| criteria.size }   # => [ [key1,val1], [key2,val2] ... ]
    rec_crit_array.each_key{ |record| unchoose( record ) if is_redundant?(record) }
  end
   
  # called by determine_record_criteria and criteria_matched_without_record
  def get_criteria( records = @records_and_criteria.keys )
    criteria = []
    records.each{ |record| criteria << @records_and_criteria[record] }
    criteria.flatten.uniq
  end 

  # called by determine_record_criteria  
  def passing_criteria(record)
    passed = []
    @criteria.each{ |name,proc| passed << name if proc.call( record ) }
    passed  
  end

  # called by remove_records_with_duplicate_criteri
  def unchoose( *records )
    # @records_and_criteria.delete_all( *records )
    @unused_records += records
    @used_records -= records 
  end
  
  # called by remove_redundancies
  def is_redundant?( record )
    criteria_matched_without_record(record).size == @matched.size
  end 
   
   # called by is_redundant?    
  def criteria_matched_without_record( record )
    used_records = @used_records.clone  # don't want to actually alter instance variable, so use copy
    used_records.delete( record )
    get_criteria( used_records )
  end 

  def fix_proportions
    series_needed, nonseries_needed = OHProcs.analyze_proportions( @used_records )
    unused_series, unused_nonseries = OHProcs.sort_records( @unused_records )
    
    # chances are that either series_needed or nonseries_needed will be 0
    @used_records += take_within_reason( series_records, series_needed )
    @used_records += take_within_reason( nonseries_records, nonseries_needed )
  end 
  
  def take_within_reason( records_to_take, proposed_amount )
    cutoff = 0.1                # how many more records do we take?  10% more
    cutoff_amount = ( @used_records.size * 0.1 ).round
    amount_to_take = cutoff_amount < proposed_amount ? cutoff_amount : proposed_amount
    records_to_take.shuffle.take( amount_to_take )
  end    
end  