# last tested 4/15
require 'classes/RecordCriteriaMap'
require 'lib/extended_base_classes'

class ListOfMaps
  attr_reader :criteria
  
  def initialize(*maps)
    @maps = maps
    @maps.freeze      # make sure @maps is immutable!
    @criteria = matched_criteria
  end
  
  def maps
    @maps.clone
  end

  def find_redundancies
    collect_duplicates + collect_redundancies(maps_in_ascending_order)
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
    @maps.map(&:criteria).flatten.uniq.sort
  end
  
  def maps_in_ascending_order
    @maps.uniq.sort { |map| map.criteria.size }
  end
  
  # when properly written collect_redundancies will also identify duplicates...
  # but it turns out the logic for collect_redundancies is a LOT simpler if you don't have
  #+ to deal with identical elements
  def collect_duplicates
    @maps.find_duplicates
  end
  
  # this cannot be done with a simple @maps.collect(&:is_redundant?) --
  #+ whether a record is redundant or not depends on which other redundant records have
  #+ already been identified and removed from the list of records 
  def collect_redundancies(record_set)
    redundancy = find_first_redundancy(record_set)
    redundancy ? [redundancy] + collect_redundancies(record_set.remove(redundancy)) : []
  end
  
  def find_first_redundancy(set_of_maps)  
    set_of_maps.each { |map| return map if criteria_is_the_same(set_of_maps.remove(map)) }
    nil
  end
  
  def criteria_is_the_same(different_set_of_maps)
    other_list = ListOfMaps.new(*different_set_of_maps)
    @criteria.sort == other_list.criteria.sort
  end
  
end