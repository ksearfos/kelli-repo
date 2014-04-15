require 'mixins/SizeRestrictable'
require 'classes/RecordComparer'

class SizedRecordComparer < RecordComparer
  include SizeRestrictable  
  
  def initialize(list_of_maps)
    super  
  end
  
  def analyze    
    super
    supplement
  end
  
  private

  def set_starting_values
    super
    set_size(1)
  end
  
  def size
    chosen.size
  end
  
  def add(amount) 
    choose(take(amount))
  end
  
  def take(amount)
    unchosen.shuffle.take(amount)
  end
  
end  