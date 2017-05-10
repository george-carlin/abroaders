class CardProduct::ProcessImage
  def self.call(card_product, image_file, save: true)
    ratio = CardProduct::IMAGE_ASPECT_RATIO

    card_product.image(image_file) do |p|
      p.process!(:original)
      p.process!(:medium) { |job| job.thumb!("210x#{(210 / ratio).to_i}>") }
      p.process!(:small) { |job| job.thumb!("140x#{(140 / ratio).to_i}>") }
    end
    card_product
  end
end
