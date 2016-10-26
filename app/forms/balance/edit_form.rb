class Balance::EditForm < Balance::Form
  # EditForm only has one property, 'value', which is already defined in
  # 'Form'. ('NewForm' adds the property 'currency_id' too). So EditForm
  # doesn't actually need to exist, we could just use 'Form', but create and
  # use an empty class anyway just to make the controller clearer.
end
