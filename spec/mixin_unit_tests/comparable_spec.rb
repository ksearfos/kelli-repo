shared_examples Comparable do
  describe "#<=>" do
    it "is defined" do
      expect(object).to respond_to(:<=>)
    end
  end
  
  describe "#==" do
    context "when given an object of equivalent value" do
      it "is true" do
        expect(object == equal_object).to be_true
      end
    end
    
    context "when given an object of unequivalent value" do
      it "is false" do
        expect(object == unequal_object).to be_false
      end
    end
  end
  
  describe "#<" do
    context "when given an object of greater value" do
      it "is true" do
        expect(object < larger_object).to be_true
      end
    end
    
    context "when given an object of equal value" do
      it "is false" do
        expect(object < equal_object).to be_false
      end
    end
    
    context "when given an object of lesser value" do
      it "is false" do
        expect(object < smaller_object).to be_false
      end
    end
  end

  describe "#>" do
    context "when given an object of greater value" do
      it "is false" do
        expect(object > larger_object).to be_false
      end
    end
    
    context "when given an object of equal value" do
      it "is false" do
        expect(object > equal_object).to be_false
      end
    end
    
    context "when given an object of lesser value" do
      it "is true" do
        expect(object > smaller_object).to be_true
      end
    end
  end
  
  describe "#<=" do
    context "when given an object of greater value" do
      it "is true" do
        expect(object <= larger_object).to be_true
      end
    end
    
    context "when given an object of equal value" do
      it "is true" do
        expect(object <= equal_object).to be_true
      end
    end
    
    context "when given an object of lesser value" do
      it "is false" do
        expect(object <= smaller_object).to be_false
      end
    end
  end
  
  describe "#>=" do
    context "when given an object of greater value" do
      it "is false" do
        expect(object >= larger_object).to be_false
      end
    end
    
    context "when given an object of equal value" do
      it "is true" do
        expect(object >= equal_object).to be_true
      end
    end
    
    context "when given an object of lesser value" do
      it "is true" do
        expect(object >= smaller_object).to be_true
      end
    end
  end
end