# last tested 4/15
require 'classes/ListOfMaps'

class RecordComparer 
  attr_reader :list_of_maps
  
  def initialize(list_of_maps)
    @list_of_maps = list_of_maps 
    set_starting_values   
  end
  
  def analyze    
    unchoose(@list_of_maps.find_redundancies) 
  end
  
  def chosen
    @list_of_maps.maps.select(&:chosen?)
  end  
  
  def unchosen
    @list_of_maps.maps.select { |map| !map.chosen? }
  end
  
  def summary
    "I have successfully matched #{matched.size} criteria, for a total of #{chosen.size} records."
  end
  
  def matched
    @list_of_maps.matched_criteria
  end
  
  def reset
    set_starting_values
  end
  
  private

  def unchoose(list)
    list.each(&:unchoose)
  end

  def choose(list)
    list.each(&:choose)
  end

  def set_starting_values
    choose(@list_of_maps.maps)
  end
  
end  