module FormHelper

  def options_for_enum_select(enum)
    options_for_select(enum.each_with_object({}) do |(key, _), hash|
      hash[key.humanize] = key
    end)
  end

end
