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
  
  # as delete_redunancies, but puts @maps back how it was originally
  # this algorithm works the most neatly if you delete maps in-place, but we don't want to lose the original value
  def find_redundancies
    redundat_maps = []
    do_and_reset_maps { redundant_maps = @maps - maps_minus_redundancies }
    redundant_maps
  end
  
  def each
    @maps.each { |map| yeild(map) }
  end
  
  def select
    @maps.select { |map| yield(map) }
  end
  
  private

  def is_redundant?(map)
    other_list = ListOfMaps.new(@maps - [map])
    @matched_criteria == other_list.matched_criteria
  end
  
  def matched_criteria
    @maps.map(&:criteria).uniq
  end
  
  def maps_in_ascending_order
    @maps.sort { |map| map.criteria.size }
  end
  
  def remove_if_redundant(map)
    @maps.delete(map) if is_redundant?(map)
  end 
  
  def do_and_reset_maps(&block)
    original_maps = @maps.clone
    yield
    @maps = original_maps
  end
  
  def maps_minus_redundancies
    maps_in_ascending_order.each { |map| remove_if_redundant(map) }   # updates @maps directly!
  end
end