require 'spec_helper'

describe NameSplitter::Splitter do
    subject { NameSplitter::Splitter}

    it "should be able to split a name into first and last names" do
      @name = subject.new
      @name.name="Jimmy Johnson"
      @name.name.should == "Jimmy Johnson"
      @name.first_name.should == "Jimmy"
      @name.last_name.should == "Johnson"
    end

    it "should be able to split a name into first, middle and last_names" do
      @name = subject.new
      @name.name="Jimmy Berger Johnson II"
      @name.name.should == "Jimmy Johnson, II"
      @name.first_name.should == "Jimmy"
      @name.middle_name.should == "Berger"
      @name.last_name.should == "Johnson"
      @name.suffix.should == "II"
    end

     it "should be able to split a name into first, middle and last_names when last name includes a prefix" do
      @name = subject.new
      @name.name="Jimmy Berger van Hinton III"
      @name.name.should == "Jimmy van Hinton, III"
      @name.first_name.should == "Jimmy"
      @name.middle_name.should == "Berger"
      @name.last_name.should == "van Hinton"
      @name.suffix.should == "III"
    end

    it "should take a full name with a prefix and suffix on new and provide access to first middle etc. " do
      @name = subject.new("Jimmy Berger van Hinton III")
      @name.name.should == "Jimmy van Hinton, III"
      @name.first_name.should == "Jimmy"
      @name.middle_name.should == "Berger"
      @name.last_name.should == "van Hinton"
    end

    it "should take a full name with a prefix on new and provide access to first midddle etc. " do
      @name = subject.new("Maggie de Cuevas")
      @name.name.should == "Maggie de Cuevas"
      @name.first_name.should == "Maggie"
      @name.middle_name.should == ""
      @name.last_name.should == "de Cuevas"
    end

    it "should take a salutation and return it along with the rest of the name" do
      @name = subject.new("Miss Floura Flanders")
      @name.name.should == "Floura Flanders"
      @name.salutation.should == "Miss"
      @name.first_name.should == "Floura"
      @name.last_name.should == "Flanders"
      @name.middle_name.should == ""
    end

    it "salutations can include punctuation" do
      @name = subject.new("Mr. Tom Peterson")
      @name.salutation.should == "Mr."
    end

    it "should take on MD as a suffix" do
      @name = subject.new("John Farmer, Md")
      @name.name.should == "John Farmer, Md"
      @name.last_name.should == "Farmer"
      @name.suffix.should == "Md"
      @name.salutation.should == ""
    end

    it "should take a suffix with punctuation" do
      @name = subject.new("Same Barker, Ph.D.")
      @name.last_name.should == "Barker"
      @name.suffix.should == "Ph.D."
    end

    it "should handle a name with salutation, prefix and suffix" do
      @name = subject.new("Mr. Fred el Greco, III")
      @name.last_name.should == "el Greco"
      @name.name.should == "Fred el Greco, III"
    end

    it "should handle a name where the first name consists of two names" do
      @name = subject.new("Ms. Mary Beth Farmer")
      @name.last_name.should == "Farmer"
      @name.first_name.should == "Mary Beth"
    end

    it "should handle just a first name that is in two parts" do
      @name = subject.new("Mary Catherine")
      @name.first_name.should == "Mary Catherine"
      @name = subject.new("Mary Beth")
      @name.first_name.should == "Mary Beth"
    end

    it "should handle being passed just a single name" do
      @name = subject.new("Jimmy")
      @name.first_name.should == "Jimmy"
    end

    it "should place find the last name if the name consists of a salutation and one other name" do
      @name = subject.new("Mr. Martin")
      @name.last_name.should == "Martin"
      @name.name == "Martin"
    end

    it "should place both first names in the first name field if they are separated by an 'and'" do
      @name = subject.new("Janet and Tom Smith")
      @name.last_name.should == "Smith"
      @name.first_name.should == "Janet and Tom"
    end

     it "should not blow up if no parameter is included on new and attributes are accessed " do
      @name = subject.new
      @name.name.should == " "
      @name.first_name.should == ""
      @name.middle_name.should == ""
      @name.last_name.should == ""
    end


    describe ".call" do
      it "should call new with the passed parameter" do
        expect(NameSplitter::Splitter).to receive(:new).with("Joan of Arc")  
        NameSplitter::Splitter.call("Joan of Arc") 
      end      
    end


end
