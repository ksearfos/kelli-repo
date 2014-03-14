proj_dir = File.expand_path("../../",__FILE__)
require "#{proj_dir}/Record_Comparer/OHProcs.rb"

class RecordComparer
  include OHProcs
  
  attr_reader :records, :matches, :use, :recs_to_use

  @@details = [ :PT_NAME, :PT_ACCT, :PROC_NAME, :PROC_DATE ]
  
  def initialize( recs, type, min_results_size=1 )
    @records = recs                   # all records to be compared
    @min_size = min_results_size      # smallest number of records to return, 1 by default
    
    # items for tracking criteria
    @criteria = OHProcs.instance_variable_get( "@#{type}" )   # hash, :descriptive_symbol => {proc_to_call}
    @total = @criteria.size
    
    @unmatched = @criteria.keys
    @recs_to_search = {}             # will track which criteria each record meets
    
    # items for keeping track of preferred records
    @high_recs = []                   # these get reset during find_best(), but I want the values accessible
    @high_score = 0
    @recs_to_use = @use = []          # the list of records to look at

    assign_values                     # sets @recs_to_search to be { rec => [keys of all criteria met] }
    @recs_to_search.remove_duplicate_values!   # don't search records that cover the same fields 
  end
  
  def analyze
    # first, determine if we have to run through the algorithm at all
    # if we need all of the records we were given, go ahead and use the whole list
    num_recs = @records.size
    if num_recs <= @min_size           # we're going the need all the records
      puts "We will use all #{num_recs} records."
      @recs_to_use = @records.clone    # weird things happen if you don't clone an instance variable!
      return
    end
      
    # now look for records  
    puts "Searching #{num_recs} records for test cases...\n"  
    find_me_some_records

    # if that is not enough records, supplement with a random sample set
    num_found = @recs_to_use.size
    needed = @min_size - num_found              # number of records we still need
    
    if ( needed > 0 && num_found < num_recs )   # not enough records, and there are others
      @recs_to_use << pick_random(needed)
      @recs_to_use.flatten!
    end
    
    # now @recs_to_use has all the records we want, but some of these may be for the same person/encounter
    # so get rid of those
    @use = @recs_to_use.map{ |rec| fetch_details(rec) }
    @use.uniq!
  end
  
  def summary
    str = "I have successfully matched #{how_many_matches?} of #{@total} criteria, for a total of #{@use.size} records."
  end
  
  def unmatched  
    @unmatched.join( "\n" )
  end
  
  def matched
    m = @criteria.keys - @unmatched
    m.join( "\n" )  
  end
  
  def used_records
    str = ""
    @use.each{ |rec| str << record_details(rec) << "\n" }
    str
  end
  
  private
  
  def assign_values
    @records.each{ |rec|
      @recs_to_search[rec] = []      # add for all recs, but some will hold empty array
  
      @criteria.each{ |sym,proc|
        @recs_to_search[rec] << sym if proc.call( rec )  # if this criterion is met, record it
      } #each criterion
    } #each record
  end
  
  # finds all records to be used
  # doesn't return anything, but updates @recs_to_use with the records we decide we want
  def find_me_some_records
    until ( @recs_to_search.empty? || found_all? )  # until we have matched all criteria or run out of records...      
      # first, find the record(s) that cover the most criteria
      find_best      # find record(s) that satisfy the most criteria, updating @high_recs and @high_score   
      exit 1 if ( @high_recs.empty? || @high_score == 0 )    # nothing to analyze -- something went horribly wrong!

      # next, figure out which criteria those records meet, and record that we have matched them
      to_delete = []              # list of criteria we have found a record for, so we can stop searching for them
      @high_recs.each{ |rec| 
        to_delete << @recs_to_search[rec] 
        note_matches( rec )       # also deletes rec from @recs_to_search, so we don't look again
      }

      # lastly, remove useless records -- that is, records that do not contain un-matched criteria
      # will remove records that we don't need to use from @recs_to_search
      to_delete.flatten!.uniq!     # might be duplicates
      remove_useless_records( to_delete )
    end
  end
  
  # find records with highest "score" -- the records meeting the greatest number of (unmatched) criteria
  # doesn't return anything, but sets @high_recs and @high_score
  def find_best
    @high_recs = []        # reset for new search
    @high_score = 0        # reset for new search

    @recs_to_search.each{ |rec,criteria|
      score = criteria.size
  
      if score == @high_score
        @high_recs << rec
      elsif score > @high_score
        @high_score = score
        @high_recs = [rec]
      end
    }
  end
  
  # updates @unmatched to identify everything we have matches for in given record
  # then removes record from list of records to look at
  # takes a single record to analyze
  def note_matches( rec )
    @recs_to_use << rec 
    # return unless @recs_to_search.has_key?( rec )    # one of the duplicates that got removed, so no more to do
    @unmatched -= @recs_to_search[rec]    # matched all the criteria, so remove it so we don't look for it
    @recs_to_search.delete( rec )       # also, don't search this record again!
  end
  
  # removes any criteria we have met from the records' lists of matches; then remove any records with no other criteria
  # takes list of records whose criteria we want to remove
  def remove_useless_records( del )
    @recs_to_search.delete_if{ |_,criteria|           # for each record we want to search...
      criteria.delete_if{ |cr| del.include?( cr ) }   #+ remove all criteria we have met...
      criteria.empty?                                 #+ and remove the record if it has nothing else to offer
    }
  end
  
  # have we found at least one record for each criterion yet?
  def found_all?
    how_many_matches? == @total
  end
  
  def how_many_matches?
    @total - @unmatched.size      # total number of criteria, minus those we haven't matched yet
  end
  
  def fetch_details(rec)
    rec.details(@@details)
  end

  def pick_random( amt )
    r = @records.clone
    r -= @recs_to_use  # only take unchosen records
    r.shuffle!         # randomize!
    r.take( amt )
  end  
  
  def record_details(rec)
    str = <<STR
NAME: #{rec[:PT_NAME]}
ACCOUNT #: #{rec[:PT_ACCT]}
PROCEDURE: #{rec[:PROC_NAME]}
DATE/TIME: #{rec[:PROC_DATE]}
STR
    
    str
  end
end #class  