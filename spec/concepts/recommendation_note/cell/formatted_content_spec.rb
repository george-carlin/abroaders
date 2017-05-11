require 'cells_helper'

RSpec.describe RecommendationNote::Cell::FormattedContent do
  let(:rec_note_class) { Struct.new(:content) }
  example '#show' do
    note = rec_note_class.new(<<-EOL.strip_heredoc
      Multiple paragraphs.

      And a link! http://example.com
    EOL
                             )
    rendered = cell(note).()
    expect(rendered).to have_selector 'p', text: 'Multiple paragraphs'
    expect(rendered).to have_selector 'p', text: 'And a link!'
    expect(rendered).to have_link 'http://example.com', href: 'http://example.com'
  end

  example 'protected against XSS' do
    note = rec_note_class.new('<script>')
    expect(raw_cell(note)).to include('&lt;script&gt;')
  end
end
