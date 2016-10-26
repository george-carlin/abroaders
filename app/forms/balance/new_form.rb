class Balance::NewForm < Balance::Form
  property :currency_id

  validation do
    required(:currency_id).filled
  end
end
