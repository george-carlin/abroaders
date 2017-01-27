require "rails_helper"

RSpec.describe TravelPlan::Form, type: :model do
  let(:account) { Account.new }
  let(:form) { new_form }
  subject { form }

  def new_form
    described_class.new(account.travel_plans.new)
  end

  # Returns the errors object for the given attributes. For convenience, if
  # your attributes hash only has one key, it will return the errors for that
  # specific key rather than the whole error object.
  def errors_for(attrs = {})
    form = new_form
    form.validate(attrs)
    if attrs.keys.length == 1
      form.errors[attrs.keys.first]
    else
      form.errors
    end
  end

  describe 'prepopulate!' do
    let(:form) { described_class.new(travel_plan) }

    context 'when TP is being edited' do
      let(:travel_plan) { create(:travel_plan, depart_on: '2020-01-02', return_on: '2025-12-05') }
      let(:flight) { travel_plan.flights[0] }

      before { form.prepopulate! }

      it 'fills "from" and "to" with the airport info' do
        expect(form.from).to eq flight.from.full_name
        expect(form.to).to eq flight.to.full_name
      end
    end

    context 'when TP is new' do
      let(:travel_plan) { TravelPlan.new }
      it 'leaves from/to and dates blank' do
        expect(form.from).to be nil
        expect(form.to).to be nil
      end
    end
  end

  describe 'validations' do
    %w[from to].each do |dest|
      describe dest do
        it 'fails gracefully when blank or invalid' do
          expect(errors_for(dest => ' ')).to include "can't be blank"
          [
            'ioajwera',
            'jaoiwerj a (AA)',
            'iajower (AAAA)',
            'iajower (AAAA',
          ].each do |val|
            expect(errors_for(dest => val)).to include 'is invalid'
          end
        end
      end
    end

    it { is_expected.to validate_presence_of(:depart_on) }
    it { is_expected.to validate_presence_of(:no_of_passengers) }

    describe "#no_of_passengers" do
      it 'must be >= 1, <= 20' do
        def errors_for_no(no)
          errors_for(no_of_passengers: no)
        end

        expect(errors_for_no(0)).to eq ['must be greater than or equal to 1']
        expect(errors_for_no(1)).to be_empty
        expect(errors_for_no(20)).to be_empty
        expect(errors_for_no(21)).to eq ['must be less than or equal to 20']
      end
    end

    it 'further_information is <= 500 chars' do
      def errors_for_length(l)
        errors_for(further_information: ('a' * l))
      end

      expect(errors_for_length(500)).to be_empty
      expect(errors_for_length(501)).to eq ['is too long (maximum is 500 characters)']
    end

    specify "depart_on must be present and not in the past" do
      def errors_for_date(date)
        errors_for(depart_on: date)
      end

      expect(errors_for_date(nil)).to eq ["can't be blank"]
      form.depart_on = Time.zone.yesterday
      expect(errors_for_date(Time.zone.yesterday)).to eq ["can't be in the past"]
      expect(errors_for_date(Time.zone.today)).to be_empty
    end

    specify 'return_on must be blank when type is single' do
      form.type = 'single'
      expect(form).to validate_absence_of(:return_on)
    end

    context "when type is return" do
      specify "return date must be present and not in the past" do
        def errors_for_date(date)
          errors_for(return_on: date, type: 'return')[:return_on]
        end

        expect(errors_for_date(nil)).to include "can't be blank"
        expect(errors_for_date(Time.zone.yesterday)).to include "can't be in the past"
        expect(errors_for_date(Time.zone.today)).to be_empty
      end

      specify "return date must be >= departure" do
        def errors_for_dates(dep, ret)
          errors_for(depart_on: dep, return_on: ret, type: 'return')[:return_on]
        end

        tomorrow = Time.zone.tomorrow
        today    = Time.zone.today
        expect(errors_for_dates(tomorrow, today)).to eq ["can't be earlier than departure date"]
        expect(errors_for_dates(tomorrow, tomorrow)).to be_empty
      end
    end
  end

  describe 'saving' do
    let(:account) { create(:account, :onboarded) }
    let(:airport_0) { create(:airport) }
    let(:airport_1) { create(:airport) }
    let(:account)   { create(:account, :onboarded) }

    example 'creating a new travel plan' do
      form = described_class.new(account.travel_plans.new)
      expect(
        form.validate(
          from: "#{airport_0.name} (#{airport_0.code})",
          to: "#{airport_1.name} (#{airport_1.code})",
          type: 'return',
          no_of_passengers: 5,
          accepts_economy: true,
          accepts_premium_economy: true,
          accepts_business_class: true,
          accepts_first_class: true,
          depart_on: '05/08/2025',
          return_on: '02/03/2026',
          further_information: 'blah blah blah',
        ),
      ).to be true
      expect(form.save).to be true
      tp = form.model
      expect(tp.flights[0].from).to eq airport_0
      expect(tp.flights[0].to).to eq airport_1
      expect(tp.type).to eq 'return'
      expect(tp.no_of_passengers).to eq 5
      expect(tp.accepts_economy).to be true
      expect(tp.accepts_premium_economy).to be true
      expect(tp.accepts_business_class).to be true
      expect(tp.accepts_first_class).to be true
      expect(tp.depart_on).to eq Date.new(2025, 5, 8)
      expect(tp.return_on).to eq Date.new(2026, 2, 3)
      expect(tp.further_information).to eq 'blah blah blah'
    end

    example 'updating a travel plan' do
      plan = TravelPlan::Operations::Create.(
        {
          travel_plan: {
            from: "#{airport_0.name} (#{airport_0.code})",
            to: "#{airport_1.name} (#{airport_1.code})",
            type: 'return',
            no_of_passengers: 5,
            accepts_economy: true,
            accepts_premium_economy: true,
            accepts_business_class: true,
            accepts_first_class: true,
            depart_on: '05/08/2025',
            return_on: '02/03/2026',
            further_information: 'blah blah blah',
          },
        },
        'account' => account,
      )['model']

      form = described_class.new(plan)
      expect(
        form.validate(
          from: "#{airport_1.name} (#{airport_1.code})",
          to: "#{airport_0.name} (#{airport_0.code})",
          type: 'return',
          no_of_passengers: 3,
          accepts_economy: false,
          accepts_premium_economy: false,
          accepts_business_class: false,
          accepts_first_class: false,
          depart_on: '05/08/2023',
          return_on: '02/03/2024',
          further_information: 'yeah yeah yeah',
        ),
      ).to be true
      expect(form.save).to be true
      plan.reload
      expect(plan.flights[0].from).to eq airport_1
      expect(plan.flights[0].to).to eq airport_0
      expect(plan.type).to eq 'return'
      expect(plan.no_of_passengers).to eq 3
      expect(plan.accepts_economy).to be false
      expect(plan.accepts_premium_economy).to be false
      expect(plan.accepts_business_class).to be false
      expect(plan.accepts_first_class).to be false
      expect(plan.depart_on).to eq Date.new(2023, 5, 8)
      expect(plan.return_on).to eq Date.new(2024, 2, 3)
      expect(plan.further_information).to eq 'yeah yeah yeah'
    end
  end
end
