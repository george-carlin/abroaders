FactoryGirl.define do
  factory :card_product, aliases: [:product] do
    sequence(:name) { |n| "Example Card #{n}" }
    annual_fee_cents { rand(500_00) + 10_00 }
    bank_id { Bank.all.pluck(:id).sample }
    network { CardProduct::Network.values.sample }
    personal { rand > 0.5 }
    type { CardProduct::Type.values.sample }

    # See https://github.com/thoughtbot/paperclip/issues/1333
    before(:create) do |product|
      image_file = Rails.root.join('spec', 'support', 'example_card_image.png')

      # TODO this is a duplicate of the logic in card_products#create
      # TODO will creating images like this in tests fuck up the development image
      # files? Can it be skipped entirely (so we don't slow down the tests?)
      # TODO suppress logs in test mode

      ratio = CardProduct::IMAGE_ASPECT_RATIO

      product.image(image_file) do |p|
        p.process!(:original)
        p.process!(:medium) { |job| job.thumb!("210x#{(210 / ratio).to_i}>") }
        p.process!(:small)  { |job| job.thumb!("140x#{(140 / ratio).to_i}>") }
      end
    end

    currency { Currency.all.sample || SampleDataMacros::Generator.instance.currency }

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
