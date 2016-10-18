require "rails_helper"

describe CardAccountSerializer do
  it "serializes a CardAccount to JSON" do
    bank = Bank.find_by(name: "Chase")
    card = create(
      :card,
      bank:    bank,
      bp:      :personal,
      name:    "My awesome card",
      network: :visa,
    )

    card_account = CardAccount.new(
      card: card,
      person: create(:person),
      # Note that these dates, of course, make no sense, and a real card
      # account would never have all of them present:
      recommended_at: "2015-09-10",
      applied_at:     "2015-09-11",
      opened_at:      "2015-09-12",
      earned_at:      "2015-09-13",
      closed_at:      "2015-09-14",
      clicked_at:     "2015-09-15",
      declined_at:    "2015-09-16",
      denied_at:      "2015-09-17",
      nudged_at:      "2015-09-18",
      called_at:      "2015-09-19",
      redenied_at:    "2015-09-20",
      decline_reason: "something",
    )
    card_account.save!(validate: false)

    # Note that this card account is, of course, completely invalid:
    json = described_class.new(card_account).to_json

    parsed_json = JSON.parse(json)

    expect(parsed_json.keys).to match_array(
      %w[
        id recommended_at applied_at opened_at earned_at closed_at clicked_at
        declined_at denied_at nudged_at called_at redenied_at card decline_reason
      ],
    )

    expect(parsed_json["recommended_at"]).to eq "2015-09-10"
    expect(parsed_json["applied_at"]).to eq     "2015-09-11"
    expect(parsed_json["opened_at"]).to eq      "2015-09-12"
    expect(parsed_json["earned_at"]).to eq      "2015-09-13"
    expect(parsed_json["closed_at"]).to eq      "2015-09-14"
    expect(parsed_json["clicked_at"]).to eq     "2015-09-15"
    expect(parsed_json["declined_at"]).to eq    "2015-09-16"
    expect(parsed_json["denied_at"]).to eq      "2015-09-17"
    expect(parsed_json["nudged_at"]).to eq      "2015-09-18"
    expect(parsed_json["called_at"]).to eq      "2015-09-19"
    expect(parsed_json["redenied_at"]).to eq    "2015-09-20"
    expect(parsed_json["decline_reason"]).to eq "something"

    card = parsed_json["card"]

    expect(card.keys).to match_array(%w[name network bp type bank])

    expect(card["name"]).to eq "My awesome card"
    expect(card["network"]).to eq "visa"
    expect(card["bp"]).to eq "personal"

    bank = card["bank"]

    expect(bank.keys).to match_array(%w[name personal_phone business_phone])

    expect(bank["name"]).to eq "Chase"
    expect(bank["personal_phone"]).to eq "888-245-0625"
    expect(bank["business_phone"]).to eq "800 453-9719"
  end
end
