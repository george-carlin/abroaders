FactoryGirl.define do
  factory :card_product, class: 'Card::Product' do
    sequence(:code) do |n|
      str = "AAA"
      n.times { str.next! }
      str
    end
    sequence(:name) { |n| "Example Card #{n}" }
    network { Card::Product.networks.keys.sample }
    bp      { Card::Product.bps.keys.sample }
    type    { Card::Product.types.keys.sample }
    bank
    annual_fee_cents { rand(500_00) + 10_00 }
    image_file_name    { 'example_card_image.png' }
    image_content_type { 'image/png' }
    image_file_size    { 256 }
    image_updated_at   { Time.zone.now }

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

    currency { Currency.all.sample || create(:currency) }

    trait :visa do
      network "visa"
    end

    trait :mastercard do
      network "mastercard"
    end

    trait :business do
      bp :business
    end

    trait :personal do
      bp :personal
    end

    trait :hidden do
      shown_on_survey false
    end
  end
end
