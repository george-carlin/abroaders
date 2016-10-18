module PaginationHelper
  extend ActiveSupport::Concern

  # Override will_paginate so it always uses the renderer provided by the
  # will_paginate-bootstrap gem. As long as we're using Bootstrap I can't
  # imagine we're going to be using will_paginate without this renderer.
  def will_paginate(assocations)
    super(assocations, renderer: BootstrapPagination::Rails)
  end
end
