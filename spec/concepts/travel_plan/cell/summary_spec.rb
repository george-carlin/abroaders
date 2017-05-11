require 'cells_helper'

RSpec.describe TravelPlan::Cell::Summary do
  controller TravelPlansController

  class FlightSummaryStub
    def self.call(flight, *)
      "Flight #{flight.id}"
    end
  end

  before do
    allow(described_class).to receive(:flight_summary_cell) { FlightSummaryStub }
  end

  let(:plan) do
    result = TravelPlan.new(
      id: 1,
      depart_on: Date.new(2020, 2, 1),
      type: 'one_way',
      no_of_passengers: 5,
      accepts_business_class: true,
      accepts_economy: true,
    )
    flight = Struct.new(:id, :to, :from).new(456)
    allow(result).to receive(:flights).and_return [flight]
    allow(result).to receive(:persisted?).and_return(true)
    result
  end

  example 'a round-trip plan' do
    plan.type = 'round_trip'
    plan.return_on = Date.new(2025, 2, 1)
    rendered = cell(plan).()
    expect(rendered).to have_content 'Round trip'
    expect(rendered).to have_content '02/01/20'
    expect(rendered).to have_content '02/01/25'
    # no further info:
    expect(rendered).not_to have_content 'Notes:'
    expect(rendered).to have_content 'E B'
  end

  example 'a one-way plan' do
    plan.return_on = nil
    plan.accepts_first_class = true
    plan.accepts_economy = false
    plan.accepts_premium_economy = true
    plan.further_information = 'qwerqwerqwer'
    one_way = cell(plan).()
    expect(one_way).to have_content 'One-way'
    expect(one_way).to have_content '02/01/20'
    expect(one_way).not_to have_content '02/01/25'
    expect(one_way).to have_content 'PE B 1st'
    expect(one_way).to have_content 'Notes: qwerqwerqwer'
  end

  it 'has a link to delete the plan' do
    rendered = cell(plan).()
    expect(rendered).to have_link 'Delete', href: travel_plan_path(plan)
  end

  it 'handles legacy travel plans with no return date' do # bug fix
    plan.type      = 'round_trip'
    plan.return_on = nil
    rendered = cell(plan).()
    expect(rendered).to have_content 'Round trip'
  end

  describe 'showing the Edit button' do
    example 'plan is editable' do
      allow(plan).to receive(:editable?).and_return(true)
      expect(cell(plan).()).to have_link 'Edit', href: edit_travel_plan_path(plan.id)
    end

    example 'plan is not editable' do
      allow(plan).to receive(:editable?).and_return(false)
      expect(cell(plan).()).not_to have_link 'Edit'
    end

    example 'with `admin: true` option' do
      allow(plan).to receive(:editable?).and_return(true)
      expect(cell(plan, admin: true).()).not_to have_link 'Edit'
    end
  end

  it 'escapes HTML' do
    plan.further_information = '<script>'
    expect(raw_cell(plan)).to include '&lt;script&gt;'
  end
end
