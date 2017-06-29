module Abroaders::Cell
  # Takes the Rails flash and, renders a Bootstrap alert for each of the
  # following keys, if any are present (the colour in brackets is the colour of
  # the BS alert that will be rendered):
  #
  # :danger (red)
  # :success (green)
  # :warning (orange)
  # :info (blue)
  #
  # This corresponds to the CSS class names used by Bootstrap itself. Or use
  # 'error' as well; it'll look the same as 'danger', but 'error' feels like
  # a word we should include.
  #
  # This method will also output alerts for the keys 'alert' and 'notice' too,
  # because these are the keys Devise uses, but don't use them yourself.
  #
  # TODO make devise use the normal Bootstrap class names?
  #
  # @!method self.call(flash, options = {})
  #   @param flash [ActionDispatch::Flash] the Rails flash object
  class Layout::FlashAlerts < Abroaders::Cell::Base
    def show
      result = ''
      {
        alert:   'danger',
        danger:  'danger',
        error:   'danger',
        info:    'info',
        notice:  'info',
        success: 'success',
        warning: 'warning',
      }.each do |key, bs_class|
        next unless model.key?(key)
        result << content_tag(
          :div,
          model[key],
          class: "alert alert-#{bs_class}",
        )
      end
      raw result
    end
  end
end
