require 'rails_helper'

RSpec.describe "Declaration page", type: :system do
  let(:first_time_user) { build(:user, first_login: true) }

  before do
    sign_in(as_user: first_time_user)
  end

  after do
    sign_out
  end

  it "is displayed on first login" do
    visit root_path

    assert_current_path declaration_path
  end

  it "requires confirmation before continuing" do
    visit root_path

    click_on "Continue"

    assert_current_path accept_declaration_path
    assert_text "You must confirm the declaration"
  end

  it "records confirmation and redirects to account page" do
    visit root_path

    check "I confirm"
    click_on "Continue"

    assert_current_path account_path(:overview)
    expect(first_time_user.has_accepted_declaration?).to be true
  end
end