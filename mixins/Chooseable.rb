module Chooseable
  def choose
    @used = true
  end
  
  def unchoose
    @used = false
  end
  
  def chosen?
    @used
  end
end