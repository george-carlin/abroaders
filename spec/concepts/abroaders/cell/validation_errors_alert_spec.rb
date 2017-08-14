require 'cells_helper'

RSpec.describe Abroaders::Cell::ValidationErrorsAlert do
  context 'with a Reform object' do
    let(:model_class) { Struct.new(:name) }

    context 'that uses ActiveModel validations' do
      let(:form_class) do
        Class.new(Reform::Form) do
          property :name
          validates :name, presence: true
        end
      end

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

    context 'that uses dry-validation' do
      let(:form_class) do
        Class.new(Reform::Form) do
          feature Reform::Form::Dry
          property :name
          validation do
            required(:name).filled
          end
        end
      end

      example 'no errors' do
        form = form_class.new(model_class.new)
        expect(form.validate(name: 'X')).to be true

        expect(described_class.(form).()).to eq ''
      end

      example 'with errors' do
        form = form_class.new(model_class.new)
        expect(form.validate(name: '')).to be false

        expect(described_class.(form).()).to include "Name must be filled"
      end
    end
  end

  context 'with an ActiveModel object' do
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

    example 'unvalidated' do
      model = model_class.new
      expect(described_class.(model).()).to eq ''
    end

    example 'with errors' do
      model = model_class.new
      model.name = ''
      expect(model.valid?).to be false

      expect(described_class.(model).()).to include "Name can't be blank"
    end
  end

  context 'with an ActiveRecord object' do
    class MyRecord < ActiveRecord::Base
      self.table_name = 'accounts'

      attr_accessor :email
      validates :email, presence: true
    end

    example 'no errors' do
      model = MyRecord.new.tap { |m| m.email = 'email@email.com' }
      expect(model.valid?).to be true

      expect(described_class.(model).()).to eq ''
    end

    example 'unvalidated' do
      model = MyRecord.new
      expect(described_class.(model).()).to eq ''
    end

    example 'with errors' do
      model = MyRecord.new
      expect(model.valid?).to be false

      expect(described_class.(model).()).to include "Email can't be blank"
    end
  end
end
