require "rails_helper"

describe CardAccount::Status do

  let(:date) { Date.today }
  let(:error_class) { CardAccount::InvalidStatus }
  let(:status) { described_class.new }

  # There are 512 (2^9) possible combinations of present/not present for these
  # timestamps! But luckily most of them will never be reached
  TIMESTAMPS = CardAccount::Status::TIMESTAMPS.map(&:to_sym)

  describe "validations" do
    def valid_attributes?(attrs)
      described_class.new(attrs).valid?
    end

    context "when recommended_at is nil" do
      specify "opened_at must be present; closed_at may or may not be present" do
        expect(valid_attributes?(opened_at: date)).to be true
        expect(valid_attributes?(opened_at: date, closed_at: date)).to be true
      end

      describe "all other timestamps except 'opened_at' and 'closed_at'" do
        specify "must be blank" do
          (TIMESTAMPS - [:recommended_at, :opened_at, :closed_at]).each do |timestamp|
            expect(valid_attributes?({timestamp => date})).to be false
          end
        end
      end
    end

    context "when recommended_at is present" do
      let(:attrs) { { recommended_at: date } }

      context "and declined_at is present" do
        before { attrs[:declined_at] = date }

        specify "every other timestamp must be nil" do
          expect(valid_attributes?(attrs)).to be true

          (TIMESTAMPS - [:recommended_at, :declined_at]).each do |timestamp|
            expect(valid_attributes?(attrs.merge(timestamp => date))).to be false
          end
        end
      end

      context "and declined_at is nil" do
        context "and expired_at is present" do
          before { attrs[:expired_at] = date }
          specify "every other timestamp must be nil" do
            expect(valid_attributes?(attrs)).to be true

            (TIMESTAMPS - [:recommended_at, :expired_at]).each do |timestamp|
              expect(valid_attributes?(attrs.merge(timestamp => date))).to be false
            end
          end
        end

        context "and expired_at is nil" do
          context "and applied_at is nil" do
            specify "every other timestamp must be nil" do
              expect(valid_attributes?(attrs)).to be true

              (TIMESTAMPS - [:expired_at, :recommended_at, :declined_at, :applied_at]
              ).each do |timestamp|
                expect(valid_attributes?(attrs.merge(timestamp => date))).to be false
              end
            end
          end

          context "and applied_at is present" do
            before { attrs[:applied_at] = date }

            context "and closed_at is present" do
              before { attrs[:closed_at] = date }
              specify "opened_at must be present" do
                expect(valid_attributes?(attrs)).to be false
                expect(valid_attributes?(attrs.merge(opened_at: date))).to be true
              end
            end

            context "and redenied_at is present" do
              before { attrs[:redenied_at] = date }

              specify "denied_at must be present" do
                expect(valid_attributes?(attrs)).to be false
                expect(valid_attributes?(attrs.merge(denied_at: date))).to be true
              end
            end
          end
        end
      end
    end
  end

  # That eliminates about 3/4 of the possible combinations of timestamps.
  # There are many other invalid combinations (e.g. if redenied_at is present,
  # denied_at must also be present) but it's too painful to test them all

  describe "#name" do
    # possible values: [recommended, declined, applied, denied, open, closed]
    let(:attrs) { {} }

    let(:status) { described_class.new(attrs) }

    subject { status.name }

    context "when closed_at is present" do
      before { attrs.merge!(closed_at: date, opened_at: date) }

      it { is_expected.to eq "closed" }
    end

    context "when expired_at is present" do
      before { attrs.merge!(expired_at: date, opened_at: date) }
      it { is_expected.to eq "expired" }
    end

    context "when closed_at is nil" do
      before { attrs[:recommended_at] = date }

      context "and applied_at is present" do
        before { attrs[:applied_at] = date }

        context "and opened_at is present" do
          before { attrs[:opened_at] = date }
          it { is_expected.to eq "open" }
        end

        context "and opened_at is nil" do
          context "and denied_at is present" do
            before { attrs[:denied_at] = date }
            it { is_expected.to eq "denied" }
          end

          context "and denied_at is nil" do
            it { is_expected.to eq "applied" }
          end
        end
      end

      context "and applied_at is not present" do
        it { is_expected.to eq "recommended" }
      end

      context "and declined_at is present" do
        before { attrs[:declined_at] = date }
        it { is_expected.to eq "declined" }
      end
    end
  end
end
