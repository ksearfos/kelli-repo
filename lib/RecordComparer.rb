require 'lib/OHmodule/OhioHealthUtilities'

class RecordComparer
  include OhioHealthUtilities
  
  attr_reader :records_and_criteria
  
  def initialize( recs, type, min_results_size=1 )
    @records_and_criteria = Hash.new_from_array( recs, [] )
    @used_records = recs
    @unused_records = []
    @min_size = min_results_size      # smallest number of records to return
    
    # items for tracking criteria
    @criteria = OhioHealthUtilities.instance_variable_get( "@#{type}" )   # hash, :descriptive_symbol => proc_to_call
    @matched_criteria = []

    determine_record_criteria
    remove_records_with_duplicate_criteria
  end
  
  def analyze
    return if @records_and_criteria.size <= @min_size   # if we need all the records, don't do anything
    
    remove_redundancies    
    supplement_chosen if @used_records.size < @records_and_criteria.size
  end

  def chosen
    @used_records
  end  
  
  def summary
    "I have successfully matched #{matched.size} of #{@criteria.size} criteria, for a total of #{chosen.size} records."
  end
  
  def unmatched  
    unmatched = @criteria.keys - @matched_criteria
    unmatched.sort
  end
  
  def matched
    @matched_criteria.sort
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
      next unless records.size > 1   # don't do anything with unique sets of criteria
      unchoose_all_but_one( records )
    }
  end

  # called by remove_records_with_duplicate_criteria
  def unchoose_all_but_one( records )
    records.shuffle!
    records.shift       # "choose" the first one by not un-choosing it
    unchoose( records )   
  end
 
  # called by analyze
  def remove_redundancies
    rec_crit_array = @records_and_criteria.sort_by{ |_,criteria| criteria.size }   # => [ [rec1,crit1], [rec2,crit2] ... ]
    rec_crit_array.each{ |record,_| 
      next unless @used_records.include?( record )
      unchoose( [record] ) if is_redundant?( record )
    }
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

  # called by remove_records_with_duplicate_criteria
  def unchoose( records )
    @unused_records += records
    @used_records -= records
    @unused_records.uniq
  end

  # called by fix_proportions
  def choose( records )
    @unused_records -= records
    @used_records += records 
    @used_records.uniq
  end
    
  # called by remove_redundancies
  def is_redundant?( record )
    criteria_matched_without_record( record ).size == @matched_criteria.size
  end 
   
   # called by is_redundant?    
  def criteria_matched_without_record( record )
    used_records = @used_records.clone  # don't want to actually alter instance variable
    used_records.delete( record )
    get_criteria( used_records )
  end 
  
  # called by analyze
  def supplement_chosen
    chosen = @unused_records.shuffle.take( @min_size )
    choose( chosen )
  end
end  