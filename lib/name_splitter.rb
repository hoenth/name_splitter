require "name_splitter/version"

module NameSplitter
  class Splitter
    attr_accessor :suffixes, :first_name, :last_name, :middle_name, :last_name_prefix, :salutation, :suffix
    attr_reader :name

    def self.call(fullname)
      new(fullname)
    end

    def initialize(fullname = "")
      self.salutation = ""
      self.first_name = ""
      self.middle_name = ""
      self.last_name = ""
      self.suffix = ""
      self.name = fullname if fullname and !fullname.to_s.empty?
    end

    def name
      first_name + " " + last_name + (suffix.to_s.empty? ? "" : ", " + suffix)
    end

    def name=(fullname)
      name_arr = fullname.split(" ")

      if contains_suffix(name_arr)
        self.suffix = name_arr.pop
      end

      if name_arr.length == 1
        self.first_name = name_arr.shift
        return
      end

      if is_first_element_a_last_name(name_arr)
        self.last_name = name_arr.shift.gsub(",","")
      end

      self.salutation = name_arr.shift(number_of_salutations(name_arr)).join(" ")

      if name_arr.length == 1 && last_name.empty?
        self.last_name = name_arr.shift
      else
        self.first_name = name_arr.shift(number_of_first_names(name_arr)).join(" ")
        self.middle_name = name_arr.shift if contains_middle_name(name_arr)
        self.last_name_check(name_arr)
      end
    end

    def last_name_check(last_name_arr)
      #accepts either a string or an array
      if last_name_arr.class.name == "String"
        last_name_arr = last_name_arr.split(" ")
      end
      return false if last_name_arr.empty?
      self.suffix = last_name_arr.pop if contains_suffix(last_name_arr)
      self.last_name = last_name_arr.join(" ").gsub(/[.,]+/, "")
    end

    private

    def contains_middle_name(name_arr)
      #checks whether the array of names passed in contains a likely middle name
      (name_arr.length == 1 && !last_name.empty? && !first_name.empty?) ||
      (name_arr.length == 2 &&
        !(contains_suffix(name_arr) || contains_last_name_prefix(name_arr))) ||
      (name_arr.length == 3 &&
        !(contains_suffix(name_arr) && contains_last_name_prefix(name_arr))) ||
      name_arr.length > 3
    end

    def number_of_salutations(name_arr)
      return 3 if contains_salutation(name_arr[0]) & anded_names?(name_arr[1]) & contains_salutation(name_arr[2])
      return 1 if contains_salutation(name_arr[0])
      return 0
    end

    def number_of_first_names(name_arr)
      return 2 if is_second_first_name?(name_arr[1])
      number_of_anded_names_before_last_names_if_any(name_arr)
    end

    def number_of_anded_names_before_last_names_if_any(name_arr)
      return 1 unless contains_an_and(name_arr)
      first_name_length = name_arr.length - (last_name.empty? ? 1 : 0)
      first_name_length -= 1 if contains_suffix(name_arr)
      first_name_length -= 1 if contains_last_name_prefix(name_arr)
      first_name_length
    end

    def is_second_first_name?(_name)
      return false unless _name
      second_first_names.collect { |x| x.upcase }.include?(_name.upcase)
    end

    def is_first_element_a_last_name(name_arr)
      name_arr[0].strip.match(/,/)
    end

    def anded_names?(_name)
      contains_an_and(_name)
    end

    def contains_an_and(*name_arr)
      name_arr.flatten.select { |_name| ["and", "&"].include?(_name.to_s.strip) }.any?
    end

    def contains_salutation(_name)
      return false unless _name
      salutations.collect { |x| x.upcase }.include?(_name.gsub(/[.,;']+/, "").upcase)
    end

    def contains_last_name_prefix(name_arr)
      last_name_prefix.collect { |x| x.upcase }.include?(name_arr.first.upcase)
    end

    def contains_suffix(name_arr)
      raise "contains_suffix must receive an array" if !name_arr.class.name == "Array"
      return false if name_arr.length == 1
      suffixes.collect { |x| x.upcase }.include?(name_arr.last.gsub(/[.,;']+/, "").upcase)
    end

    def suffixes
      %w{Jr Sr II III IV V VI MD PHD Esq DDS}
    end

    def last_name_prefix
      %w(al de da la du del dei vda. dello della degli delle el van von der den heer ten ter vande vanden vander voor ver aan mac mc ben).freeze
    end

    def salutations
      %w{Mr Mrs Ms Miss Dr Prof Rev Capt Sister Honorable Judge Chief}
    end

    def second_first_names
      %w{Beth Catherine Louise}
    end
  end
end
