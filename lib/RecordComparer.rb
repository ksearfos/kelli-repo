require 'lib/OHmodule/OHProcs'

class RecordComparer
  include OHProcs
  
  attr_reader :records, :matches, :recs_to_use
  attr_writer :weight_method
  
  def initialize( recs, type, min_results_size=1 )
    @records = @records_by_criteria = {}   # all records, tracking whether we are using them or not
    set_records( recs, false )
    @min_size = min_results_size      # smallest number of records to return
    @type = type
    @weight_method = Proc.new{ |records| records.shuffle.first }
    
    # items for tracking criteria
    @criteria_procs = OHProcs.instance_variable_get( "@#{type}" )   # hash, :descriptive_symbol => {proc_to_call}
    @criteria = @criteria_procs.clone.keys

    assign_values                     # sets @records_by_criteria to be { rec => [keys of all criteria met] }
    @records_by_criteria.remove_duplicate_values!   # don't search records that cover the same fields 
  end
  
  def analyze
    if @records.size <= @min_size   # we're going the need all the records
      set_records( @records.keys, true )
    else 
      find_me_some_records
      supplement_chosen unless found_enough?
    end 
  end

  def chosen
    rec_details = {}
    @records.each{ |record,used| rec_details[record] = record.to_row if used }
    rec_details.invert.values    # all records, minus those with duplicate sets of details  
  end  
  
  def summary
    str = "I have successfully matched #{match_size} of #{@criteria.size} criteria, for a total of #{chosen_size} records."
  end
  
  def get_unmatched  
    criteria = @criteria.clone
    criteria.delete_if{ |_,proc| proc.nil? }
    criteria.sort
  end
  
  def get_matched
    criteria = @criteria.clone
    criteria.keep_if{ |_,proc| proc.nil? }
    criteria.sort
  end
  
  private
  
  def assign_values
    @records.each_key{ |record|
      @records_by_criteria[record] = []      # add for all recs, but some will hold empty array  
      @criteria_procs.each{ |name,proc|
        @records_by_criteria[record] << name if proc.call( record )  # if this criterion is met, record it
      }
    }
  end
  
  # finds all records to be used
  # doesn't return anything, but updates @recs_to_use with the records we decide we want
  def find_me_some_records
    until ( @records_by_criteria.empty? || found_all? )  # until we have matched all criteria or run out of records...      
      score, records = find_best 
      break if score == 0 || records.empty?
      
      chose = pick_most_important( records )
      note_chosen( chose )
    end
  end
  
  # find records with highest "score" -- the records meeting the greatest number of (unmatched) criteria
  # doesn't return anything, but sets @high_recs and @high_score
  def find_best
    high_recs = []        # reset for new search
    high_score = 0        # reset for new search

    @records_by_criteria.each{ |rec,criteria|
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
  
  # updates @unmatched to identify everything we have matches for in given record
  # then removes record from list of records to look at
  # takes a single record to analyze
  def note_chosen( records )
    records.each{ |record|
      @records[record] = true   # mark that we are using this one
      remove_matched_criteria( @records_by_criteria[record] )
      @records_by_criteria.delete( record )   # don't search this record again
    }
  end
  
  # removes any criteria we have met from the records' lists of matches; then remove any records with no other criteria
  # takes list of records whose criteria we want to remove
  def remove_matched_criteria( criteria )
    criteria.each{ |criterion| @criteria_procs.delete( criterion ) }   # mark that we've satisfied it
    @records.keys.each{ |record| @records_by_criteria[record] -= criteria }
  end
  
  # have we found at least one record for each criterion yet?
  def found_all?
    how_many_matches? == @total
  end
  
  def how_many_matches?
    @total - @unmatched.size      # total number of criteria, minus those we haven't matched yet
  end
  
  def pick_random( amt )
    r = @records.clone
    r -= @recs_to_use  # only take unchosen records
    r.shuffle!         # randomize!
    r.take( amt )
  end  

  def pick_most_important( potentials )
    @weight_method.call( potentials )
  end
  
  def set_records( keys, value )
    @records = Hash[ keys.collect{ |rec| [rec,value] } ]
  end
  
  def supplement_chosen
    num_found = chosen_size
    needed = @min_size - num_found                   # number of records we still need
    
    if ( needed > 0 && num_found < @records.size )   # not enough records, and there are others
      add = pick_random(needed)
      add.each{ |record| @records[record] = true }
    end 
  end

  def found_enough?
    @min_size <= chosen_size
  end  
  
  def chosen_size
    count = 0
    @records.each_value{ |true_false| count += 1 if true_false }
    count
  end
     
end #class  