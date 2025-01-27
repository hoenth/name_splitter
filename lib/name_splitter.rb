require "name_splitter/version"

module NameSplitter
  class Splitter
    LAST_COMMA_FIRST_FORMAT = "last_comma_first"

    attr_accessor :suffixes, :first_name, :last_name, :middle_name, :last_name_prefix, :salutation, :suffix
    attr_reader :name

    def self.call(fullname)
      new(fullname)
    end

    def initialize(fullname = "", options = {})
      @salutation = ""
      @first_name = ""
      @middle_name = ""
      @last_name = ""
      @suffix = ""
      @options = options
      @delimeter = options[:format] == LAST_COMMA_FIRST_FORMAT ? /[ ,]+/ : /[ ]+/
      self.name = fullname
    end

    def name
      return "#{first_name.strip} #{last_name.strip}#{suffix.to_s.empty? ? "" : ", " + suffix}".strip if first_name.strip.length > 0

      return "#{salutation.strip} #{last_name.strip}#{suffix.to_s.empty? ? "" : ", " + suffix}".strip
    end

    def name=(fullname)
      return if fullname.nil? || fullname.strip.empty?

      
      name_arr = fullname.to_s.split(@delimeter)
      return if name_arr.empty?

      if contains_suffix(name_arr)
        self.suffix = name_arr.pop.strip
      end

      if name_arr.length == 1
        self.first_name = name_arr.shift.strip
        return
      end

      if is_first_element_a_last_name(name_arr)
        self.last_name = name_arr.shift.gsub(",","").strip
      end

      self.salutation = name_arr.shift(number_of_salutations(name_arr)).join(" ").strip

      if name_arr.length == 1 && last_name.empty?
        self.last_name = name_arr.shift.strip
      else
        self.first_name = name_arr.shift(number_of_first_names(name_arr)).join(" ").strip
        self.middle_name = name_arr.shift(number_of_middle_names(name_arr)).join(" ").strip
        self.last_name_check(name_arr)
      end
    end

    def last_name_check(last_name_arr)
      #accepts either a string or an array
      if last_name_arr.is_a?(String)
        last_name_arr = last_name_arr.split(" ")
      end
      return false if last_name_arr.empty?
      self.suffix = last_name_arr.pop if contains_suffix(last_name_arr)
      self.last_name = last_name_arr.join(" ").gsub(/[.,]+/, "").strip
    end

    private

    def number_of_middle_names(name_arr)
      # if the first and last names have already been assigned, assume the
      # rest of the name is a middle name
      if !first_name.empty? && !last_name.empty?
        return name_arr.length
      end

      #checks whether the array of names passed in contains a likely middle name
      if (name_arr.length == 2 &&
        !(contains_suffix(name_arr) || contains_last_name_prefix(name_arr))) ||
      (name_arr.length == 3 &&
        !(contains_suffix(name_arr) && contains_last_name_prefix(name_arr))) ||
      name_arr.length > 3
        return 1
      end

      return 0
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
      return true if @options[:format] == LAST_COMMA_FIRST_FORMAT

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
