require 'rails_helper'

RSpec.describe TravelPlan::Cell::Summary, type: :view do
  let(:plan) do
    p = TravelPlan.new(
      id: 1,
      depart_on: Date.new(2020, 2, 1),
      return_on: Date.new(2025, 2, 1),
      type: 'return',
      no_of_passengers: 5,
      accepts_business_class: true,
      accepts_economy: true,
    )
    p.flights << Flight.new(from: create(:airport), to: create(:airport))
    allow(p).to receive(:persisted?).and_return(true)
    p
  end

  def render_cell(plan)
    described_class.(plan, context: CELL_CONTEXT).show
  end

  it 'shows info about the plan' do
    round_trip = render_cell(plan)
    expect(round_trip).to have_content 'Round trip'
    expect(round_trip).to have_content '02/01/20'
    expect(round_trip).to have_content '02/01/25'
    # no further info:
    expect(round_trip).not_to have_content 'Notes:'
    expect(round_trip).to have_content 'E B'

    plan.type = 'single'
    plan.return_on = nil
    plan.accepts_first_class = true
    plan.accepts_economy = false
    plan.accepts_premium_economy = true
    plan.further_information = "qwerqwerqwer"
    one_way = render_cell(plan)
    expect(one_way).to have_content 'One-way'
    expect(one_way).to have_content '02/01/20'
    expect(one_way).not_to have_content '02/01/25'
    expect(one_way).to have_content 'PE B 1st'
    expect(one_way).to have_content 'Notes: qwerqwerqwer'
  end

  it "handles legacy travel plans with no return date" do # bug fix
    plan.return_on = nil
    cell = render_cell(plan)
    expect(cell).to have_content 'Round trip'
  end

  it "has a link to edit the plan iff it is editable" do
    yes = render_cell(plan)
    expect(yes).to have_link 'Edit', href: edit_travel_plan_path(1)
    plan.flights = nil
    plan.flights << Flight.new(from: create(:country), to: create(:country))
    no = render_cell(plan)
    expect(no).not_to have_link 'Edit'
  end
end
