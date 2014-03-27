require 'lib/OHmodule/OHProcs'

class RecordComparer
  include OHProcs
  
  attr_reader :records, :matches, :recs_to_use
  attr_writer :weight_method
  
  def initialize( recs, type, min_results_size=1 )
    @records_and_criteria = Hash.new_from_array( recs, [] )
    @unused_records = @records_and_criteria.keys
    @min_size = min_results_size      # smallest number of records to return
    @weight_method = Proc.new{ |records| records.shuffle.first }
    
    # items for tracking criteria
    @criteria = OHProcs.instance_variable_get( "@#{type}" )   # hash, :descriptive_symbol => {proc_to_call}
    @matched_criteria = []

    determine_record_criteria
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
    @records_and_criteria - @unused_records
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
      @records_and_criteria[record] = @criteria.select{ |name,proc| name if proc.call( record ) }
    }
  end  
  
  def find_me_some_records
    no_more_matches = false
    until @unused_records.empty? || @unmatched_criteria.empty? || no_more_matches
      score, matched_records = find_best 
      no_more_matches = ( score == 0 || matched_records.empty? )      
      choose = pick_most_important( matched_records )
      choose_records( choose )
    end
  end
  
  def find_best
    high_recs = []
    high_score = 0
    @records_and_criteria.each{ |rec,criteria|
      score = (criteria - @matched_criteria).size
  
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
      @matched_criteria << @records_and_criteria[record]
    }
    @matched_criteria.uniq!
  end
  
  def pick_random( amt )
    @unused_records.shuffle.take( amt )
  end  

  def pick_most_important( potentials )
    @weight_method.call( potentials )
  end
  
  def supplement_chosen
    num_found = chosen_size
    needed = @min_size - num_found                   # number of records we still need
    
    if ( needed > 0 && num_found < @records.size )   # not enough records, and there are others
      @unused_records -= pick_random( needed )
    end 
  end 

  def is_chosen?( record )
    !@unused_records.include?( record )
  end     

end  