require "mixins/SizeRestrictable"

shared_examples SizeRestrictable do

  it "has a minimum size" do
    expect(object).to respond_to :minimum_size
  end

  describe "#set_size" do
    it "changes the minimum size" do
      object.set_size(4)
      expect(object.minimum_size).to eq(4)
    end
  end
  
  describe "#big_enough?" do
    before(:each) do
      object = double
      object.stub(:size) { 4 }
    end
    
    it "identifies objects that are the right size" do
      object.set_size(3)
      expect(object.big_enough?).to be_true
    end
    
    it "identifies objects that are too small" do
      object.set_size(6)
      expect(object.big_enough?).to be_false
    end
  end
  
  describe "#supplement" do
    it "adds elements to the including object until it is big enough" do
      object.set_size(3)
      object.supplement
      expect(object).to be_big_enough
    end
  end
  
  context "abstract methods" do
    describe "#size" do
      it "has been implemented" do
        expect { object.send(:size) }.not_to raise_exception
      end
    end
    
    describe "#add" do
      it "has been implemented" do
        expect { object.send(:add, 1) }.not_to raise_exception
      end
    end
    
    describe "#take" do
      it "has been implemented" do
        expect { object.send(:take, 1) }.not_to raise_exception
      end
    end
  end

end