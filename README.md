# NameSplitter

The NameSplitter gem takes in a full name and spits out salutation, first name, middle name (initial), last name, and suffix. 

It does its best to guess whether a middle name is really part of the last name (as in 'Manny del Rio'). 
## Installation

Add this line to your application's Gemfile:

```ruby
gem 'name_splitter'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install name_splitter

## Usage

NameSplitter is pretty simple to use. Just pass in the full name string and it will return an object that responds to salutation, first_name, last_name, middle_name, and suffix. 

````ruby
names = NameSplitter::Splitter.call("Ms. Mary Beth Farmer")
names.first_name # Mary Beth
names.last_name # Farmer
names.salutation # Ms.
````

See the [spec file](spec/name_splitter_spec.rb) for documentation on all of the ways a name can be split

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/name_splitter. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

