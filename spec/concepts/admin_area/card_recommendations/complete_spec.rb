require 'rails_helper'

RSpec.describe AdminArea::CardRecommendations::Complete do
  let(:op) { described_class }

  let(:person) { create(:person) }

  example 'completing recs with no note' do
    result = op.(
      person_id: person.id,
      recommendation_note: '',
    )

    expect(result.success?).to be true
    person.reload
    expect(person).to eq result['person']
    expect(person.account.recommendation_notes.count).to eq 0
    expect(person.last_recommendations_at).to be_within(5.seconds).of(Time.now)
  end

  example 'completing recs with a note' do
    result = op.(
      person_id: person.id,
      recommendation_note: 'I like to leave notes',
    )

    expect(result.success?).to be true
    person.reload
    expect(person.account.recommendation_notes.count).to eq 1
    expect(person.account.recommendation_notes.last.content).to eq 'I like to leave notes'
    expect(person.last_recommendations_at).to be_within(5.seconds).of(Time.now)
  end

  example 'note with trailing whitespace' do
    result = op.(
      person_id: person.id,
      recommendation_note: '    what   ',
    )
    expect(result.success?).to be true
    person.reload
    expect(person.account.recommendation_notes.last.content).to eq 'what'
  end

  example "note that's only whitespace" do
    result = op.(
      person_id: person.id,
      recommendation_note: "     \n \n \t\ \t ",
    )
    expect(result.success?).to be true

    person.reload
    expect(person.account.recommendation_notes.count).to eq 0
  end
end
