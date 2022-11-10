# Rodauth::SelectAccount

[![Gem Version](https://badge.fury.io/rb/rodauth-select-account.svg)](http://rubygems.org/gems/rodauth-select-account)
[![pipeline status](https://gitlab.com/os85/rodauth-select-account/badges/master/pipeline.svg)](https://gitlab.com/os85/rodauth-select-account/-/pipelines?page=1&ref=master)
[![coverage report](https://gitlab.com/os85/rodauth-select-account/badges/master/coverage.svg)](https://os85.gitlab.io/rodauth-select-account/coverage/#_AllFiles)

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

## Example

There's an example application in the project [under the examples directory](/examples). You can clone de project, install the dependencies and then you can run it with:

`> bundle exec ruby examples/goggles.rb`

Then you can open your browser under `http://localhost:9292`.

Here's a screenshot:

![rodauth-select-account example](/examples/select-account-example.png)

## Add Account

The URLs provided are:

* `GET /add-account`: In renders a form, similar to the login form, where you'll input the login and password of the account you want to add.
* `POST /add-account`: When the aforementioned form gets submitted; This will both add the new account to the session, and use it as the current account.

## Select Account

The URLs provided are:

* `GET /select-account`: It renders a page with recently used accounts, to switch to.
* `POST /select-account`: Submitted with a login to switch the current account to; If you're not logged in, It'll ask you to log in with the chosen account; If logged in, but the account hasn't been authenticated yet, it'll ask you to add the account to the session; otherwise, it'll switch the current account to the selected one.


The accounts a user can switch are: accounts the user recently logged into, or added. Seamless switching only happens if the account has been logged in for the current session, otherwise the user will be prompted to log in. When the user logs out, it logs out from all accounts. However, the accounts will be able to be select, for a time, in the `/select-account` page, although the user will always have to log in before the account can be selected.

# Options

You'll be able to tweak the following options

* `selected_account_key` (default: `:selected_account_id`) key from session where the current account is stored;
* `accounts_key` (default: `:accounts`) key from session where all authenticated accounts are stored;
* `add_account_redirect_session_key` (default: `:add_account_redirect`) key from session where the uri to redirect after adding an account is stored;
* `select_account_redirect_session_key` (default: `:select_account_redirect`) key from session where the uri to redirect after selecting an account is stored;
* `require_selected_account_cookie_key` (default: `"_require_selected_account"`) key from cookies where it stored if an account has been selected for a flow requiring it;
* `accounts_cookie_key` (default: `"_accounts"`) key from cookies where all previously used accounts are stored;
* `accounts_cookie_options` (default: `{}.freeze`) accounts cookie options;
* `require_selected_account_cookie_interval` (default: 5 minutes): for how much time the selected account will hold, for a flow requiring it;
* `accounts_cookie_interval` (default: `14 + 60 * 60 * 24`, 14 days): for how much time the previously used accounts in the user agent are going to be remembered;
* `no_account_error_status`: (default: 409) the status code used when no account is found for an existing account in session (for example, if an account has been closed or deleted);
* `select_account_required_error_status`: (default: 403) the status code indicating that an account needs to be selected;
* `add_account_required_error_status`: (default: 403) the status code indicating that an account needs to be added;
* `no_account_message`: flash error message when no account is found;

The following options and methods are also available to override, and names should be self-explanatory according to rodauth conventions:

* `add_account_notice_flash`
* `add_account_error_flash`
* `require_add_account_error_flash`
* `add_account_view`
* `before_add_account_route`
* `before_add_account`
* `after_add_account`
* `add_account_button`
* `add_account_redirect`
* `select_account_notice_flash`
* `select_account_error_flash`
* `require_select_account_error_flash`
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
* `require_select_account`: to be used like `require_account`, as a filter to actions that require a user to explicitly select an account before allowing it.

#### Internationalization (i18n)

`rodauth-select-account` supports translating all user-facing text found in all pages and forms and buttons, by integrating with [rodauth-i18n](https://github.com/janko/rodauth-i18n). Just set it up in your application and `rodauth` configuration.

Default translations shipping with `rodauth-select-account` can be found [in this directory](https://gitlab.com/os85/rodauth-select-account/-/tree/master/locales). If they're not available for the languages you'd like to support, consider getting them translated from the english text, and contributing them to this repository via a Merge Request.

(This feature is available since `v0.1`.)

## Ruby support policy

The minimum Ruby version required to run `rodauth-select-account` is 2.4 . Besides that, it supports all rubies that rodauth and roda support, including JRuby and truffleruby.

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake test` to run the tests, and `rake rubocop` to run the linter.

## Contributing

Bug reports and pull requests are welcome on Gitlab at https://gitlab.com/os85/rodauth-select-account.
