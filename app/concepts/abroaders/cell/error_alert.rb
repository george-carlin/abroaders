module Abroaders
  module Cell
    # A <div> with bootstrap 'alert-danger' classes - in other words, an error
    # message with red text and a red background (and a Bootstrappy button to
    # dismiss the alert.
    #
    # This isn't much use unless you give the alert some content, so pass
    # `:content` in as an option, which must be a string of HTML.
    class ErrorAlert < Trailblazer::Cell
      private

      def content
        options.fetch(:content)
      end
    end
  end
end
