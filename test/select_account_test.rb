# frozen_string_literal: true

require_relative "test_helper"

class RodauthSelectAccountSelectAccountTest < SelectAccountTest
  def test_select_account_select_account_while_logged_in
    rodauth do
      enable :select_account, :login, :logout
    end
    roda do |r|
      r.rodauth

      next unless rodauth.logged_in?

      account = DB[:accounts].where(id: rodauth.session_value).first
      r.root { view content: "#{account[:email]} is logged in" }
    end

    login
    add_account(login: "foo2@example.com", pass: "1234567890")

    # now let's select account an account from our session
    select_account("foo@example.com")
    assert page.html.include?("foo@example.com is logged in")
    assert page.find("#notice_flash").text == "You have selected an account"
    select_account("foo2@example.com")
    assert page.html.include?("foo2@example.com is logged in")
    assert page.find("#notice_flash").text == "You have selected an account"

    logout

    # now let's try to select after being logged in
    select_account("foo@example.com")
    assert page.current_path == "/login"
    fill_in "Password", with: "0123456789"
    click_button "Login"
    assert page.html.include?("foo@example.com is logged in")
    assert page.find("#notice_flash").text == "You have been logged in"

    # now let's try to select a previously used account not logged in anymore
    select_account("foo2@example.com")
    assert page.current_path == "/add-account"
    fill_in "Password", with: "1234567890"
    click_button "Add Account"
    assert page.html.include?("foo2@example.com is logged in")
    assert page.find("#notice_flash").text == "You have added a new account"
  end

  def test_select_account_require_select_account_no_accounts
    rodauth do
      enable :select_account, :login, :logout
    end
    roda do |r|
      r.rodauth

      rodauth.require_select_account

      account = DB[:accounts].where(id: rodauth.session_value).first
      r.root { view content: "#{account[:email]} is selected" }
    end

    visit "/"
    assert page.find("#error_flash").text == "Please login to continue"
    login(visit: false)
    assert page.html.include?("foo@example.com is selected")
  end

  def test_select_account_require_select_account_to_login
    rodauth do
      enable :select_account, :login, :logout
    end
    roda do |r|
      r.rodauth

      rodauth.require_select_account

      account = DB[:accounts].where(id: rodauth.session_value).first
      r.root { view content: "#{account[:email]} is selected" }
    end

    login
    add_account(login: "foo2@example.com", pass: "1234567890")
    logout
    click_link "Home"

    assert page.find("#error_flash").text == "Please select account to continue"
    click_button("foo2@example.com")
    assert page.find("#error_flash").text == "Please login to continue"
    fill_in "Password", with: "1234567890"
    click_button "Login"
    assert page.html.include?("foo2@example.com is selected")
  end

  def test_select_account_require_select_account_to_add_account
    rodauth do
      enable :select_account, :login, :logout
    end
    roda do |r|
      r.rodauth

      rodauth.require_select_account

      account = DB[:accounts].where(id: rodauth.session_value).first
      r.root { view content: "#{account[:email]} is selected" }
    end

    login
    add_account(login: "foo2@example.com", pass: "1234567890")
    logout
    login
    click_link "Home"
    click_link "Home"

    assert page.find("#error_flash").text == "Please select account to continue"
    click_button("foo2@example.com")
    assert page.find("#error_flash").text == "Please add account to continue"
    fill_in "Password", with: "1234567890"
    click_button "Add Account"
    assert page.html.include?("foo2@example.com is selected")
  end

  private

  def select_account(login)
    click_link("Accounts")
    click_button(login)
  end
end
