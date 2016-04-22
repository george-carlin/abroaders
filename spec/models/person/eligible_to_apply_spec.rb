require "rails_helper"

describe Person::EligibleToApply do

  describe "#eligible_to_apply!" do
    context "when the person is not persisted" do
      let(:person) { build(:person) }
      it "doesn't save the person" do
        expect{person.eligible_to_apply!}.not_to change{Person.count}
      end

      it "marks the person as eligible to apply" do
        expect(person.onboarded_eligibility?).to be false
        person.eligible_to_apply!
        expect(person).to be_eligible_to_apply
      end

      it "doesn't save the eligibility status" do
        person.eligible_to_apply!
        expect(person.eligibility).not_to be_persisted
      end
    end

    context "when the person is persisted" do
      let(:person) { create(:person) }

      it "marks the person as eligible to apply" do
        expect(person.onboarded_eligibility?).to be false
        person.eligible_to_apply!
        expect(person).to be_eligible_to_apply
      end

      it "saves the eligibility status" do
        person.eligible_to_apply!
        expect(person.eligibility).to be_persisted
      end
    end
  end

  describe "#ineligible_to_apply!" do
    context "when the person is not persisted" do
      let(:person) { build(:person) }
      it "doesn't save the person" do
        expect{person.ineligible_to_apply!}.not_to change{Person.count}
      end

      it "marks the person as ineligible to apply" do
        expect(person.onboarded_eligibility?).to be false
        person.ineligible_to_apply!
        expect(person).to be_ineligible_to_apply
      end

      it "doesn't save the eligibility status" do
        person.ineligible_to_apply!
        expect(person.eligibility).not_to be_persisted
      end
    end

    context "when the person is persisted" do
      let(:person) { create(:person) }

      it "marks the person as ineligible to apply" do
        expect(person.onboarded_eligibility?).to be false
        person.ineligible_to_apply!
        expect(person).to be_ineligible_to_apply
      end

      it "saves the eligibility status" do
        person.ineligible_to_apply!
        expect(person.eligibility).to be_persisted
      end
    end
  end

  describe "#onboarded_eligibility?" do
    let(:person) { build(:person) }
    it "returns true iff eligibility is present (persisted or not)" do
      expect(person.onboarded_eligibility?).to be false
      person.ineligible_to_apply!
      expect(person.onboarded_eligibility?).to be true
      person.save!
      expect(person.eligibility).to be_persisted
      expect(person.onboarded_eligibility?).to be true
    end
  end

end
