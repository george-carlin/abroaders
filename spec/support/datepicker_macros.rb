module DatepickerMacros
  # JS must be enabled for this to work - obviously.
  def set_datepicker_field(selector, to:)
    date_to_pick = to.to_date

    find(selector).click # show the datepicker calendar

    # If the date we want to find isn't in the current month, go back through
    # the datepicker months until we find it.
    target_month = date_to_pick.change(day: 1)

    # Both dates are a Date object where day of the month is the 1st:
    until current_month_in_datepicker == target_month
      # Go back or forward a month, as needed:
      if current_month_in_datepicker > target_month
        find(".datepicker .prev").click
      else
        find(".datepicker .next").click
      end
    end

    # Test that text *exactly* matches or e.g. the selector will return the
    # '11' button when searching for '1'.
    find(
      '.datepicker .day:not(.old):not(.new):not(.disabled)',
      text: /\A#{date_to_pick.day}\z/,
    ).click
  end

  private

  # this may break if you have more than one datepicker open in your tests, but
  # you probably won't want to do that anyway:
  def current_month_in_datepicker
    Date.parse(find(".datepicker-switch").text)
  end
end
