require 'rails_helper'

RSpec.describe AdminArea::Person::Cell::SpendingInfo, type: :view do
  let(:cell) { described_class }
  let(:person) { Struct.new(:id, :spending_info).new(1, nil) }

  def render_cell(person)
    cell.(person, context: CELL_CONTEXT).()
  end

  example 'when person has no spending info' do
    expect(render_cell(person)).to eq 'User has not added their spending info'
  end

  example 'when person has spending info' do
    person.spending_info = build(:spending_info)
    rendered = render_cell(person)
    expect(rendered).not_to have_content 'User has not added their spending info'
    expect(rendered).to have_link 'Edit'
  end
end
