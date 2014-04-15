require 'mixins/SizeRestrictable'
require 'classes/RecordComparer'

class SizedRecordComparer < RecordComparer
  include SizeRestrictable  
  
  attr_reader :minimum_size
  
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
    choose(take_random(amount))
  end
  
  def take_random(amount)
    unchosen.shuffle.take(amount)
  end
  
end  