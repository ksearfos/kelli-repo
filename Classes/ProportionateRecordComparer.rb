require 'mixins/SeriesNonseriesSupport'
require 'classes/SizedRecordComparer'

# this class is very very similar to the RecordComparer, except that it takes into account the proportions
# of the SERIES encounters versus non-SERIES among the organiation and tries to give results that also fit
# these proportions
class OrgSensitiveRecordComparer < SizedRecordComparer
  
  def initialize(list_of_maps)
    super
  end
  
  def analyze
    super
    fix_proportions
  end
  
  private
  
  def fix_proportions
    amount = chosen_evaluator.amount_that_fixes_proportions(size_cap)
    unchosen_evaluator.take_from_correct_set(amount)
  end
  
  def size_cap
    size_cap = (chosen.size * 0.10).ceil   # don't add too many records - 10% is arbitrary
  end

  # add() method calls take, supplement() calls add(), and analyze() calls supplement()
  def take(amount)
    unchosen_evaluator.take_from_both_sets(amount)
  end
  
  # can't really use instance variables, since these will keep changing as records are chosen/unchosen
  def chosen_evaluator
    SeriesNonseriesSupport.make_new_evaluator(chosen)
  end
    
  def unchosen_evaluator
    SeriesNonseriesSupport.make_new_evaluator(unchosen)
  end
  
end  