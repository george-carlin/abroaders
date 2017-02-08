# Eventually we're going to split 'Card' into separate models called 'Card',
# 'CardRecommendation', and possibly 'CardApplication'. For now keep this
# pseudo-activerecord model around to help with some cells and form helpers
# (and to ease in renaming 'CardAccount' to 'Card')
class CardRecommendation
  include ActiveModel::Model

  def self.all(*args)
    Card.recommendations.where(args)
  end

  def self.find(*args)
    Card.recommendations.find(*args)
  end
end
