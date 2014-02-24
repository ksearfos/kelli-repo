require 'ruby-hl7'
require "C:/Users/Owner/Documents/Ruby code/Test/Test/RSpec/spec/test/utility_methods.rb"

FILE = "C:/Users/Owner/Documents/manifest_lab_in_shortened.txt"
SEGMENT = :PID
FIELD_DELIM = '|'

txt = get_hl7( FILE )
msg = HL7::Message.new( txt )
msg.view_children