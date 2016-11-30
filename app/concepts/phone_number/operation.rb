require_dependency 'reform/form/dry'

class PhoneNumber < ApplicationRecord
  class Create < Trailblazer::Operation
    def self.normalize(string)
      string.gsub(/\D/, '')
    end

    contract do
      feature Reform::Form::Coercion
      feature Reform::Form::Dry

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
        ApplicationRecord.transaction do
          f.model.save
          Account::Onboarder.new(params[:current_account]).add_phone_number!
        end
      end
    end

    private

    def model!(params)
      PhoneNumber.new(account: params[:current_account])
    end
  end
end
