require "rails_helper"

describe NewTravelPlanForm, type: :model do

  let(:account) { Account.new }
  let(:form)  { described_class.new(account) }
  subject { form }

  it { is_expected.to validate_presence_of(:earliest_departure) }
  it { is_expected.to validate_presence_of(:from_id) }
  it { is_expected.to validate_presence_of(:to_id) }
  it { is_expected.to validate_presence_of(:no_of_passengers) }
  it { is_expected.to validate_numericality_of(:no_of_passengers)\
                                  .is_greater_than_or_equal_to(1) }
  it { is_expected.to validate_inclusion_of(:type)
                                  .in_array(["return", "single"]) }

  it { is_expected.to validate_length_of(:further_information).
                        is_at_most(500) }

  context "iff earliest departure is in the past" do
    it "is invalid" do
      def errors; form.tap(&:valid?).errors[:earliest_departure] end
      expect(errors).to be_empty
      form.earliest_departure = Date.yesterday.strftime("%m/%d/%Y")
      expect(errors).not_to be_empty
      form.earliest_departure = Date.today.strftime("%m/%d/%Y")
      expect(errors).to be_empty
      form.earliest_departure = Date.tomorrow.strftime("%m/%d/%Y")
      expect(errors).to be_empty
    end
  end

end
