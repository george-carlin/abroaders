module AlertsHelper
  def flash_alerts
    # If you want to display a Bootstrap alert using the flash, use one of these keys:
    #
    # danger (red) o
    # success (green)
    # warning (orange)
    # info (blue)
    #
    # This corresponds to the CSS class names used by Bootstrap itself. Or use
    # 'error' as well; it'll look the same as 'danger', but 'error' feels like
    # a word we should include.
    #
    # This method will output alerts for the keys 'alert' and 'notice' too,
    # because these are the keys Devise uses, but don't use them yourself.
    result = ""
    {
      alert:   "danger",
      danger:  "danger",
      error:   "danger",
      info:    "info",
      notice:  "info",
      success: "success",
      warning: "warning",
    }.each do |key, bs_class|
      next unless flash.key?(key)
      result << content_tag(
        :div,
        flash[key],
        class: "alert alert-#{bs_class}",
      )
    end
    raw result
  end
end
