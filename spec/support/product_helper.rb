RSpec.shared_context "with product form helpers", shared_context: :metadata do
  def counterfeit_answer(authenticity)
    case authenticity
    when "counterfeit" then "Yes"
    when "genuine"     then "No"
    when "unsure"      then "Unsure"
    when "missing"     then "Not provided"
    end
  end

  def when_placed_on_market_answer(when_placed_on_market)
    case when_placed_on_market
    when "before_2021" then "Yes"
    when "on_or_after_2021" then "No"
    when "unknown" then "Unable to ascertain"
    when "missing" then "Not provided"
    end
  end
end

RSpec.configure do |rspec|
  rspec.include_context "with product form helpers", with_product_form_helper: true
end
