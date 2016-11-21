class PhoneNumber < ApplicationRecord
  class Create < Trailblazer::Operation
    def self.normalize(string)
      string.gsub(/\D/, '')
    end

    contract do
      feature Reform::Form::Coercion

      property :number, type: Types::Stripped::String

      validation do
        required(:number).filled { str? && max_size?(15) }
      end
    end

    def process(params)
      validate params[:phone_number] do |f|
        # TODO urgh
        f.sync
        f.model.normalized_number = self.class.normalize(f.number)
        f.model.save
      end
    end

    private

    def model!(params)
      params[:current_account].build_phone_number
    end
  end
end
