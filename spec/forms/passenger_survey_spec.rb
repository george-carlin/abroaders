require "rails_helper"

describe PassengerSurvey, type: :model do

  let(:survey) { described_class.new(Account.new) }
  subject { survey }

  it { is_expected.to validate_presence_of(:main_passenger_first_name) }
  it { is_expected.to validate_presence_of(:main_passenger_last_name) }
  it { is_expected.to validate_presence_of(:main_passenger_phone_number) }

  it { is_expected.to validate_length_of(:main_passenger_first_name)\
                                                          .is_at_most(50) }
  it { is_expected.to validate_length_of(:main_passenger_middle_names)\
                                                          .is_at_most(50) }
  it { is_expected.to validate_length_of(:main_passenger_last_name)\
                                                          .is_at_most(50) }
  it { is_expected.to validate_length_of(:main_passenger_phone_number)\
                                                          .is_at_most(20) }

  context "when the account does not a companion" do
    before { survey.has_companion = false }
    it { is_expected.not_to validate_presence_of(:companion_first_name) }
    it { is_expected.not_to validate_presence_of(:companion_last_name) }
    it { is_expected.not_to validate_presence_of(:companion_phone_number) }
  end

  context "when the account has a companion" do
    before { survey.has_companion = true }
    it { is_expected.to validate_presence_of(:companion_first_name) }
    it { is_expected.to validate_presence_of(:companion_last_name) }
    it { is_expected.to validate_presence_of(:companion_phone_number) }

    it { is_expected.to validate_length_of(:companion_first_name)\
                                                          .is_at_most(50) }
    it { is_expected.to validate_length_of(:companion_middle_names)
                                                          .is_at_most(50) }
    it { is_expected.to validate_length_of(:companion_last_name)
                                                          .is_at_most(50) }
    it { is_expected.to validate_length_of(:companion_phone_number)
                                                          .is_at_most(20) }
  end

end
