require "mixins/Chooseable"

shared_examples Chooseable do
  it "can be selected" do
    object.choose
    expect(object).to be_chosen
  end
  
  it "can be de-selected" do
    object.unchoose
    expect(object).not_to be_chosen
  end
end