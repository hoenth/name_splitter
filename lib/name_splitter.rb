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
      if name_arr.length == 1
        self.first_name = name_arr.shift
      elsif name_arr.length == 2 and contains_salutation(name_arr[0])
        self.salutation = name_arr.shift
        self.last_name = name_arr.shift
      else
        self.salutation = name_arr.shift if contains_salutation(name_arr[0])
        self.first_name = name_arr.shift
        self.first_name = first_name + " " + name_arr.shift if is_second_first_name?(name_arr[0])
        self.first_name = first_name + " " + name_arr.shift + " " + name_arr.shift if anded_first_names?(name_arr[0])

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

    def contains_middle_name(name_arr)
      #checks whether the array of names passed in contains a likely middle name
      (name_arr.length == 2 and
        !(contains_suffix(name_arr) or contains_last_name_prefix(name_arr))) or
      (name_arr.length == 3 and
        !(contains_suffix(name_arr) and contains_last_name_prefix(name_arr))) or
      name_arr.length > 3
    end

    def is_second_first_name?(this_name)
     second_first_names.collect { |x| x.upcase }.include?(this_name.upcase)
    end

    def anded_first_names?(this_name)
      ["and", "&"].include?(this_name.to_s.strip)
    end

    def contains_salutation(this_name)
      salutations.collect { |x| x.upcase }.include?(this_name.gsub(/[.,;']+/, "").upcase)
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
      %w{Jr Sr II III IV V VI MD PHD}
    end

    def last_name_prefix
      %w(al de da la du del dei vda. dello della degli delle el van von der den heer ten ter vande vanden vander voor ver aan mac mc ben).freeze
    end

    def salutations
      %w{Mr Mrs Ms Miss Dr Prof Rev}
    end

    def second_first_names
      %w{Beth Catherine Louise}
    end
  end
end
