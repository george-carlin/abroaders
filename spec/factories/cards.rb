FactoryGirl.define do
  factory :card do
    sequence(:code) do |n|
      str = "AAA"
      n.times { str.next! }
      str
    end
    sequence(:name) { |n| "Example Card #{n}" }
    network { Card.networks.keys.sample }
    bp      { Card.bps.keys.sample }
    type    { Card.types.keys.sample }
    bank
    annual_fee_cents { rand(500_00) + 10_00 }
    image_file_name    { 'example_card_image.png' }
    image_content_type { 'image/png' }
    image_file_size    { 256 }
    image_updated_at   { Time.now }

    # See https://github.com/thoughtbot/paperclip/issues/1333
    after(:create) do |card|
      image_file = Rails.root.join("spec", "support", card.image_file_name)

      # cp test image to directories
      %i[original large medium small].each do |size|
        dest_path = card.image.path(size)
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

    trait :chase do
      bank :chase
    end

    trait :us_bank do
      bank :us_bank
    end
  end
end
