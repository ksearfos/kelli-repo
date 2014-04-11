module SizeRequired
  def initialize_min_size
    @min_size = 1
    @starting_value_setters << proc { @min_size = 1 }
  end
  
  def set_size(size)
    @min_size = size
  end
  
  def big_enough?
    amount_short <= 0
  end
  
  def amount_short
    @min_size - size
  end
  
  def supplement
    return if big_enough?
    add(amount_short)
  end
end
  
class RecordComparer
  include SizeRequired
  
  private
  
  def size
    chosen.size
  end
  
  def add(amount) 
    to_add = ListOfMaps.new(random_unchosen_maps(amount))
    choose(to_add)
  end
  
  def random_unchosen_maps(amount)
    unchosen.shuffle.take(amount)
  end
  
end