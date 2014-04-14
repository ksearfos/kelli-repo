require 'mixins/SeriesNonseriesSupport'
require 'classes/RecordComparer'

# this class is very very similar to the RecordComparer, except that it takes into account the proportions
# of the SERIES encounters versus non-SERIES among the organiation and tries to give results that also fit
# these proportions
class OrgSensitiveRecordComparer < RecordComparer
  include SeriesNonseriesSupport
  
  def initialize(list_of_maps)
    super
  end
  
  def analyze
    super
    fix_proportions
  end
  
  private
  
  def fix_proportions
    add(chosen_evaluator.take_minimum(size_cap))
  end
  
  def size_cap
    size_cap = (chosen.size * 0.10).ceil   # don't add too many records - 10% is arbitrary
  end

  # add method calles take_random
  def take_random(amount)
    unchosen_evaluator.take_proportionately(amount)
  end
  
  # can't really use instance variables, since these will keep changing as records are chosen/unchosen
  def chosen_evaluator
    SeriesNonseriesSupport.instantiate_proportion(chosen)
  end
    
  def unchosen_evaluator
    SeriesNonseriesSupport.instantiate_proportion(unchosen)
  end
  
end  