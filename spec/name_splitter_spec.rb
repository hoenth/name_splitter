require 'spec_helper'

RSpec.describe NameSplitter::Splitter do
  subject { NameSplitter::Splitter }

  it "splits a name into first and last names" do
    name = subject.new
    name.name = "Jimmy Johnson"
    expect(name.name).to eq("Jimmy Johnson")
    expect(name.first_name).to eq("Jimmy")
    expect(name.last_name).to eq("Johnson")
  end

  it "splits a name into first, middle, and last names" do
    name = subject.new
    name.name = "Jimmy Berger Johnson II"
    expect(name.name).to eq("Jimmy Johnson, II")
    expect(name.first_name).to eq("Jimmy")
    expect(name.middle_name).to eq("Berger")
    expect(name.last_name).to eq("Johnson")
    expect(name.suffix).to eq("II")
  end

  it "splits a name into first, middle, and last names when last name includes a prefix" do
    name = subject.new
    name.name = "Jimmy Berger van Hinton III"
    expect(name.name).to eq("Jimmy van Hinton, III")
    expect(name.first_name).to eq("Jimmy")
    expect(name.middle_name).to eq("Berger")
    expect(name.last_name).to eq("van Hinton")
    expect(name.suffix).to eq("III")
  end

  it "takes a full name with a prefix and suffix on new and provides access to first, middle, etc." do
    name = subject.new("Jimmy Berger van Hinton III")
    expect(name.name).to eq("Jimmy van Hinton, III")
    expect(name.first_name).to eq("Jimmy")
    expect(name.middle_name).to eq("Berger")
    expect(name.last_name).to eq("van Hinton")
  end

  it "takes a full name with a prefix on new and provides access to first, middle, etc." do
    name = subject.new("Maggie de Cuevas")
    expect(name.name).to eq("Maggie de Cuevas")
    expect(name.first_name).to eq("Maggie")
    expect(name.middle_name).to eq("")
    expect(name.last_name).to eq("de Cuevas")
  end

  it "takes a salutation and returns it along with the rest of the name" do
    name = subject.new("Miss Floura Flanders")
    expect(name.name).to eq("Floura Flanders")
    expect(name.salutation).to eq("Miss")
    expect(name.first_name).to eq("Floura")
    expect(name.last_name).to eq("Flanders")
    expect(name.middle_name).to eq("")
  end

  it "takes 2 salutations separated by & or 'and' and places them both in the salutation field" do
    name = subject.new("Mr. and Mrs. Jimmy Flanders")
    expect(name.salutation).to eq("Mr. and Mrs.")
    expect(name.first_name).to eq("Jimmy")
    expect(name.last_name).to eq("Flanders")

    name = subject.new("Mr. & Mrs. Jimmy Flanders")
    expect(name.salutation).to eq("Mr. & Mrs.")
    expect(name.first_name).to eq("Jimmy")
    expect(name.last_name).to eq("Flanders")

    name = subject.new("Mr. & Mrs. Jimmy and Beth Flanders")
    expect(name.salutation).to eq("Mr. & Mrs.")
    expect(name.first_name).to eq("Jimmy and Beth")
    expect(name.last_name).to eq("Flanders")
  end

  it "allows salutations to include punctuation" do
    name = subject.new("Mr. Tom Peterson")
    expect(name.salutation).to eq("Mr.")
  end

  it "takes on MD as a suffix" do
    name = subject.new("John Farmer, Md")
    expect(name.name).to eq("John Farmer, Md")
    expect(name.last_name).to eq("Farmer")
    expect(name.suffix).to eq("Md")
    expect(name.salutation).to eq("")
  end

  it "takes a suffix with punctuation" do
    name = subject.new("Same Barker, Ph.D.")
    expect(name.last_name).to eq("Barker")
    expect(name.suffix).to eq("Ph.D.")
  end

  it "handles a name with salutation, prefix, and suffix" do
    name = subject.new("Mr. Fred el Greco, III")
    expect(name.last_name).to eq("el Greco")
    expect(name.name).to eq("Fred el Greco, III")
  end

  it "handles a name where the first name consists of two names" do
    name = subject.new("Ms. Mary Beth Farmer")
    expect(name.last_name).to eq("Farmer")
    expect(name.first_name).to eq("Mary Beth")
  end

  it "handles just a first name that is in two parts" do
    name = subject.new("Mary Catherine")
    expect(name.first_name).to eq("Mary Catherine")

    name = subject.new("Mary Beth")
    expect(name.first_name).to eq("Mary Beth")
  end

  it "handles being passed just a single name" do
    name = subject.new("Jimmy")
    expect(name.first_name).to eq("Jimmy")
  end

  it "finds the last name if the name consists of a salutation and one other name" do
    name = subject.new("Mr. Martin")
    expect(name.last_name).to eq("Martin")
    expect(name.name).to eq("Mr. Martin")
  end

  it "places both first names in the first name field if they are separated by an 'and'" do
    name = subject.new("Janet and Tom Smith")
    expect(name.last_name).to eq("Smith")
    expect(name.first_name).to eq("Janet and Tom")
  end

  it "recognizes a suffix even if it has multiple punctuation marks" do
    name = subject.new("Jim Smith M.D.")
    expect(name.last_name).to eq("Smith")
    expect(name.first_name).to eq("Jim")
    expect(name.suffix).to eq("M.D.")
  end

  it "does not blow up if no parameter is included on new and attributes are accessed" do
    name = subject.new
    expect(name.name).to eq("")
    expect(name.first_name).to eq("")
    expect(name.middle_name).to eq("")
    expect(name.last_name).to eq("")
  end

  it "properly places last name when the name has only salutation and last name for Mr. & Mrs. Stoll" do
    name = subject.new("Mr. & Mrs. Stoll")
    expect(name.last_name).to eq("Stoll")
  end

  it "puts multiple names in the first name field if they are anded" do
    name = subject.new("Mr. & Mrs. Jimmy Smith and Beth Flanders")
    expect(name.salutation).to eq("Mr. & Mrs.")
    expect(name.first_name).to eq("Jimmy Smith and Beth")
    expect(name.last_name).to eq("Flanders")
  end

  context 'when the last name is listed first with a comma' do
    let(:split_name) { described_class.new(full_name) }

    context "and no format option is provided" do
      context "and nothing other than the first name is provided" do
        let(:full_name) { "Smith, Jim" }

        it "correctly places the names in the first and last name fields" do
          expect(split_name.last_name).to eq("Smith")
          expect(split_name.first_name).to eq("Jim")
        end
      end

      context "and a middle name is provided" do
        it "correctly places the names in the first and last name fields" do  
          name = subject.new("Smith, Jim C.")
          expect(name.last_name).to eq("Smith")
          expect(name.first_name).to eq("Jim")
          expect(name.middle_name).to eq("C.")
        end
      end

      context "and a second person is provided along with a suffix" do
        it "correctly places the names in the first and last name fields" do  
          name = subject.new("Bedard, Sheryl A. & Louis J. Jr.")
          expect(name.last_name).to eq("Bedard")
          expect(name.first_name).to eq("Sheryl A. & Louis J.")
          expect(name.suffix).to eq("Jr.")
        end
      end

      context "and multiple middle names are provided" do
        it "correctly places the names in the first and last name fields, etc" do
          name = subject.new("Bedard, John Samuel Benning")
          expect(name.last_name).to eq("Bedard")
          expect(name.first_name).to eq("John")
          expect(name.middle_name).to eq("Samuel Benning")  
        end
      end

      context "and no space separating the comma and the first name" do
        it "does not quite work properly, as we expect to split on a space" do
          name = subject.new("Smith,Jim")
          expect(name.first_name).to eq("Smith,Jim")
          expect(name.last_name).to eq("")
        end
      end
    end

    context "and the last_first format option is provided" do
      # Add tests for last_first format option if needed
    end

    context 'and also includes salutations' do
      it "correctly places the names in the first and last name and salutation fields" do
        name = subject.new("Smith, Mr. Jim")
        expect(name.last_name).to eq("Smith")
        expect(name.first_name).to eq("Jim")
        expect(name.salutation).to eq("Mr.")

        name = subject.new("Smith, Mr. & Mrs. Jim")
        expect(name.last_name).to eq("Smith")
        expect(name.first_name).to eq("Jim")
        expect(name.salutation).to eq("Mr. & Mrs.")

        name = subject.new("Smith, Mr. & Mrs. Jim & Janet")
        expect(name.last_name).to eq("Smith")
        expect(name.first_name).to eq("Jim & Janet")
        expect(name.salutation).to eq("Mr. & Mrs.")
      end
    end
  end

  it 'handles space' do
    name = subject.new
    name.name = " "
    expect(name.first_name).to eq("")
    expect(name.middle_name).to eq("")
    expect(name.last_name).to eq("")
  end

  it 'handles empty string' do
    name = subject.new
    name.name = ""
    expect(name.first_name).to eq("")
    expect(name.middle_name).to eq("")
    expect(name.last_name).to eq("")
  end

  it 'handles nil' do
    name = subject.new
    name.name = nil
    expect(name.first_name).to eq("")
    expect(name.middle_name).to eq("")
    expect(name.last_name).to eq("")
  end

  describe ".call" do
    it "calls new with the passed parameter" do
      expect(NameSplitter::Splitter).to receive(:new).with("Joan of Arc")
      NameSplitter::Splitter.call("Joan of Arc")
    end
  end
end
