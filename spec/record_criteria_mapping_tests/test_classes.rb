require 'classes/RecordCriteriaMap'
require 'classes/ListOfMaps'

class TestRecordCriteriaMap < RecordCriteriaMap
  def initialize(criteria)
    @record = nil
    @criteria = determine_record_criteria(criteria)
  end
end