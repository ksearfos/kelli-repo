require_relative '../../classes/RecordCriteriaMap'
require_relative '../../classes/ListOfMaps'
# require 'classes/RecordComparer'

class TestRecordCriteriaMap < RecordCriteriaMap
  def initialize(criteria)
    @record = nil
    @criteria = criteria.to_set
  end
end

class TestListOfMaps < ListOfMaps
  def initialize(maps)
    @maps = maps.map(&:to_set)
  end
  
  def delete_if_redundant
    super(@maps.clone)
  end
  
  private
  
  def is_redundant?(map)
    other_maps = @maps.clone.delete(map)
    other_maps.each { |other_map| return true if map.subset?(other_map) }
    false
  end
end