# last tested 4/7

class RecordComparer
  
  def initialize(list_of_maps)
    @list_of_maps = list_of_maps
    @starting_value_setters = [proc { choose(@list_of_maps) }]    # start with all maps "chosen" 
    set_starting_values   
  end
  
  def analyze    
    redundancies = ListOfMaps.new(@list_of_maps.find_redundancies)
    unchoose(redundancies) 
  end
  
  def chosen
    @list_of_maps.select(&:chosen?)
  end  
  
  def unchosen
    @list_of_maps.select { |map| !map.chosen? }
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
    @starting_value_setters.each { |setter| setter.call }
  end
end  