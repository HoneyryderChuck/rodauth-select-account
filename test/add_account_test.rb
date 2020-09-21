# frozen_string_literal: true

require_relative "test_helper"

class RodauthSelectAccountAddAccountTest < SelectAccountTest
  def test_select_account_add_account
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

    assert page.find("#notice_flash").text == "You have been logged in"
    assert page.html.include?("foo@example.com is logged in")

    add_account(login: "foo2@example.com", pass: "1234567890")
    assert page.find("#notice_flash").text == "You have added a new account"
    assert page.html.include?("foo2@example.com is logged in")

    logout
    assert page.find("#notice_flash").text == "You have been logged out"
    assert page.current_path == "/login"
  end

  def test_select_account_add_account_no_account
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

    assert page.find("#notice_flash").text == "You have been logged in"
    assert page.html.include?("foo@example.com is logged in")

    add_account(login: "foo3@example.com", pass: "0123456789")

    assert page.find("#error_flash").text == "There was an error adding the new account"
    assert page.html.include?("no matching login")

    logout
    assert page.find("#notice_flash").text == "You have been logged out"
    assert page.current_path == "/login"
  end

  def test_select_account_add_account_wrong_password
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

    assert page.find("#notice_flash").text == "You have been logged in"
    assert page.html.include?("foo@example.com is logged in")

    add_account(login: "foo2@example.com", pass: "0123456789")
    assert page.find("#error_flash").text == "There was an error adding the new account"
    assert page.html.include?("invalid password")

    logout
    assert page.find("#notice_flash").text == "You have been logged out"
    assert page.current_path == "/login"
  end

  def test_select_account_multiphase_add_account
    rodauth do
      enable :select_account, :login, :logout
      use_multi_phase_login? true
    end
    roda do |r|
      r.rodauth
      next unless rodauth.logged_in?

      account = DB[:accounts].where(id: rodauth.session_value).first
      r.root { view content: "#{account[:email]} is logged in" }
    end

    visit("/login")
    fill_in "Login", with: "foo@example.com"
    click_button "Login"
    fill_in "Password", with: "0123456789"
    click_button "Login"

    assert page.find("#notice_flash").text == "You have been logged in"
    assert page.html.include?("foo@example.com is logged in")

    click_link("Add Account")
    fill_in "Login", with: "foo2@example.com"
    click_button "Add Account"
    fill_in "Password", with: "1234567890"
    click_button "Login"

    assert page.find("#notice_flash").text == "You have added a new account"
    assert page.html.include?("foo2@example.com is logged in")

    logout
    assert page.find("#notice_flash").text == "You have been logged out"
    assert page.current_path == "/login"
  end
end
