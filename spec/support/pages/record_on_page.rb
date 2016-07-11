require_relative "./object_on_page"

# A Page Object which encapsulates a single instance of a model (usually an
# ActiveRecord model) and the subsection of the DOM tree where that model is
# displayed. E.g. if you have a page that displays a <table> of Cards, each
# <tr> in the table body will display information about a single Card.  In that
# case, you could use a subclass of RecordOnPage called CardOnPage which would
# contain methods to let you test the contents of the card's <tr> and interact
# with it.
#
# RecordOnPage will find the element for the given model by calling
# RecordOnPage#dom_id(model), which defaults to
# ActionView::RecordIdentifier#dom_id(model).  So for example in the above Card
# example, if the Card's ID is 5 then CardOnPage by default would assume that
# the element that displays the Card would have an HTML ID of "card_5". You can
# change this by overriding `dom_id` in subclasses
class RecordOnPage < ObjectOnPage
  include ActionView::RecordIdentifier

  attr_reader :model

  def initialize(model, spec_context)
    super(spec_context)
    @model = model
  end

  def dom_selector
    "#" << dom_id
  end

  def dom_id(prefix=nil)
    super(model, prefix)
  end

  def id
    model.id
  end

end
