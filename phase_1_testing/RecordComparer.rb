# last updated 2/28/14 3:22pm

require "./HL7ProcsMod.rb"

# require all utility files, stored in phase_1_testing/lib
util_path = File.dirname( __FILE__ ) + "/lib"
util = Dir.new( util_path )   # all helper functions
util.entries.each{ |f| require util_path + "/" + f if f.include?( '.rb' ) }

class RecordComparer
  include HL7Procs
  
  @@CRITERIA = HL7Procs::LAB_CRITERIA
  @@CRITERIA_BY_NAME = %w[ EVENT, T_ID, ID_23, P_ID, ID_24, ATT, REF, TX_TYPE, SN_TYPE, NM_TYPE, OBS_ID, TX_VAL,
                   NM_VAL, SN_VAL, UNITS, REF_RG, FLAG_H, FLAG_I, FLAG_CH, FLAG_CL, FLAG_L, FLAG_A, FLAG_U,
                   FLAG_N, FLAG_C, PT_ID, NAME, DOB, SEX_M, SEX_F, SEX_O, VISIT_ID, SSN, ORD_NUM, SER_ID,
                   ORD_DT, ORD_MD, RES_ST_F, RES_ST_I, RES_ST_C, RES_ST_P, ATT_EQ_REF ]
  @@TOTAL = @@CRITERIA.size
  @@HOW_MANY = 1      # minimum number of records we want returned, e.g. target size of @recs_to_use
  
  attr_reader :records, :matches, :recs_to_use, :people_to_use

  def initialize( recs, passing_cases = true )
    @criteria_by_rec = {}
    @high_recs = []   # these get reset during find_best(), but I want the values accessible
    @high_score = 0   #+ in-between calls, so I made them instance variables
    @matches = Array.new( @@TOTAL, false )   # tracks whether we've matched a record to each of the criteria
    @recs_to_use = @people_to_use = []
    @want_success = passing_cases

    # populate @records, @criteria_by_rec
    @records = recs
    assign_values
    @criteria_by_rec.remove_duplicate_values!   # don't search records that cover the same fields 
  end

  def popular
    find_most_popular
  end
  
  def analyze
    @recs_to_use = []                   # reset, in case we want to run this again
    
    num_recs = @records.size
    if num_recs <= @@HOW_MANY           # we're going the need all the records
      puts "We will use all #{num_recs} records."
      @recs_to_use = @records.clone     # weird things happen if you don't clone an instance variable!
    else     
      if @want_success
        #find person who appears the most, and definitely choose him
        puts "\nFinding patient appearing in the most messages..."
        find_most_popular
      end
      
      sleep 1
      print "Searching #{num_recs} records for "
      print @want_success ? "positive" : "negative"
      puts " test cases..."
      
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
    
    # now @recs_to_use has all the records we want, but some of these may be for the same person/encounter
    # so get rid of those
    pts = @recs_to_use.map{ |rec| rec = pt_enc_details( rec ) }   # pts = [ {info}, {info}, ... ]
    @people_to_use = pts.uniq
    sleep 2
  end

  def list_patients
    puts "We will check the following patients:"
    @people_to_use.each{ |pt| puts pt }
  end
    
  def list_records
    puts "We will use the following records:"
    @recs_to_use.each{ |rec|
      puts record_details( rec )
    }
  end
  
  def summarize( verbose = false )
    print "\nWe have found "
    print @want_success ? "positive" : "negative"
    puts " matches for #{how_many_found?} criteria."
    sleep 1
    
    if verbose
      puts "The unmatched criteria are:"
      i = 0
      while i < @@TOTAL
        puts "  " + @@CRITERIA_BY_NAME[i].chomp(',') unless @matches[i]
        i += 1
      end
      
      puts ""
      sleep 1
    end
    
    print "This will require a total of #{@people_to_use.size} patient records"
    puts verbose ? ":" : "."
    
    if verbose
      @people_to_use.each{ |pt| puts "  MRN: #{pt[:ID]}" }
      sleep 1
    end
  end
  
  private
  
  def assign_values
    @records.each{ |rec|
      @criteria_by_rec[rec] = []                # add for all recs, but some will hold empty array
  
      @@CRITERIA.each{ |proc|
        ret = proc.call( rec )
        
        if @want_success
          @criteria_by_rec[rec] << proc if ret   # if this criterion is met, and that's what we want, record it
        else
          @criteria_by_rec[rec] << proc if !ret  # if criterion is not met, and we want negative cases, record it
        end
      } #each criterion
    } #each record
  end
  
  # finds patient who occurs the most in the list of records
  # definitely choose him, since there is lots of data to look at there
  # go ahead and remove him from the list afterward, so we don't choose him again
  # modifies @recs_to_use/@criteria_by_record/@matches by calling note_matches()
  def find_most_popular
    rec_to_id = {}                             # { rec1 => pt_id, rec2 => pt_id ... }

    @records.each{ |r|
      id = r[:PID][0].e3.before( "^" )         # patient_id
      rec_to_id[r] = id
    }
    
    id_counts = {}
    id_counts.add_keys( 0, rec_to_id.values.uniq )    # now id_counts is { id => 0, id2 => 0 ... }
    rec_to_id.values.each{ |id| id_counts[id] += 1 }
    big = id_counts.values.sort[-1]                   # highest count, e.g. patient who comes up the most

    id_counts.keep_if{ |_,ct| ct == big }             # all patient ids linked to that big count
    ids = id_counts.keys.uniq

    rec_to_id.keep_if{ |_,id| ids.include?( id ) }    # all records referring to one of those patients
    rec_to_id.each_key{ |rec| note_matches( rec ) }
  end
  
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
    @recs_to_use << rec 
    return unless @criteria_by_rec.has_key?( rec )     # one of the duplicates that got removed, so no more to do
    
    @criteria_by_rec[rec].each{ |crit|
      i = index( crit )
      @matches[i] = true   # found a match! 
    }

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