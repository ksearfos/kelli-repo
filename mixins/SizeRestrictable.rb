module SizeRestrictable 
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
  
  # the following methods must be defined for any including class:
  def size
    raise NotImplementedError
  end
  
  def add(amount) 
    raise NotImplementedError
  end
  
  def take_random(amount)
    raise NotImplementedError
  end

end