# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170420222800) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string   "email",                   default: "",              null: false
    t.string   "encrypted_password",      default: "",              null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",           default: 0,               null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.integer  "monthly_spending_usd"
    t.string   "phone_number"
    t.string   "phone_number_normalized"
    t.string   "onboarding_state",        default: "home_airports", null: false
    t.string   "promo_code"
    t.boolean  "test",                    default: false,           null: false
    t.index ["email"], name: "index_accounts_on_email", unique: true, using: :btree
    t.index ["onboarding_state"], name: "index_accounts_on_onboarding_state", using: :btree
    t.index ["phone_number_normalized"], name: "index_accounts_on_phone_number_normalized", using: :btree
    t.index ["reset_password_token"], name: "index_accounts_on_reset_password_token", unique: true, using: :btree
  end

  create_table "accounts_home_airports", force: :cascade do |t|
    t.integer  "account_id", null: false
    t.integer  "airport_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "airport_id"], name: "index_accounts_home_airports_on_account_id_and_airport_id", unique: true, using: :btree
    t.index ["account_id"], name: "index_accounts_home_airports_on_account_id", using: :btree
    t.index ["airport_id"], name: "index_accounts_home_airports_on_airport_id", using: :btree
  end

  create_table "admins", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["email"], name: "index_admins_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree
  end

  create_table "award_wallet_accounts", force: :cascade do |t|
    t.integer  "award_wallet_owner_id", null: false
    t.integer  "aw_id",                 null: false
    t.string   "display_name",          null: false
    t.string   "kind",                  null: false
    t.string   "login",                 null: false
    t.integer  "balance_raw",           null: false
    t.integer  "error_code",            null: false
    t.string   "error_message"
    t.string   "last_detected_change"
    t.datetime "expiration_date"
    t.datetime "last_retrieve_date"
    t.datetime "last_change_date"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.index ["aw_id"], name: "index_award_wallet_accounts_on_aw_id", using: :btree
    t.index ["award_wallet_owner_id"], name: "index_award_wallet_accounts_on_award_wallet_owner_id", using: :btree
  end

  create_table "award_wallet_owners", force: :cascade do |t|
    t.integer  "award_wallet_user_id", null: false
    t.string   "name",                 null: false
    t.integer  "person_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["award_wallet_user_id", "name"], name: "index_award_wallet_owners_on_award_wallet_user_id_and_name", unique: true, using: :btree
    t.index ["award_wallet_user_id"], name: "index_award_wallet_owners_on_award_wallet_user_id", using: :btree
    t.index ["name"], name: "index_award_wallet_owners_on_name", using: :btree
    t.index ["person_id"], name: "index_award_wallet_owners_on_person_id", using: :btree
  end

  create_table "award_wallet_users", force: :cascade do |t|
    t.integer  "account_id",                            null: false
    t.integer  "aw_id",                                 null: false
    t.boolean  "loaded",                default: false, null: false
    t.integer  "agent_id"
    t.string   "full_name"
    t.string   "user_name"
    t.string   "status"
    t.string   "email"
    t.string   "forwarding_email"
    t.string   "access_level"
    t.string   "accounts_access_level"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.index ["account_id"], name: "index_award_wallet_users_on_account_id", using: :btree
    t.index ["aw_id"], name: "index_award_wallet_users_on_aw_id", using: :btree
  end

  create_table "balances", force: :cascade do |t|
    t.integer  "person_id",   null: false
    t.integer  "currency_id", null: false
    t.integer  "value",       null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["currency_id"], name: "index_balances_on_currency_id", using: :btree
    t.index ["person_id", "currency_id"], name: "index_balances_on_person_id_and_currency_id", using: :btree
    t.index ["person_id"], name: "index_balances_on_person_id", using: :btree
  end

  create_table "banks", force: :cascade do |t|
    t.string   "name",           null: false
    t.integer  "personal_code",  null: false
    t.string   "personal_phone"
    t.string   "business_phone"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "card_products", force: :cascade do |t|
    t.string   "code",                              null: false
    t.string   "name",                              null: false
    t.integer  "network",                           null: false
    t.integer  "bp",                                null: false
    t.integer  "type",                              null: false
    t.integer  "annual_fee_cents",                  null: false
    t.boolean  "shown_on_survey",    default: true, null: false
    t.integer  "currency_id"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "bank_id",                           null: false
    t.string   "wallaby_id"
    t.string   "image_file_name",                   null: false
    t.string   "image_content_type",                null: false
    t.integer  "image_file_size",                   null: false
    t.datetime "image_updated_at",                  null: false
    t.index ["bank_id"], name: "index_card_products_on_bank_id", using: :btree
    t.index ["currency_id"], name: "index_card_products_on_currency_id", using: :btree
    t.index ["wallaby_id"], name: "index_card_products_on_wallaby_id", using: :btree
  end

  create_table "cards", force: :cascade do |t|
    t.integer  "card_product_id"
    t.integer  "person_id",         null: false
    t.integer  "offer_id"
    t.datetime "recommended_at"
    t.date     "applied_on"
    t.date     "opened_on"
    t.date     "closed_on"
    t.string   "decline_reason"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.datetime "clicked_at"
    t.datetime "declined_at"
    t.datetime "denied_at"
    t.datetime "nudged_at"
    t.datetime "called_at"
    t.datetime "redenied_at"
    t.datetime "seen_at"
    t.datetime "expired_at"
    t.integer  "recommended_by_id"
    t.index ["recommended_at"], name: "index_cards_on_recommended_at", using: :btree
    t.index ["seen_at"], name: "index_cards_on_seen_at", using: :btree
  end

  create_table "currencies", force: :cascade do |t|
    t.string   "name",                           null: false
    t.string   "award_wallet_id",                null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.boolean  "shown_on_survey", default: true, null: false
    t.string   "type",                           null: false
    t.string   "alliance_name",                  null: false
    t.index ["award_wallet_id"], name: "index_currencies_on_award_wallet_id", unique: true, using: :btree
    t.index ["name"], name: "index_currencies_on_name", unique: true, using: :btree
    t.index ["type"], name: "index_currencies_on_type", using: :btree
  end

  create_table "destinations", force: :cascade do |t|
    t.string   "name",                       null: false
    t.string   "code",                       null: false
    t.integer  "parent_id"
    t.integer  "children_count", default: 0, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "type",                       null: false
    t.index ["code", "type"], name: "index_destinations_on_code_and_type", unique: true, using: :btree
    t.index ["name"], name: "index_destinations_on_name", using: :btree
    t.index ["parent_id"], name: "index_destinations_on_parent_id", using: :btree
    t.index ["type"], name: "index_destinations_on_type", using: :btree
  end

  create_table "flights", force: :cascade do |t|
    t.integer  "travel_plan_id",                       null: false
    t.integer  "position",       limit: 2, default: 0, null: false
    t.integer  "from_id",                              null: false
    t.integer  "to_id",                                null: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.index ["from_id"], name: "index_flights_on_from_id", using: :btree
    t.index ["to_id"], name: "index_flights_on_to_id", using: :btree
    t.index ["travel_plan_id", "position"], name: "index_flights_on_travel_plan_id_and_position", unique: true, using: :btree
    t.index ["travel_plan_id"], name: "index_flights_on_travel_plan_id", using: :btree
  end

  create_table "interest_regions", force: :cascade do |t|
    t.integer  "account_id", null: false
    t.integer  "region_id",  null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "region_id"], name: "index_interest_regions_on_account_id_and_region_id", unique: true, using: :btree
    t.index ["account_id"], name: "index_interest_regions_on_account_id", using: :btree
    t.index ["region_id"], name: "index_interest_regions_on_region_id", using: :btree
  end

  create_table "offers", force: :cascade do |t|
    t.integer  "product_id",                        null: false
    t.integer  "points_awarded",                    null: false
    t.integer  "spend"
    t.integer  "cost",                              null: false
    t.integer  "days"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "link",                              null: false
    t.text     "notes"
    t.datetime "last_reviewed_at"
    t.datetime "killed_at"
    t.string   "partner",          default: "none", null: false
    t.string   "condition",                         null: false
    t.index ["killed_at"], name: "index_offers_on_killed_at", using: :btree
    t.index ["product_id"], name: "index_offers_on_product_id", using: :btree
  end

  create_table "people", force: :cascade do |t|
    t.integer  "account_id",                        null: false
    t.string   "first_name",                        null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.boolean  "owner",              default: true, null: false
    t.string   "award_wallet_email"
    t.boolean  "eligible"
    t.index ["account_id", "owner"], name: "index_people_on_account_id_and_owner", unique: true, using: :btree
  end

  create_table "recommendation_notes", force: :cascade do |t|
    t.text     "content",    null: false
    t.integer  "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_recommendation_notes_on_account_id", using: :btree
  end

  create_table "recommendation_requests", force: :cascade do |t|
    t.integer  "person_id",   null: false
    t.datetime "resolved_at"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["person_id"], name: "index_recommendation_requests_on_person_id", using: :btree
    t.index ["resolved_at"], name: "index_recommendation_requests_on_resolved_at", using: :btree
  end

  create_table "spending_infos", force: :cascade do |t|
    t.integer  "person_id",                             null: false
    t.integer  "credit_score",                          null: false
    t.boolean  "will_apply_for_loan",   default: false, null: false
    t.integer  "business_spending_usd"
    t.integer  "has_business",          default: 0,     null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.index ["person_id"], name: "index_spending_infos_on_person_id", unique: true, using: :btree
  end

  create_table "travel_plans", force: :cascade do |t|
    t.integer  "account_id",                              null: false
    t.integer  "type",                    default: 0,     null: false
    t.integer  "no_of_passengers",        default: 1,     null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.text     "further_information"
    t.date     "depart_on",                               null: false
    t.date     "return_on"
    t.boolean  "accepts_economy",         default: false, null: false
    t.boolean  "accepts_premium_economy", default: false, null: false
    t.boolean  "accepts_business_class",  default: false, null: false
    t.boolean  "accepts_first_class",     default: false, null: false
    t.index ["account_id"], name: "index_travel_plans_on_account_id", using: :btree
    t.index ["type"], name: "index_travel_plans_on_type", using: :btree
  end

  add_foreign_key "accounts_home_airports", "accounts", on_delete: :cascade
  add_foreign_key "accounts_home_airports", "destinations", column: "airport_id", on_delete: :restrict
  add_foreign_key "award_wallet_accounts", "award_wallet_owners", on_delete: :cascade
  add_foreign_key "award_wallet_owners", "award_wallet_users", on_delete: :cascade
  add_foreign_key "award_wallet_owners", "people", on_delete: :nullify
  add_foreign_key "award_wallet_users", "accounts", on_delete: :cascade
  add_foreign_key "balances", "currencies", on_delete: :cascade
  add_foreign_key "balances", "people", on_delete: :cascade
  add_foreign_key "card_products", "banks"
  add_foreign_key "card_products", "currencies", on_delete: :restrict
  add_foreign_key "cards", "admins", column: "recommended_by_id", on_delete: :nullify
  add_foreign_key "cards", "card_products", on_delete: :restrict
  add_foreign_key "cards", "offers", on_delete: :cascade
  add_foreign_key "cards", "people", on_delete: :cascade
  add_foreign_key "destinations", "destinations", column: "parent_id", on_delete: :restrict
  add_foreign_key "flights", "destinations", column: "from_id", on_delete: :restrict
  add_foreign_key "flights", "destinations", column: "to_id", on_delete: :restrict
  add_foreign_key "flights", "travel_plans", on_delete: :cascade
  add_foreign_key "interest_regions", "accounts", on_delete: :cascade
  add_foreign_key "interest_regions", "destinations", column: "region_id", on_delete: :restrict
  add_foreign_key "offers", "card_products", column: "product_id", on_delete: :cascade
  add_foreign_key "people", "accounts", on_delete: :cascade
  add_foreign_key "recommendation_notes", "accounts", on_delete: :cascade
  add_foreign_key "recommendation_requests", "people", on_delete: :cascade
  add_foreign_key "spending_infos", "people", on_delete: :cascade
  add_foreign_key "travel_plans", "accounts", on_delete: :cascade
end
