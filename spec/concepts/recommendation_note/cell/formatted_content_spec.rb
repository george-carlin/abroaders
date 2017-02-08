require 'rails_helper'

RSpec.describe RecommendationNote::Cell::FormattedContent, type: :view do
  let(:cell) { described_class }

  example '#show' do
    note = Struct.new(:content).new(<<-EOL.strip_heredoc
      Multiple paragraphs.

      And a link! http://example.com

      <script>alert('watch out for XSS')</script>
    EOL
                                   )
    rendered = cell.(note).()
    expect(rendered).to have_selector 'p', text: 'Multiple paragraphs'
    expect(rendered).to have_selector 'p', text: 'And a link!'
    expect(rendered).to have_link 'http://example.com', href: 'http://example.com'
    expect(rendered).to include('&lt;script&gt;')
  end
end
