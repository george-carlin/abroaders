module FormHelper
  def options_for_enum_select(enum, selected = nil)
    options = enum.each_with_object({}) do |(key, _), hash|
      hash[key.humanize] = key
    end
    options_for_select(options, selected)
  end
end
