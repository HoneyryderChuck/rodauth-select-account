# Rodauth::SelectAccount

[![pipeline status](https://gitlab.com/honeyryderchuck/rodauth-select-account/badges/master/pipeline.svg)](https://gitlab.com/honeyryderchuck/rodauth-select-account/-/pipelines?page=1&ref=master)
[![coverage report](https://gitlab.com/honeyryderchuck/rodauth-select-account/badges/master/coverage.svg)](https://honeyryderchuck.gitlab.io/rodauth-select-account/coverage/#_AllFiles)

This gem adds a feature to `rodauth` to support the management of multiple accounts in the same session. The behaviour is similar to how the "Google Sign-In" widget works, where you can sign-in with a different account, or switch to an already authenticated account.

## Features

This feature implements multiple accounts on the same session seamlessly, so that you can use the remaining `rodauth` features (they'll always refer to the currently selected account). Besides that, you'll be able to:

* Select previously used account to login;
* Sign in with a different account;
* Switch to an already authennticated account;
* Log out from all accounts;


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rodauth-select-account'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rodauth-select-account


## Usage

Usage of this feature should be as simple as:

```ruby
plugin :rodauth do
  # enable it in the plugin
  enable :select_account, :login, :logout
end

# then, inside roda

route do |r|
  r.rodauth
  # ...
end
```

## Ruby support policy

The minimum Ruby version required to run `rodauth-select-account` is 2.3 . Besides that, it should support all rubies that rodauth and roda support, including JRuby and (potentially, I don't know yet) truffleruby.

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake test` to run the tests, and `rake rubocop` to run the linter.

## Contributing

Bug reports and pull requests are welcome on Gitlab at https://gitlab.com/honeyryderchuck/rodauth-select-account.

