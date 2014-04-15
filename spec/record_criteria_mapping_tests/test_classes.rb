require 'classes/RecordCriteriaMap'
require 'classes/ListOfMaps'

class TestRecordCriteriaMap < RecordCriteriaMap
  def initialize(criteria)
    @record = nil
    @criteria = determine_record_criteria(criteria)
  end
end

class TestListOfMaps < ListOfMaps
  def initialize(maps)
    @maps = maps.map(&:to_set)
  end
end