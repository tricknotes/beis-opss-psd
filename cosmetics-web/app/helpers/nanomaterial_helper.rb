module NanomaterialHelper
  def get_ec_regulation_annex_numbers_for_nanomaterial_purposes(purposes)
    purposes.map { |purpose| get_ec_regulation_annex_number_for_nanomaterial_purpose(purpose) }
  end

  def get_ec_regulation_annex_number_for_nanomaterial_purpose(purpose)
    ANNEX_NUMBER_FOR_PURPOSE[purpose.to_sym]
  end

  def get_ec_regulation_link_for_annex_number(annex_number)
    case annex_number
    when 4
      "https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=celex:32009R1223#d1e32-176-1"
    when 5
      "https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=celex:32009R1223#d1e32-192-1"
    when 6
      "https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=celex:32009R1223#d1e32-201-1"
    else
      "https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=celex:32009R1223"
    end
  end

  ANNEX_NUMBER_FOR_PURPOSE = {
    colorant: 4,
    preservative: 5,
    uv_filter: 6
  }.freeze

  private_constant :ANNEX_NUMBER_FOR_PURPOSE
end
