require "rails_helper"

RSpec.feature "Adding a product", :with_stubbed_mailer, :with_stubbed_elasticsearch, :with_product_form_helper do
  let(:user)          { create(:user, :activated) }
  let(:investigation) { create(:enquiry, creator: user) }
  let(:attributes)    { attributes_for(:product_iphone, authenticity: Product.authenticities.keys.without("missing").sample) }
  let(:other_user)    { create(:user, :activated) }

  before do
    ChangeCaseOwner.call!(investigation: investigation, owner: user.team, user: user)
  end

  scenario "Adding a product to a case" do
    sign_in user
    visit "/cases/#{investigation.pretty_id}/products/new"

    fill_in "Barcode number (GTIN, EAN or UPC)", with: "9781529034528"

    click_button "Save product"

    # Expected validation errors
    expect(page).to have_error_messages
    expect(page).to have_text("Name cannot be blank")
    expect(page).to have_text("Category cannot be blank")
    expect(page).to have_text("Product type cannot be blank")
    expect(page).to have_text("Enter a valid barcode number")
    expect(page).to have_text("You must state whether the product is a counterfeit")

    select attributes[:category], from: "Product category"

    fill_in "Product type",                      with: attributes[:product_type]
    fill_in "Product brand",                     with: attributes[:brand]
    fill_in "Product name",                      with: attributes[:name]
    fill_in "Barcode number (GTIN, EAN or UPC)", with: attributes[:gtin13]
    fill_in "Other product identifiers",         with: attributes[:product_code]
    fill_in "Batch number",                      with: attributes[:batch_number]
    fill_in "Webpage",                           with: attributes[:webpage]

    within_fieldset("Is the product counterfeit?") do
      choose counterfeit_answer(attributes[:authenticity])
    end

    select attributes[:country_of_origin], from: "Country of origin"

    fill_in "Description of product", with: attributes[:description]

    click_on "Save product"

    expect_to_be_on_investigation_products_page(case_id: investigation.pretty_id)
    expect(page).not_to have_error_messages

    expect(page).to have_summary_item(key: "Product brand",             value: attributes[:brand])
    expect(page).to have_summary_item(key: "Product name",              value: attributes[:name])
    expect(page).to have_summary_item(key: "Category",                  value: attributes[:category])
    expect(page).to have_summary_item(key: "Product type",              value: attributes[:product_type])
    expect(page).to have_summary_item(key: "Product authenticity",      value: I18n.t(attributes[:authenticity], scope: Product.model_name.i18n_key))
    expect(page).to have_summary_item(key: "Barcode number",            value: attributes[:gin13])
    expect(page).to have_summary_item(key: "Other product identifiers", value: attributes[:product_code])
    expect(page).to have_summary_item(key: "Batch number",              value: attributes[:batch_number])
    expect(page).to have_summary_item(key: "Webpage",                   value: attributes[:webpage])
    expect(page).to have_summary_item(key: "Country of origin",         value: attributes[:country])
    expect(page).to have_summary_item(key: "Description",               value: attributes[:description])
  end

  scenario "Not being able to add a product to another team’s case" do
    sign_in other_user
    visit "/cases/#{investigation.pretty_id}/products"

    expect(page).not_to have_link("Add product")
  end
end
