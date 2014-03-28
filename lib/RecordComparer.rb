require 'lib/OHmodule/OHProcs'

class RecordComparer
  include OHProcs
  
  attr_reader :records, :matches, :recs_to_use
  attr_writer :weight_method
  
  def initialize( recs, type, min_results_size=1 )
    @records_and_criteria = Hash.new_from_array( recs, [] )
    @unused_records = recs
    @min_size = min_results_size      # smallest number of records to return
    @weight_method = Proc.new{ |records| records.shuffle }
    
    # items for tracking criteria
    @criteria = OHProcs.instance_variable_get( "@#{type}" )   # hash, :descriptive_symbol => {proc_to_call}
    @matched_criteria = []

    determine_record_criteria
    @records_and_criteria.remove_duplicate_values!
  end
  
  def analyze
    if @records_and_criteria.size <= @min_size
      @unused_records = []       # chose them all
    else 
      find_me_some_records
      supplement_chosen if chosen.size < @min_size
    end 
  end

  def chosen
    @records_and_criteria.keys - @unused_records
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
  
  def determine_record_criteria
    @records_and_criteria.each_key{ |record|
      @records_and_criteria[record] = passing_criteria( record )
    }
  end  
  
  def passing_criteria(record)
    passed = []
    @criteria.each{ |name,proc| passed << name if proc.call( record ) }
    passed  
  end
  
  def find_me_some_records
    no_more_matches = false
    
    until using_all_records || no_unmatched_criteria || no_more_matches
      score, matched_records = find_best 
      no_more_matches = ( score == 0 || matched_records.empty? )      
      choose = pick_most_important( matched_records )
      choose_records( [choose.first] )   # removes records from @unused_records and adds criteria to @matched_criteria
    end
  end
  
  def find_best
    high_recs = []
    high_score = 0
    @records_and_criteria.each{ |rec,criteria|
      score = criteria.size
  
      if score == high_score
        high_recs << rec
      elsif score > high_score
        high_score = score
        high_recs = [rec]
      end
    }
    
    [ high_score, high_recs ] 
  end
  
  def choose_records( records )
    records.each{ |record|
      @unused_records.delete( record )
      @matched_criteria += @records_and_criteria[record]
      @records_and_criteria.delete( record )
    }
    remove_matched_criteria
  end

  def remove_matched_criteria
    @records_and_criteria.each_key{ |record| @records_and_criteria[record] -= @matched_criteria }  
  end
    
  def pick_random( amt )
    @unused_records.shuffle.take( amt )
  end  

  def pick_most_important( potentials )
    @weight_method.call( potentials )
  end
  
  def supplement_chosen
    num_found = chosen.size
    needed = @min_size - num_found                          # number of records we still need
    
    if ( needed > 0 && num_found < @unused_records.size )   # not enough records, and there are others
      @unused_records -= pick_random( needed )
    end 
  end 

  def is_chosen?( record )
    !@unused_records.include?( record )
  end     

  def no_unmatched_criteria
    @matched_criteria.size == @criteria.size
  end

  def using_all_records
    @unused_records.empty?
  end  
  
end  