require "rails_helper"

describe Person::ReadyToApply do

  describe "#ready_to_apply!" do
    context "when the person is not persisted" do
      let(:person) { build(:person) }
      it "doesn't save the person" do
        expect{person.ready_to_apply!}.not_to change{Person.count}
      end

      it "marks the person as ready to apply" do
        expect(person.readiness_given?).to be false
        person.ready_to_apply!
        expect(person).to be_ready_to_apply
      end

      it "doesn't save the readiness status" do
        person.ready_to_apply!
        expect(person.readiness_status).not_to be_persisted
      end
    end

    context "when the person is persisted" do
      let(:person) { create(:person) }

      it "marks the person as ready to apply" do
        expect(person.readiness_given?).to be false
        person.ready_to_apply!
        expect(person).to be_ready_to_apply
      end

      it "saves the readiness status" do
        person.ready_to_apply!
        expect(person.readiness_status).to be_persisted
      end
    end
  end

  describe "#unready_to_apply!" do
    context "when the person is not persisted" do
      let(:person) { build(:person) }
      it "doesn't save the person" do
        expect{person.unready_to_apply!}.not_to change{Person.count}
      end

      it "marks the person as unready to apply" do
        expect(person.readiness_given?).to be false
        person.unready_to_apply!
        expect(person).to be_unready_to_apply
      end

      it "doesn't save the readiness status" do
        person.unready_to_apply!
        expect(person.readiness_status).not_to be_persisted
      end

      context "when passed a reason" do
        it "adds the unreadiness reason" do
          person.unready_to_apply!(reason: "Because")
          expect(person.unreadiness_reason).to eq "Because"
        end
      end
    end

    context "when the person is persisted" do
      let(:person) { create(:person) }

      it "marks the person as unready to apply" do
        expect(person.readiness_given?).to be false
        person.unready_to_apply!
        expect(person).to be_unready_to_apply
      end

      it "saves the readiness status" do
        person.unready_to_apply!
        expect(person.readiness_status).to be_persisted
      end

      context "when passed a reason" do
        it "saves the unreadiness reason" do
          person.unready_to_apply!(reason: "Because")
          expect(person.unreadiness_reason).to eq "Because"
        end
      end
    end
  end

end
