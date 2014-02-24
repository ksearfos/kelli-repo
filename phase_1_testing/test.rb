require 'ruby-hl7'

# require all utility files, stored in [HEAD]/utilities
DEL = "\\"       # windows-style file path delimiter
pts = __FILE__.split( '/' )
pts.pop(2)
util_path = pts.join( DEL ) + DEL + 'utilities' 
util = Dir.new( util_path )   # all helper functions
util.entries.each{ |f| require util_path + DEL + f if f.include?( '.rb' ) }

FILE = "C:/Users/Owner/Documents/manifest_lab_in.txt"
SEGMENT = :PID
FIELD_DELIM = '|'
DIR_DELIM = '/'

puts get_hl7( FILE )
# puts break_into_records( msg )
