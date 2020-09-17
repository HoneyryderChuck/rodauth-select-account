# frozen_string_literal: true

require_relative "test_helper"

class RodauthSelectAccountAddAccountTest < SelectAccountTest
  def test_select_account_login_logout
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
end
