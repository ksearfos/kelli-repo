require 'lib/hl7/HL7'
require 'ListOfRecordMaps'

class RecordExtractor
  include HL7  
  
  attr_reader :records
  
  def initialize(files)
    @files = files
    @records = [] # magic happens!
  end
  
end