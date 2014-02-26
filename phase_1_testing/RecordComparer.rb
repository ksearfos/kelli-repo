require "#{__FILE__}\\..\\hl7_utils.rb"

# require all utility files, stored in [HEAD]/utilities
DEL = "\\"       # windows-style file path delimiter
pts = __FILE__.split( '/' )
pts.pop(2)
util_path = pts.join( DEL ) + DEL + 'utilities' 
util = Dir.new( util_path )   # all helper functions
util.entries.each{ |f| require util_path + DEL + f if f.include?( '.rb' ) }

class RecordComparer
  @@IMPORTANT_FIELDS = [ "msh9", "pid3", "obx3" ]
  @@IMPT_NUM = @@IMPORTANT_FIELDS.size
  @@HOW_MANY = 2

  # @rec_by_field = {}
  # @field_by_rec = {}
  # @recs = []
  # @high_rec = nil
  # @high_score = 0
  # @matches = Array.new( @@IMPT_NUM, 0 )   # number of records containing the field we have found so far

  def initialize( recs )
    @rec_by_field = {}
    @field_by_rec = {}
    @high_rec = nil
    @high_score = 0
    @matches = Array.new( @@IMPT_NUM, 0 )   # number of records containing the field we have found so far
    
    # populate @field_by_rec
    @@IMPORTANT_FIELDS.each{ |f| @field_by_rec[f] = [] }

    # populate @recs, @rec_by_field
    @recs = recs
    @recs.each{ |rec|
      @rec_by_field[rec] = []      # add for all recs, but some will hold empty array
  
      @@IMPORTANT_FIELDS.each{ |field|
        res = rec.fetch_field( field )   # array of all matches
    
        if ( res.has_value? )            # this has one of the important fields, so link the field and the record
          @rec_by_field[rec] << field
          @field_by_rec[field] << rec
        end
      } #each field
    } #each record
  end

  # find record with highest "score"
  # which is the record with the greatest number of unmatches fields
  def find_best
    # reset count!
    @high_rec = nil
    @high_score = 0
    
    @rec_by_field.each{ |r,fields|
      fields.keep_if{ |f| 
        idx = @field_by_rec.keys.index( f )  # which field is this?
        @matches[idx] < @@HOW_MANY           # get rid of any fields that we've finished up
      }
      score = fields.size
  
      if score > @high_score
        @high_score = score
        @high_rec = r
      end
    
      @high_rec
    }
  end

  def summarize
    puts "rec #{record_id(@high_rec)} has the high score, matching #{@high_score} of #{@@IMPT_NUM} fields" 
    puts ""
    puts "rec_by_field: "
    @rec_by_field.each{ |r,f| puts record_id(r) + ": " + f.size.to_s }
    puts ""
    puts "field_by_rec: "
    @field_by_rec.each{ |f,r| puts f + ": " + r.size.to_s }
  end
end #class  
=begin
highest scoring records
take it
cross off any other fields covered in those recs
next highest scoring--higher priority given to any that contain the most unmatched fields
pare down to remove duplicates/already checked
repeat

recs_by_field = { rec => [fields] }
fields_by_rec = { field => [recs] }
"ranking" = size of value
=end