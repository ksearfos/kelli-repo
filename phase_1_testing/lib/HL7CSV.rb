require 'CSV'
require 'lib/hl7module/HL7'

# really just exists to add methodology to treat HL7 objects
# as excel-writable
module HL7CSV
  
  extend HL7Test
  
  ADT_DETAILS = [ :PT_ID, :PT_NAME, :DOB, :PT_ACCT, :VISIT_DATE ]
  LAB_RAD_DETAILS = [ :PT_ID, :PT_NAME, :DOB, :PT_ACCT, :PROC_NAME, :PROC_DATE ]
  ADT_HEADER = [ "MRN", "PATIENT NAME", "DOB", "VISIT #", "VISIT DATE/TIME" ]
  LAB_RAD_HEADER = [ "MRN", "PATIENT NAME", "DOB", "ACCOUNT #", "PROCEDURE NAME", "DATE/TIME" ] 

  class HL7Test::Message    
    def to_row  
      dets = HL7CSV.get_details( @type )
      d = details( *dets )
      
      # theoretically, the next part is unnecessary, since dets.values should be in the desired order
      # but in case it isn't, since the return order matters....
      row = []
      dets.each{ |key| row << d[key] }
      row
    end
  end

  # requires array_of_rows that looks like [ [hdr1], [rec1], [rec2] ... ]     
  def self.make_spreadsheet_from_array( file, array_of_rows )
    sorted = HL7CSV.csv_sort( array_of_rows )
    open( file, "wb" ) do |csv|
      sorted.each{ |row| csv << row.to_csv }
    end
  end
    
  # requires string of rows, each row is comma-delimited (',') and the delimiter for each
  #+ line, if not "\n", is passed in as 3rd argument
  # e.g. "FOOD,COLOR,NUMBER\napple,blue,2\ncookies,red,7"
  # e.g. "FOOD,COLOR,NUMBER || apple,blue,2 || cookies,red,7" with " || " as extra arg   
  def self.make_spreadsheet_from_string( file, string, delim = "\n" )
    ary = []
    string.split(delim).each{ |line| ary << line.parse_csv }
    make_spreadsheet_from_array( file, ary )
  end
    
  # takes a list of HL7Test::Message files and prints them out as rows in a spreadsheet
  def self.record_to_spreadsheet( file, *recs )
    recs.flatten!(1)
    t = recs[0].type
    hdr = get_header( t )
    rows = [ hdr ]
    recs.each{ |rec| rows << rec.to_row }

    # now rows looks like [ [hdr1], [rec1], [rec2] ... ] 
    make_spreadsheet_from_array( file, rows )
  end
    
  def self.get_header( type )
    type == :adt ? ADT_HEADER : LAB_RAD_HEADER 
  end
  
  def self.get_details( type )
    type == :adt ? ADT_DETAILS : LAB_RAD_DETAILS     
  end
  
  def self.csv_sort( rows )
    # don't make any changes to actual rows object, just in case we want it intact later  
    hdr = rows.first
    r = rows[1..-1]
    r.sort_by!{ |_,name,_,num,visit_or_proc| [ name, num, visit_or_proc ] }
    [hdr] + r
  end
  
  def self.view_csv_array( ary )
    max_cols = ary.map{ |row| row.size }.sort.last
    widths = Array.new(max_cols){ 0 }
    sep = ' | '
    
    for i in 0...max_cols
      cols = ary.map{ |row| row[i] }
      cols.each{ |val| widths[i] = val.size if val.size > widths[i] }
    end
    
    sized_ary = []
    ary.each{ |row|
      sized_row = []
      for i in 0...max_cols
        sized_row << row[i].ljust(widths[i])
      end
      
      sized_ary << sized_row
    }
    
    sized_ary.each{ |row| puts row.join(sep) }
  end
end
