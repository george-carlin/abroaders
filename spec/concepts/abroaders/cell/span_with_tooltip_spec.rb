require 'cells_helper'

RSpec.describe Abroaders::Cell::SpanWithTooltip do
  it '' do
    rendered = cell(text: 'Hello', tooltip_text: 'Hola').()
    expect(rendered).to have_selector 'span.SpanWithTooltip', text: /\AHello\z/
    span = rendered.find('span.SpanWithTooltip')
    expect(span['data-title']).to eq 'Hola'
    expect(span['data-toggle']).to eq 'tooltip'
  end
end
