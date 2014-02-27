require "#{__FILE__}\\..\\hl7_utils.rb"
require "#{__FILE__}\\..\\HL7ProcsMod.rb"

# require all utility files, stored in [HEAD]/utilities
DEL = '\\'
pts = __FILE__.split( '/' )
pts.pop(2)
util_path = pts.join( DEL ) + DEL + 'utilities' 
util = Dir.new( util_path )   # all helper functions
util.entries.each{ |f| require util_path + DEL + f if f.include?( '.rb' ) }

class RecordComparer
  include HL7Procs
  
  @@CRITERIA = [ HL7Procs::OBX3, HL7Procs::PID1 ]
  @@TOTAL = @@CRITERIA.size
  @@HOW_MANY = 1      # minimum number of records we want returned, e.g. target size of @recs_to_use
  
  attr_reader :records, :high_recs, :high_score, :matches

  def initialize( recs )
    @criteria_by_rec = {}
    @high_recs = []   # these get reset during find_best(), but I want the values accessible
    @high_score = 0   #+ in-between calls, so I made them instance variables
    @matches = Array.new( @@TOTAL, false )   # tracks whether we've matched a record to each of the criteria
    @recs_to_use = []

    # populate @records, @criteria_by_rec
    @records = recs
    @records.each{ |rec|
      @criteria_by_rec[rec] = []                # add for all recs, but some will hold empty array
  
      @@CRITERIA.each{ |proc|
        ret = proc.call( rec )
        @criteria_by_rec[rec] << proc if ret   # if this criterion is met, record it
      } #each criterion
    } #each record

    @criteria_by_rec.remove_duplicate_values!   # don't search records that cover the same fields 
  end


  def analyze
    num_recs = @records.size
    if num_recs <= @@TOTAL            # we're going the need all the records
      @recs_to_use = @records.clone   # weird things happen if you don't clone an instance variable!
    else
      puts "Searching records..."
      find_me_some_records
      
      num_found = @recs_to_use.size
      needed = @@HOW_MANY - num_found             # number of records we still need
      if ( needed > 0 && num_found < num_recs )   # not enough records, and there are others
        r = @records.clone
        r.delete_if{ |rec| @recs_to_use.include?( rec ) }     # pool of unused records
        r.shuffle!
      
        @recs_to_use << r.take( needed )          # now we have enough records!
        @recs_to_use.flatten!
      end
    end
  end
  
  def show_records
    puts "We will use the following records:"
    @recs_to_use.each{ |rec|
      puts record_details( rec )
    }
  end
  
  def summarize
    puts "We have successfully matched #{how_many_found?} of #{@@TOTAL} criteria."
    puts "This will require a total of #{@recs_to_use.size} records:"
    @recs_to_use.each{ |r| puts "  #{record_id(r)}" }
  end
  
  private
  
  # finds all records to be used
  # doesn't return anything, but updates @recs_to_use with the records we decide we want
  def find_me_some_records
    until ( @criteria_by_rec.empty? || found_all? )   # either we're done, or we've run out of records
      find_best                                       # find record(s) that satisfy the most criteria   
      exit 1 if ( @high_recs.empty? || @high_score == 0 )    # something went horribly wrong, or there is no data

      to_delete = []              # will store a list of criteria that we have found a record for
      @high_recs.each{ |rec| 
        to_delete << @criteria_by_rec[rec]
        note_matches( rec )       # do some cleanup so we don't searh the same stuff again
      }
      
      # now to_delete contains a list of criteria that are met by the chosen records
      #+ rendering other records matching only those criteria, useless
      to_delete.flatten!.uniq!     # might be duplicates
      remove_useless_records( to_delete )
    end
  end
  
  # find records with highest "score"
  # which are the records meeting the greatest number of outstanding criteria
  # doesn't return anything, but sets @high_recs and @high_score
  def find_best
    @high_recs = []        # reset for new search
    @high_score = 0        # reset for new search

    @criteria_by_rec.each{ |rec,criteria|
      score = criteria.size
  
      if score == @high_score
        @high_recs << rec
      elsif score > @high_score
        @high_score = score
        @high_recs = [rec]
      end
    }
  end
  
  # updates @matches to identify everything we have matches for in given record
  # then removes record from list of records to look at
  # takes a single record to analyze
  def note_matches( rec )
    @criteria_by_rec[rec].each{ |crit|
      i = index( crit )
      @matches[i] = true   # found a match! 
    }
    
    @recs_to_use << rec 
    @criteria_by_rec.delete( rec )   # remove any records we have already decided to use
  end
  
  # removes any criteria we have met, so we don't keep trying to meet them
  #+  then removes any records that have no unmet criteria left
  # takes list of records whose criteria we want to remove
  def remove_useless_records( del )
    @criteria_by_rec.delete_if{ |_,criteria|
      criteria.delete_if{ |cr| del.include?( cr ) }   # after removing all criteria we've met...
      criteria.empty?                                 # ...are there any left for this record?
    }
  end
  
  # returns "number" (ID) of given proc in @@CRITERIA
  # this is conventiently also the index in @matches
  def index( proc )
    @@CRITERIA.index( proc )
  end
  
  # have we found at least one record for each criterion yet?
  def found_all?
    how_many_found? == @@TOTAL
  end
  
  def how_many_found?
    count = 0
    @matches.each{ |m| count += 1 if m }
    count          # number of criterion we have found a match for
  end
  
end #class  