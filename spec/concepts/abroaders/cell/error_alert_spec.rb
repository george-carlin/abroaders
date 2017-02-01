require 'rails_helper'

RSpec.describe Abroaders::Cell::ErrorAlert, type: :view do
  let(:cell) { described_class }

  example '#show' do
    rendered = described_class.(nil, content: 'My totally awesome content!').()
    expect(rendered).to include('My totally awesome content!')

    expect(rendered).to have_selector '.alert.alert-danger'
    expect(rendered).to have_selector 'button.close'
  end
end
