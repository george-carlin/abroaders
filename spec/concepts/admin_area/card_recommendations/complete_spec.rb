require 'rails_helper'

RSpec.describe AdminArea::CardRecommendations::Complete do
  let(:op) { described_class }

  let(:person)  { create(:person, :eligible) }
  let(:account) { person.account }

  example 'success - no note, no rec request' do
    result = op.(
      person_id: person.id,
      recommendation_note: '',
    )

    expect(result.success?).to be true
    person.reload
    expect(person).to eq result['person']
    expect(account.recommendation_notes.count).to eq 0
    expect(person.last_recommendations_at).to be_within(5.seconds).of(Time.now)
  end

  example 'success - completing recs with a note' do
    result = op.(
      person_id: person.id,
      recommendation_note: 'I like to leave notes',
    )

    expect(result.success?).to be true
    person.reload
    expect(account.recommendation_notes.count).to eq 1
    expect(account.recommendation_notes.last.content).to eq 'I like to leave notes'
    expect(person.last_recommendations_at).to be_within(5.seconds).of(Time.now)
  end

  example 'success - user has unresolved rec request' do
    create_rec_request('owner', account.reload)

    other_account = create(:account, :eligible)
    create_rec_request('owner', other_account)

    result = op.(person_id: person.id)
    expect(result.success?).to be true
    expect(account.reload.unresolved_recommendation_requests?).to be false
    expect(other_account.reload.unresolved_recommendation_requests?).to be true
  end

  example 'success - account has two users with unresolved rec requests' do
    create(:companion, :eligible, account: account)
    create_rec_request('both', account)

    expect(account.unresolved_recommendation_requests.count).to be 2

    result = op.(person_id: person.id)
    expect(result.success?).to be true

    expect(account.unresolved_recommendation_requests.count).to eq 0
  end

  example 'success - account has two users, one has unresolved rec req' do
    create(:companion, :eligible, account: account)
    create_rec_request('companion', account)

    expect(account.unresolved_recommendation_requests.count).to eq 1

    result = op.(person_id: person.id)
    expect(result.success?).to be true

    expect(account.unresolved_recommendation_requests.count).to eq 0
  end

  example 'success - note with trailing whitespace' do
    result = op.(
      person_id: person.id,
      recommendation_note: '    what   ',
    )
    expect(result.success?).to be true
    person.reload
    expect(person.account.recommendation_notes.last.content).to eq 'what'
  end

  example "success - note that's only whitespace" do
    result = op.(
      person_id: person.id,
      recommendation_note: "     \n \n \t\ \t ",
    )
    expect(result.success?).to be true

    person.reload
    expect(person.account.recommendation_notes.count).to eq 0
  end
end
