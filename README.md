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

## Add Account

The URLs provided are:

* `GET /add-account`: In renders a form, similar to the login form, where you'll input the login and password of the account you want to add.
* `POST /add-account`: When the aforementioned form gets submitted; This will both add the new account to the session, and use it as the current account.

## Select Account

The URLs provided are:

* `POST /select-account`: Submitted with a login to switch the current account to; If you're not logged in, It'll ask you to log in with the chosen account; If logged in, but the account hasn't been authenticated yet, it'll ask you to add the account to the session; otherwise, it'll switch the current account to the selected one.


# Options

You'll be able to tweak the following options

* `selected_account_key` (default: `:selected_account_id`) key from session where the current account is stored;
* `accounts_key` (default: `:accounts`) key from session where all authenticated accounts are stored;
* `accounts_cookie_key` (default: `"_accounts"`) key from cookies where all previously used accounts are stored;
* `accounts_cookie_options` (default: `{}.freeze`) accounts cookie options;
* `accounts_cookie_interval` (default: `14 + 60 * 60 * 24`, 14 days): for how much time the previously used accounts in the user agent are going to be remembered;
* `no_account_error_status`: (default: 409) the status code used when no account is found for an existing account in session (for example, if an account has been closed or deleted);
* `no_account_message`: flash error message when no account is found;

The following options and methods are also available to override, and names should be self-explanatory according to rodauth conventions:

* `add_account_notice_flash`
* `add_account_error_flash`
* `add_account_view`
* `before_add_account_route`
* `before_add_account`
* `after_add_account`
* `add_account_button`
* `add_account_redirect`
* `select_account_notice_flash`
* `select_account_error_flash`
* `before_select_account_route`
* `before_select_account`
* `after_select_account`
* `select_account_redirect`
* `add_account_path`
* `add_account_url`
* `select_account_path`
* `select_account_url`

These are also available methods:

* `accounts_in_session`: returns all the available accounts in session

## Ruby support policy

The minimum Ruby version required to run `rodauth-select-account` is 2.4 . Besides that, it should support all rubies that rodauth and roda support, including JRuby and (potentially, I don't know yet) truffleruby.

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake test` to run the tests, and `rake rubocop` to run the linter.

## Contributing

Bug reports and pull requests are welcome on Gitlab at https://gitlab.com/honeyryderchuck/rodauth-select-account.

