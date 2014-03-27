def get_hl7( file )
  File.open( file ) { |f|
    f.gets.chop     # blank lines cause ParsingErrors
  }
end

# returns array of strings containing hl7 message of individual records
# does NOT return HL7::Message objects!
def break_into_records( hl7 )
  hdr = /\d+MSH/             #regex defining header row
  m = hl7.match( hdr )       # all headers (will be needed later)
  recs = hl7.split( hdr )    # split across headers, yielding individual records
  
  all_recs = []
  for i in 0...m.size
    all_recs << m[i] + recs[1]
  end
  
  all_recs
end
