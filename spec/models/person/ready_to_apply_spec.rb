require "rails_helper"

describe Person::ReadyToApply do

  describe "#ready_to_apply!" do

    context "when the person is not persisted" do
      let(:person) { build(:person, eligible: true) }
      it "doesn't save the person" do
        expect{person.ready_to_apply!}.not_to change{Person.count}
      end

      it "marks the person as ready to apply" do
        expect(person.onboarded_readiness?).to be false
        person.ready_to_apply!
        expect(person).to be_ready_to_apply
      end

      it "doesn't save the readiness status" do
        person.ready_to_apply!
        expect(person).not_to be_persisted
      end
    end

    context "when the person is persisted" do
      let(:person) { create(:person, eligible: true) }

      it "marks the person as ready to apply" do
        expect(person.onboarded_readiness?).to be false
        person.ready_to_apply!
        expect(person).to be_ready_to_apply
      end

      it "saves the readiness status" do
        person.ready_to_apply!
        expect(person).to be_persisted
      end
    end
  end

  describe "#unready_to_apply!" do

    context "when the person is not persisted" do
      let(:person) { build(:person, eligible: true) }
      it "doesn't save the person" do
        expect{person.unready_to_apply!}.not_to change{Person.count}
      end

      it "marks the person as unready to apply" do
        expect(person.onboarded_readiness?).to be false
        person.unready_to_apply!
        expect(person).to be_unready_to_apply
      end

      it "doesn't save the readiness status" do
        person.unready_to_apply!
        expect(person).not_to be_persisted
      end

      context "when passed a reason" do
        it "adds the unreadiness reason" do
          person.unready_to_apply!(reason: "Because")
          expect(person.unreadiness_reason).to eq "Because"
        end
      end
    end

    context "when the person is persisted" do
      let(:person) { create(:person, eligible: true) }

      it "marks the person as unready to apply" do
        expect(person.onboarded_readiness?).to be false
        person.unready_to_apply!
        expect(person).to be_unready_to_apply
      end

      it "saves the readiness status" do
        person.unready_to_apply!
        expect(person).to be_persisted
      end

      context "when passed a reason" do
        it "saves the unreadiness reason" do
          person.unready_to_apply!(reason: "Because")
          expect(person.unreadiness_reason).to eq "Because"
        end
      end
    end
  end

  describe "#ready_to_apply? and #unready_to_apply?" do

    context "when the person is ready" do
      let(:person) { build(:person, eligible: true, ready: true) }
      it "shows ready" do
        expect(person.ready_to_apply?).to be true
        expect(person.unready_to_apply?).to be false
      end
    end

    context "when the person is not ready" do
      let(:person) { build(:person, eligible: true, ready: false) }
      it "shows unready" do
        expect(person.ready_to_apply?).to be false
        expect(person.unready_to_apply?).to be true
      end
    end
  end

end
