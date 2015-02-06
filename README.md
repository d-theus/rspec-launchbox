# Rspec::Launchbox

Bundle of RSpec DSL helpers, providing
timeout matchers, service runners. Work in progress.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rspec-launchbox'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec-launchbox

## Usage

### in_presence_of

```ruby
#spec/spec_helper.rb

require 'rspec/launchbox'

RSpec.configure do |config|
#...
  config.extend RSpec::InPresenceOf
  config.include RSpec::Matchers::Timeout
end
include RSpec::DescribeExecutable
```

Then in spec file:

```ruby
describe MyClass do
  in_presence_of 'external_program' do
    it 'should listen on port' do
      #here goes expectation
    end
  end
end
```

### describe_executable

```ruby
describe_executable 'ls' do
  its_stdout do
    it { is_expected.to be_a String }
  end
end
```

### expect { }.to persist

```ruby
expect do
  #routine
end.to persist.at_least(3) # or 3.seconds if you use ActiveSupport
```

This snippet runs binary called external_program (should be in path, or pass absolute path),
 and makes sure process started by that command is dead.

 _TODO:_ One day there  will be optional parameters e.g. signal to send to process.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/rspec-launchbox/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
