require 'cells_helper'

RSpec.describe Abroaders::Cell::ValidationErrorsAlert do
  let(:form_class)   { Struct.new(:errors) }
  let(:errors_class) { Struct.new(:messages) }

  example 'no errors' do
    form = form_class.new(errors_class.new({}))
    expect(show(form).raw).to eq ''
  end

  example 'with errors' do
    messages =  { name: ['must be hip'] }
    form = form_class.new(errors_class.new(messages))
    expect(show(form)).to have_content 'Name must be hip'
    messages[:name] << 'must be funky'
    form = form_class.new(errors_class.new(messages))
    expect(show(form)).to have_content 'Name must be hip and must be funky'
  end
end
