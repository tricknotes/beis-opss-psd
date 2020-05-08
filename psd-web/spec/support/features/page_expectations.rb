module PageExpectations
  def expect_to_be_on_the_homepage
    expect(page).to have_current_path("/")
  end

  # Cases pages
  def expect_to_be_on_case_page(case_id: nil)
    if case_id
      expect(page).to have_current_path("/cases/#{case_id}")
    else
      expect(page).to have_current_path(/\/cases\/[\d\-]+$/)
    end
    expect(page).to have_selector("h1", text: "Overview")
  end

  def expect_to_be_on_investigation_businesses_page
    expect(page).to have_current_path("/cases/#{investigation.pretty_id}/businesses")
    expect(page).to have_selector("h1", text: "Businesses")
  end

  def expect_to_be_on_add_attachment_page
    expect(page).to have_current_path("/cases/#{investigation.pretty_id}/documents/new/upload")
    expect(page).to have_selector("h1", text: "Add attachment")
    expect(page).to have_link("Back", href: investigation_path(investigation))
  end

  def expect_to_be_on_enter_attachment_details_page
    expect(page).to have_current_path("/cases/#{investigation.pretty_id}/documents/new/metadata")
    expect(page).to have_selector("h3", text: "Document details")
    expect(page).to have_link("Back", href: investigation_path(investigation))
  end

  def expect_to_be_on_record_corrective_action_for_case_page
    expect(page).to have_current_path("/cases/#{investigation.pretty_id}/corrective_actions/details")
    expect(page).to have_selector("h1", text: "Record corrective action")
  end

  def expect_to_be_on_confirmation_page
    expect(page).to have_current_path("/cases/#{investigation.pretty_id}/corrective_actions/confirmation")
    expect(page).to have_selector("h1", text: "Confirm corrective action details")
  end

  def expect_to_be_on_investigation_products_page
    expect(page).to have_current_path("/cases/#{investigation.pretty_id}/products")
    expect(page).to have_selector("h1", text: "Products")
  end

  def expect_to_be_on_case_products_page
    expect(page).to have_selector("h1", text: "Products")
  end

  def expect_to_be_on_teams_page(case_id:)
    expect(page).to have_current_path("/cases/#{case_id}/teams")
    expect(page).to have_selector("h1", text: "Teams added to the case")
  end

  def expect_to_be_on_add_team_to_case_page(case_id:)
    expect(page).to have_current_path("/cases/#{case_id}/teams/add")
    expect(page).to have_selector("h1", text: "Add a team to the case")
  end

  def expect_to_be_on_attachments_page
    expect(page).to have_current_path("/cases/#{investigation.pretty_id}/attachments")
    expect(page).to have_selector("h1", text: "Attachments")
    expect(page).to have_selector("h2", text: document.title)
    expect(page).to have_selector("p",  text: document.description)
  end

  def expect_to_be_on_product_attachments_page
    expect(page).to have_selector("h2", text: "Attachments")
    expect(page).to have_selector("h2", text: document.title)
    expect(page).to have_selector("p",  text: document.description)
  end

  def expect_to_be_on_edit_attachment_page
    expect(page).to have_current_path("/cases/#{investigation.pretty_id}/documents/#{document.to_param}/edit")
    expect(page).to have_selector("h2", text: "Edit document details")
    expect(page).to have_link("Back", href: "/cases/#{investigation.pretty_id}")
  end

  def expect_to_be_on_remove_attachment_confirmation_page
    expect(page).to have_current_path("/cases/#{investigation.pretty_id}/documents/#{document.id}/remove")
    expect(page).to have_selector("h2", text: "Remove attachment")
    expect(page).to have_link("Back", href: "/cases/#{investigation.pretty_id}")
  end

  def expect_to_be_on_case_created_page
    expect(page).to have_current_path(/\/cases\/([\d-]+)\/created/)
    expect(page).to have_selector("h1", text: "Case created")
    expect(page).to have_text(/Case ID: ([\d-]+)/)
  end

  def expect_to_be_on_new_activity_page
    expect_page_to_have_h1("New activity")
  end

  def expect_to_be_on_record_test_result_page
    expect_page_to_have_h1("Record test result")
  end

  def expect_to_be_on_case_activity_page(case_id: nil)
    if case_id
      expect(page).to have_current_path("/cases/#{case_id}/activity")
    else
      expect(page).to have_current_path(/\/cases\/[\d\-]+\/activity/)
    end
    expect(page).to have_selector("h1", text: "Activity")
  end

  # Add an allegation flow
  def expect_to_be_on_allegation_complainant_page
    expect(page).to have_current_path("/allegation/complainant")
    expect_page_to_have_h1("New allegation")
  end

  def expect_to_be_on_allegation_complainant_details_page
    expect(page).to have_current_path("/allegation/complainant_details")
    expect_page_to_have_h1("New allegation")
    expect(page).to have_css(".govuk-fieldset__legend--m", text: "What are their contact details?")
  end

  def expect_to_be_on_allegation_details_page
    expect(page).to have_current_path("/allegation/allegation_details")
    expect_page_to_have_h1("New allegation")
    expect(page).to have_css(".govuk-label--m", text: "What is being alleged?")
  end

  # Add an enquiry flow
  def expect_to_be_on_about_enquiry_page
    expect(page).to have_current_path("/enquiry/about_enquiry")
    expect_page_to_have_h1("New enquiry")
  end

  def expect_to_be_on_complainant_page
    expect(page).to have_current_path("/enquiry/complainant")
    expect_page_to_have_h1("New enquiry")
  end

  def expect_to_be_on_complainant_details_page
    expect(page).to have_current_path("/enquiry/complainant_details")
    expect_page_to_have_h1("New enquiry")
    expect(page).to have_css(".govuk-fieldset__legend--m", text: "What are their contact details?")
  end

  def expect_to_be_on_enquiry_details_page
    expect(page).to have_current_path("/enquiry/enquiry_details")
    expect_page_to_have_h1("New enquiry")
    expect(page).to have_css(".govuk-fieldset__legend--m", text: "What is the enquiry?")
  end

  # Trading Standards add investigation flow
  def expect_to_be_on_risk_assessment_details_page
    expect(page).to have_current_path("/ts_investigation/risk_assessments")
    expect(page).to have_selector("h1", text: "Risk assessment details")
  end

  def expect_to_be_on_reference_number_page
    expect(page).to have_current_path("/ts_investigation/reference_number")
    expect(page).to have_selector("h1", text: "Add your own reference number")
  end

  def expect_to_be_on_what_product_are_you_reporting_page
    expect(page).to have_current_path("/ts_investigation/product")
    expect(page).to have_selector("h1", text: "What product are you reporting?")
  end

  def expect_to_be_on_why_reporting_page
    expect(page).to have_current_path("/ts_investigation/why_reporting")
    expect(page).to have_selector("h1", text: "Why are you reporting this product?")
  end

  def expect_to_be_on_supply_chain_page
    expect(page).to have_current_path("/ts_investigation/which_businesses")
    expect(page).to have_selector("h1", text: "Supply chain information")
  end

  def expect_to_be_on_business_details_page(title)
    expect(page).to have_current_path("/ts_investigation/business")
    expect(page).to have_selector("h1", text: "#{title} details")
  end

  def expect_to_be_on_corrective_action_taken_page
    expect(page).to have_current_path("/ts_investigation/has_corrective_action")
    expect(page).to have_selector("h1", text: "Has any corrective action been agreed or taken?")
  end

  def expect_to_be_on_record_corrective_action_page
    expect(page).to have_current_path("/ts_investigation/corrective_action")
    expect(page).to have_selector("h1", text: "Record corrective action")
  end

  def expect_to_be_on_other_information_page
    expect(page).to have_current_path("/ts_investigation/other_information")
    expect(page).to have_selector("h1", text: "Other information and files")
  end

  def expect_to_be_on_test_result_details_page
    expect(page).to have_current_path("/ts_investigation/test_results")
    expect(page).to have_selector("h1", text: "Test result details")
  end

  # Product pages
  def expect_to_be_on_remove_attachment_from_product_confirmation_page
    expect(page).to have_current_path("/products/#{product.id}/documents/#{document.id}/remove")
    expect(page).to have_selector("h2", text: "Remove attachment")
    expect(page).to have_link("Back", href: "/products/#{product.id}")
  end

  def expect_to_be_on_product_page
    expect(page).to have_current_path("/products/#{product.id}")
    expect(page).to have_selector("h1", text: product.name)
  end

  # Shared pages across different flows
  def expect_to_be_on_coronavirus_page(path)
    expect(page).to have_current_path(path)
    expect(page).to have_selector("h1", text: "Is this case related to the coronavirus outbreak?")
  end

  # Login and account management pages
  def expect_to_be_on_secondary_authentication_page
    expect(page).to have_current_path(/\/two-factor/)
    expect(page).to have_h1("Check your phone")
  end

  def expect_to_be_on_complete_registration_page
    expect(page).to have_current_path(/\/complete-registration?.+$/)
    expect(page).to have_h1("Create an account")
    expect(page).to have_field("username", type: "email", with: invited_user.email, disabled: true)
  end

  def expect_to_be_on_signed_in_as_another_user_page
    expect(page).to have_h1("You are already signed in to the Product safety database")
  end

  def expect_to_be_on_declaration_page
    expect(page).to have_current_path(/^\/declaration$/)
    expect(page).to have_title("Declaration - Product safety database - GOV.UK")
  end

  def expect_to_be_on_reset_password_page
    expect(page).to have_current_path("/password/new")
  end

  def expect_to_be_on_edit_user_password_page
    expect(page).to have_current_path("/password/edit", ignore_query: true)
  end

  def expect_to_be_on_check_your_email_page
    expect(page).to have_css("h1", text: "Check your email")
  end

  def expect_to_be_on_password_changed_page
    expect(page).to have_current_path("/password-changed")
    expect(page).to have_css("h1", text: "You have changed your password successfully")
  end

  def expect_to_be_on_your_account_page
    expect(page).to have_current_path("/account")
    expect(page).to have_selector("h1", text: "Your account")
  end

  def expect_to_be_on_change_name_page
    expect(page).to have_current_path("/account/name")
    expect(page).to have_selector("h1", text: "Change your name")
  end

  def expect_to_be_on_team_page
    expect(page).to have_css("h1", text: "test organisation")
  end

  def expect_to_be_on_invite_a_team_member_page
    expect(page).to have_css("h1", text: "Invite a team member")
  end

  def expect_to_be_on_edit_case_permissions_page(case_id:)
    expect(page).to have_current_path("/cases/#{case_id}/teams/#{team.id}/edit")
    expect(page).to have_selector("h1", text: team.name)
  end

  def expect_teams_tables_to_contain(expected_teams)
    teams_table = page.find(:table, "Teams added to the case")

    within(teams_table) do
      expected_teams.each do |expected_team|
        row_heading = page.find("th", text: expected_team[:team_name])
        expect(row_heading).to have_sibling("td", text: expected_team[:permission_level])
      end
    end
  end

  def expect_teams_tables_not_to_contain(teams)
    teams_table = page.find(:table, "Teams added to the case")

    within(teams_table) do
      teams.each do |expected_team|
        elems = page.all("th", text: expected_team[:team_name])
        expect(elems).to be_empty, "#{expected_team[:team_name]} should not be visible"
      end
    end
  end
end