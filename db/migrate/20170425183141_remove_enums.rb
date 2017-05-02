class RemoveEnums < ActiveRecord::Migration[5.0]
  def change_enum(model, col, mapping)
    table = model.table_name

    add_column table, :temp, :string

    mapping.each do |string, int|
      model.where(col => int).update_all(temp: string)
    end

    change_column_null table, :temp, false
    remove_column table, col, :integer, null: false
    rename_column table, :temp, col
  end

  def change
    change_enum(CardProduct, :bp, { business: 0, personal: 1 })
    change_enum(
      CardProduct,
      :network, 
      unknown: 0,
      visa: 1,
      mastercard: 2,
      amex: 3,
    )

    change_enum(
      CardProduct,
      :type,
      unknown: 0,
      credit: 1,
      charge: 2,
      debit: 3,
    )

    change_enum(
      SpendingInfo,
      :has_business,
      no_business: 0,
      with_ein: 1,
      without_ein: 2,
    )

    change_enum(
      TravelPlan,
      :type,
      one_way: 0,
      round_trip: 1,
      multi: 2
    )
  end
end
