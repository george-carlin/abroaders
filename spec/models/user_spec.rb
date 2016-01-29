require "rails_helper"

describe User do

  %i[
    business_spending
    citizenship
    credit_score
    first_name
    full_name
    has_business
    has_business?
    has_business_with_ein?
    has_business_without_ein?
    imessage
    imessage?
    last_name
    middle_names
    personal_spending
    phone_number
    text_message
    text_message?
    time_zone
    whatsapp
    whatsapp?
    will_apply_for_loan
  ].each do |method|
    it { is_expected.to delegate_method(method).to(:info) }
  end

end
