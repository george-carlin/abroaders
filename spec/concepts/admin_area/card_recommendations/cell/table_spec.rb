require 'cells_helper'

RSpec.describe AdminArea::CardRecommendations::Cell::Table do
  controller ApplicationController

  let(:person) { create_account(:eligible, :onboarded).owner }
  let(:recs) { Array.new(3) { create_rec(person: person) } }

  def render_for(recs, options = {})
    cell(described_class, recs, options).()
  end

  example '' do
    rendered = render_for(recs)
    recs.each do |rec|
      expect(rendered).to have_selector "#card_recommendation_#{rec.id}"
    end
    expect(rendered).not_to have_content person.first_name
  end

  example 'with_person_column: true' do
    rendered = render_for(recs, with_person_column: true)
    recs.each do |rec|
      row = rendered.find("#card_recommendation_#{rec.id}")
      expect(row).to have_content person.first_name
    end
  end
end
