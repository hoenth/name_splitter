require "name_splitter/version"

module NameSplitter
  class Splitter
    LAST_COMMA_FIRST_FORMAT = "last_comma_first"

    attr_accessor :suffixes, :first_name, :last_name, :middle_name, :last_name_prefix, :salutation, :suffix, :last_name_first_format
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
      @last_name_first_format = options[:format] == LAST_COMMA_FIRST_FORMAT
      @delimeter = /[ ]+/
      self.name = fullname
    end

    def name
      return "#{first_name.strip} #{last_name.strip}#{suffix.to_s.empty? ? "" : ", " + suffix}".strip if first_name.strip.length > 0

      return "#{salutation.strip} #{last_name.strip}#{suffix.to_s.empty? ? "" : ", " + suffix}".strip
    end

    def name=(fullname)
      return if fullname.nil? || fullname.strip.empty?

      if last_name_first_format
        name_arr = split_name_when_last_name_is_first(fullname)
      else
        name_arr ||= fullname.to_s.split(@delimeter)
      end
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
      number_of_non_middle_names = 0
      number_of_non_middle_names += 1 if self.first_name.empty?
      number_of_non_middle_names += 1 if self.last_name.empty?
      number_of_non_middle_names += 1 if contains_last_name_prefix(name_arr)
      number_of_non_middle_names += 1 if contains_suffix(name_arr)
      return 0 if name_arr.length <= number_of_non_middle_names

      # p "last name emptty: #{self.last_name.empty?}"
      # p "contains_last_name_prefix: #{contains_last_name_prefix(name_arr)}"
      # p "first_name: #{first_name}"
      # p "last_name: #{last_name}"
      # p "number_of_non_middle_names: #{number_of_non_middle_names}"
      # p "name_arr: #{name_arr}"

      # assume all other names that are not last name prefixes, or suffixes are middle names
      name_arr.length - number_of_non_middle_names
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

    # this is a bit of a hack to determine if the first element in the name array is actually a last name.
    # We assume that if there is a comma in the first element, then it is a last name.
    # This is not always the case, but it is a common format for names and it allows us to correctly
    # parse names like "Smith, John" and "Smith, John C." without incorrectly parsing names
    # like "Smith Johnson Jr., Jim C." as having a last name of "Smith Johnson Jr."
    # We don't need this if the last_name_first_format option is set to true because we will already be splitting the
    # name on the comma and assigning the first element as the last name.
    # But a file could have a mix of formats, or the format is not specified, so we want to be able to handle this case
    # even if the last_name_first_format option is not set to true.
    def is_first_element_a_last_name(name_arr)
      name_arr[0].strip.match(/,/)
    end

    def anded_names?(name)
      contains_an_and(name)
    end

    def contains_an_and(*name_arr)
      name_arr.flatten.select { |name| ["and", "&"].include?(name.to_s.strip) }.any?
    end

    def contains_salutation(name)
      return false unless name
      salutations.collect { |x| x.upcase }.include?(name.gsub(/[.,;']+/, "").upcase)
    end

    # We check if the name array contains a last name prefix by checking the last two elements of the name array.
    # This is because last name prefixes are typically found in the last name portion of the name, and they are
    # typically found before the last name. For example, in the name "John de la Smith", "de la" is a last name prefix
    # and it is found before the last name "Smith".
    def contains_last_name_prefix(name_arr)
      return false if name_arr.length < 2
      last_two = name_arr.last(2)
      last_name_prefix.collect { |x| x.upcase }.include?(last_two.first.upcase)
    end

    # the name can't contain a suffix unless there are at least two names left in the name array.
    def contains_suffix(name_arr)
      raise "contains_suffix must receive an array" if !name_arr.is_a?(Array)
      return false if name_arr.length < 2

      suffixes.collect { |x| x.upcase }.include?(name_arr.last.gsub(/[.,;']+/, "").upcase)
    end

    # here we assume that everything before the comma is associated with the last name and everything after the comma
    # are the other names (first, middle, salutation). A suffix would most likely be in the last name portion of the name.
    # examples of this format include "Smith, John", "Smith,John C.", "Smith Johnson Jr., Jim C."
    def split_name_when_last_name_is_first(fullname)
      name_arr = fullname.to_s.split(/[,]+/) # we first only want to split out the name(s) that are considered last from the first
      return name_arr if name_arr.length < 2

      last_names = name_arr[0].split(" ") # we then want to split the last name(s) into an array to check for last name prefixes and suffixes
      first_names = name_arr[1].split(" ") # we also want to split the first name(s) into an array to check for salutations and suffixes


      # lets check if the last name(s) contain a suffix
      if contains_suffix(last_names)
        self.suffix = last_names.pop.strip
      end

      # now let's check if the first name(s) contain a suffix
      if contains_suffix(first_names)
        self.suffix = first_names.pop.strip
      end

      # now we'll recombine the last name(s) and first name(s) into one array to be processed as normal
      # We assume if there were multiple last names (i.e. before the comma) that they are all part of the last name.
      first_names + [last_names.join(" ").strip]
    end

    def suffixes
      %w{Jr Sr II III IV V VI MD PHD Esq DDS}.freeze
    end

    def last_name_prefix
      %w(al de da la du del dei vda. dello della degli delle el van von der den heer ten ter vande vanden vander voor ver aan mac mc ben).freeze
    end

    def salutations
      %w{Mr Mrs Ms Miss Dr Prof Rev Capt Sister Honorable Judge Chief}.freeze
    end

    def second_first_names
      %w{Beth Catherine Louise}.freeze
    end
  end
end
