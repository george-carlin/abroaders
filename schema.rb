  create_table "accounts", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.boolean  "admin",                  default: false, null: false
    t.integer  "plan"
    t.integer  "passenger_id"
    t.integer  "companion_id",           default: false, null: false
    t.boolean  "shares_spending",        default: false, null: false
  end

  # if shares_spending is true, use the personal spending of the person,
  # and companion spending can be left blank

  create_table "passengers", force: :cascade do |t|
    t.string   "email",               default: "",    null: false
    t.integer  "account_id"
    t.string   "first_name",                          null: false
    t.string   "middle_names"
    t.string   "last_name",                           null: false
    t.string   "phone_number",                        null: false
    t.boolean  "text_message",        default: false, null: false
    t.boolean  "whatsapp",            default: false, null: false
    t.boolean  "imessage",            default: false, null: false
    t.string   "time_zone",                           null: false
    t.integer  "citizenship",         default: 0,     null: false

    t.boolean  "willing_to_apply_for_cards"

    t.boolean  "will_apply_for_loan", default: false, null: false
    t.integer  "personal_spending",   default: 0,     null: false
    t.integer  "business_spending",   default: 0
    t.integer  "has_business",        default: 0,     null: false
    t.boolean  "has_added_cards",     default: false, null: false
    t.boolean  "has_added_balances",  default: false, null: false
  end

  create_table "travel_plans" do
    t.integer "account_id"
  end
