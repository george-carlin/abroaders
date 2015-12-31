module AlertsHelper

  def flash_alerts
    result = ""
    {
      alert:   "danger",
      danger:  "danger" ,
      error:   "danger" ,
      info:    "info",
      notice:  "info",
      success: "success",
      warning: "warning"
    }.each do |key, bs_class|
      if flash.key?(key)
        result << content_tag(
          :div,
          flash[key],
          class: "alert alert-#{bs_class}"
        )
      end
    end
    raw result
  end

end
