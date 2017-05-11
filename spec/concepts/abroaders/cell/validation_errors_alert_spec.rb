require 'cells_helper'

RSpec.describe Abroaders::Cell::ValidationErrorsAlert do
  let(:form_class)   { Struct.new(:errors) }
  let(:errors_class) { Struct.new(:messages) }

  example 'no errors' do
    form = form_class.new(errors_class.new({}))
    expect(raw_cell(form)).to eq ''
  end

  example 'with errors' do
    messages =  { name: ['must be hip'] }
    form = form_class.new(errors_class.new(messages))
    expect(cell(form).()).to have_content 'Name must be hip'
    messages[:name] << 'must be funky'
    form = form_class.new(errors_class.new(messages))
    expect(cell(form).()).to have_content 'Name must be hip and must be funky'
  end

  describe '::ActiveModel' do
    describe 'with a Reform object' do
      let(:form_class) do
        Class.new(Reform::Form) do
          property :name
          validates :name, presence: true
        end
      end

      let(:model_class) { Struct.new(:name) }

      example 'no errors' do
        form = form_class.new(model_class.new)
        expect(form.validate(name: 'X')).to be true

        expect(described_class.(form).()).to eq ''
      end

      example 'with errors' do
        form = form_class.new(model_class.new)
        expect(form.validate(name: '')).to be false

        expect(described_class.(form).()).to include "Name can't be blank"
      end
    end

    describe 'with an ActiveModel object' do
      let(:model_class) do
        Class.new(Object) do
          include ActiveModel::Model
          include ActiveModel::Validations

          attr_accessor :name
          validates :name, presence: true

          # .valid? will crash if this method isn't defined:
          def self.model_name
            ActiveModel::Name.new(self, nil, 'DummyName')
          end
        end
      end

      example 'no errors' do
        model = model_class.new
        model.name = 'X'
        expect(model.valid?).to be true

        expect(described_class.(model).()).to eq ''
      end

      example 'with errors' do
        model = model_class.new
        model.name = ''
        expect(model.valid?).to be false

        expect(described_class.(model).()).to include "Name can't be blank"
      end
    end
  end
end
