# Cells take a special argument [:context][:controller] which lets them access
# methods available in the controller such as routes. When you call `cell` in a
# controller or view, this context gets passed in automatically, but it doesn't
# happen in specs. If you're testing a cell that renders routes you'll need to
# initialize the cell with something like this:
#
# let(:cell) { MyCell.(model, context: CELL_CONTEXT).show }

class CellContextController
  include Rails.application.routes.url_helpers
end

CELL_CONTEXT = { controller: CellContextController.new }.freeze
