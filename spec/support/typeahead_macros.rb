module TypeaheadMacros
  # 'with' = the string that gets typed into the text field
  # 'and_choose' - the suggested result that's chosen (doesn't have to match
  #               the full string, it can match a substring)
  def fill_in_typeahead(selector, with:, and_choose:)
    # See http://stackoverflow.com/a/31480061/1603071
    execute_script(
      "$('#{selector}').val('#{with}').trigger('input').typeahead('open')",
    )

    find('.tt-suggestion', text: and_choose).click
  end
end
