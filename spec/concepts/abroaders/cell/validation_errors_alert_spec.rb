require 'rails_helper'

RSpec.describe Abroaders::Cell::ValidationErrorsAlert do
  let(:cell) { described_class }

  let(:form_class)   { Struct.new(:errors) }
  let(:errors_class) { Struct.new(:messages) }

  example 'no errors' do
    form = form_class.new(errors_class.new({}))
    expect(cell.(form).()).to eq ''
  end

  example 'with errors' do
    messages =  { name: ['must be hip'] }
    form = form_class.new(errors_class.new(messages))
    expect(cell.(form).()).to include 'Name must be hip'
    messages[:name] << 'must be funky'
    form = form_class.new(errors_class.new(messages))
    expect(cell.(form).()).to include 'Name must be hip and must be funky'
  end
end
