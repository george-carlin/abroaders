class StaticPagesController < ApplicationController
  # TOC and Privacy policy generated at
  # http://www.bennadel.com/coldfusion/privacy-policy-generator.htm#primary-navigation
  #
  # We should get a pair of legal eyes on them at some point, just in case.

  def contact_us
    render cell(StaticPages::Cell::ContactUs, current_account)
  end
end
