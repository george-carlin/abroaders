class RecommendationRequest < RecommendationRequest.superclass
  module Cell
    # @!method self.call(account, options = {})
    #   @param account [Account] the currently logged-in account
    class Banner < Abroaders::Cell::Base
      # Banner with a button for the user to make a recommendation request,
      # and/or information about any unresolved requests or actionable recs
      # they might have. Shown at the top of most pages if there's currently
      # a logged-in (non-admin) user.
      #
      # Never show the banner if the current user is not onboarded.
      #
      # The banner consists of two parts: 1) Status (not yet implemented; class
      # is currently a stub), which tells you if e.g. you already have any
      # unresolved requests, or if you have recommendations that require
      # action, and 2) Form, which has a button to make a request (only
      # shown if you actually *can* make a request.)
      #
      # The Banner class itself is just a wrapper that displays the Status and
      # Form together. One or both of the Status and the Form may be absent
      # (i.e. they just return an empty string) based on various conditions.
      # If they're both absent, there's no need to display the banner at all.
      # So evaluate both components separately and only output the Banner's
      # wrapping div(s) if there's something to go inside them.
      #
      # There are certain pages where the banner should never appear, e.g. on
      # the confirmation survey itself. To handle this, return '' if the
      # current controller is blacklisted.
      def show
        raise 'model must be an Account' unless model.is_a?(Account)
        return '' unless model.onboarded?
        return '' if excluded_controller?
        form   = cell(Form, model).show
        status = cell(Status, model).show
        return '' if form.empty? && status.empty?

        content_tag :div, class: 'hpanel' do
          content_tag :div, class: 'panel-body' do
            content_tag :div, class: 'row' do
              "#{status}#{form}"
            end
          end
        end
      end

      private

      # The only pages I can think to exclude for now (other than ones which
      # are already excluded in #show, like onboarding pages),  are the ones
      # under RecommendationRequestsController. So I think that for now we can
      # blacklist things at the controller level instead of on a per-path
      # basis.
      def excluded_controller?
        [
          RecommendationRequestsController,
        ].include?(controller.class)
      end
    end
  end
end
