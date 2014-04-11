# passed testing 4/7
$LOAD_PATH.unshift File.expand_path("../../..", __FILE__)   # project directory
$LOAD_PATH.unshift File.dirname(__FILE__)
require 'spec_helper'
require 'shared_examples'

describe "RecordComparer" do

  before(:all) do
    @comparer = RecordComparer.new($messages.values, $criteria)
  end
  
  it_behaves_like "RecordComparer" do
    let(:comparer){ @comparer }
  end

end