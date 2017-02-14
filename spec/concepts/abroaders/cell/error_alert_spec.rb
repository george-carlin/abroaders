require 'cells_helper'

RSpec.describe Abroaders::Cell::ErrorAlert do
  example '#show' do
    rendered = show(nil, content: 'My totally awesome content!')

    expect(rendered).to have_content 'My totally awesome content!'

    expect(rendered).to have_selector '.alert.alert-danger'
    expect(rendered).to have_selector 'button.close'
  end
end
