class Card::Cell < Trailblazer::Cell
  def image_tag(size = "180x114")
    super model.image.url, size: size
  end
end
