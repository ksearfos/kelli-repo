require_relative '../classes/RecordCriteriaMap'

class ListOfMaps
  attr_reader :matched_criteria
  
  def initialize(*maps)
    @maps = maps
    @maps.freeze      # make sure @maps is immutable!
    @matched_criteria = matched_criteria
  end
  
  def maps
    @maps.clone
  end

  def find_redundancies
    collect_redundancies
  end
  
  def each
    @maps.each { |map| yield(map) }
  end
  
  def select
    @maps.select { |map| yield(map) }
  end
  
  def size
    @maps.size
  end

  def take(amount)
    @maps.shuffle.take(amount)
  end  
  
  private
  
  def matched_criteria
    @maps.map(&:criteria).uniq
  end
  
  def maps_in_ascending_order
    @maps.sort { |map| map.criteria.size }
  end
  
  # this cannot be done with a simple @maps.collect(&:is_redundant?) --
  #+ whether a record is redundant or not depends on which other redundant records have
  #+ already been identified and removed from the list of records 
  def collect_redundancies(record_set = maps)    # not @maps; I want the clone
    redundancy = find_first_redundancy(record_set)
    redundancy ? [redundancy] + collect_redundancies(record_set - redundancy) : []
  end
  
  def find_first_redundancy(records)
    records.each { |record| return record if is_redundant?(record) }
    nil
  end
  
  def is_redundant?(map)
    other_list = ListOfMaps.new(@maps - [map])
    @matched_criteria == other_list.matched_criteria
  end
  
end