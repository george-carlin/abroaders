FactoryGirl.define do
  factory :card_product, aliases: [:product] do
    sequence(:name) { |n| "Example Card #{n}" }
    annual_fee_cents { rand(500_00) + 10_00 }
    bank_id { Bank.all.pluck(:id).sample }
    image_content_type { 'image/png' }
    image_file_name    { 'example_card_image.png' }
    image_file_size    { 256 }
    image_updated_at   { Time.zone.now }
    network { CardProduct::Network.values.sample }
    personal { rand > 0.5 }
    type { CardProduct::Type.values.sample }

    # See https://github.com/thoughtbot/paperclip/issues/1333
    after(:create) do |product|
      image_file = Rails.root.join("spec", "support", product.image_file_name)

      # cp test image to directories
      %i[original large medium small].each do |size|
        dest_path = product.image.path(size)
        `mkdir -p #{File.dirname(dest_path)}`
        `cp #{image_file} #{dest_path}`
      end
    end

    currency { Currency.all.sample || create_currency }

    trait :visa do
      network 'visa'
    end

    trait :mastercard do
      network 'mastercard'
    end

    trait :business do
      business true
    end

    trait :personal do
      business false
    end

    trait :hidden do
      shown_on_survey false
    end
  end
end
