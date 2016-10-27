require "rails_helper"

describe AccountSerializer do
  it "serializes a solo account to JSON" do
    account = create(
      :account,
      email: "test@example.com",
      monthly_spending_usd: 234,
      phone_number: "555 1234 555",
    )

    account.owner.update_attributes!(
      eligible: true,
      first_name: "George",
    )
    account.owner.create_spending_info!(
      credit_score:          456,
      will_apply_for_loan:   true,
      business_spending_usd: 1234,
      has_business:          "with_ein",
    )

    parsed_json = JSON.parse(described_class.new(account).to_json)

    expect(parsed_json.keys).to match_array(
      %w[
        id email owner companion monthly_spending_usd phone_number created_at
        balances_by_currencies home_airports travel_plans regions_of_interest
        recommendation_notes
      ],
    )

    expect(parsed_json["id"]).to eq account.id
    expect(parsed_json["email"]).to eq "test@example.com"
    expect(parsed_json["companion"]).to be_nil
    expect(parsed_json["monthly_spending_usd"]).to eq 234
    expect(parsed_json["phone_number"]).to eq "555 1234 555"

    owner = parsed_json["owner"]
    expect(owner.keys).to match_array(
      %w[id first_name eligible owner ready spending_info type ready_on card_accounts],
    )
    expect(owner["id"]).to eq account.owner.id
    expect(owner["owner"]).to be true
    expect(owner["first_name"]).to eq "George"
    expect(owner["eligible"]).to be true
    expect(owner["type"]).to eq "owner"

    owner_spending = owner["spending_info"]
    expect(owner_spending.keys).to match_array(
      %w[id credit_score will_apply_for_loan business_spending_usd has_business],
    )

    expect(owner_spending["id"]).to eq account.owner.spending_info.id
    expect(owner_spending["credit_score"]).to eq 456
    expect(owner_spending["will_apply_for_loan"]).to be true
    expect(owner_spending["business_spending_usd"]).to eq 1234
    expect(owner_spending["has_business"]).to eq "with_ein"
  end
end
