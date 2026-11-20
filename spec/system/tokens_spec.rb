require "rails_helper"

RSpec.describe "Token management", type: :system do
  before do
    visit sign_in_path
    fill_in "Email address", with: "testuser@example.com"
    click_button "Sign In"
    expect(page).to have_current_path(root_path)
    expect(page).to have_button("Menu")
  end

  it "creates a token and displays the raw value via Turbo Stream" do
    visit settings_tokens_path

    expect(page).not_to have_css(".token-reveal")

    fill_in "Token Name", with: "My Test Token"
    click_button "Create Token"

    # The token reveal should appear without a full page reload
    expect(page).to have_css(".token-reveal")
    expect(page).to have_content("Your new API token")
    expect(page).to have_content("Copy this token now")

    token_code = find(".token-reveal__value code")
    expect(token_code.text).to match(/\A[0-9a-f]{64}\z/)

    expect(page).to have_content("My Test Token")

    expect(find_field("Token Name").value).to be_blank
  end

  it "creates a token when no tokens exist yet (empty state)" do
    visit settings_tokens_path

    expect(page).not_to have_css("#tokens-list tr")

    fill_in "Token Name", with: "First Token"
    click_button "Create Token"

    expect(page).to have_css(".token-reveal")
    expect(page).to have_content("First Token")
    expect(page).to have_css("#tokens-list tr", count: 1)
  end

  it "revokes a token via Turbo Stream" do
    user = CoPlan::User.find_by!(email: "testuser@example.com")
    create(:api_token, user: user, name: "Revokable")

    visit settings_tokens_path
    expect(page).to have_content("Revokable")
    expect(page).to have_css(".badge--success")

    click_button "Revoke"

    expect(page).to have_css(".badge--danger")
    expect(page).not_to have_button("Revoke")

    expect(page).to have_content("Revokable")
  end
end
