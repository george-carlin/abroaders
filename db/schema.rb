# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160418210346) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "monthly_spending_usd"
  end

  add_index "accounts", ["email"], name: "index_accounts_on_email", unique: true, using: :btree
  add_index "accounts", ["reset_password_token"], name: "index_accounts_on_reset_password_token", unique: true, using: :btree

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
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree

  create_table "balances", force: :cascade do |t|
    t.integer  "person_id",   null: false
    t.integer  "currency_id", null: false
    t.integer  "value",       null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "balances", ["currency_id"], name: "index_balances_on_currency_id", using: :btree
  add_index "balances", ["person_id", "currency_id"], name: "index_balances_on_person_id_and_currency_id", unique: true, using: :btree
  add_index "balances", ["person_id"], name: "index_balances_on_person_id", using: :btree

  create_table "card_accounts", force: :cascade do |t|
    t.integer  "card_id"
    t.integer  "person_id",                      null: false
    t.integer  "offer_id"
    t.integer  "status",                         null: false
    t.datetime "recommended_at"
    t.datetime "applied_at"
    t.datetime "opened_at"
    t.datetime "earned_at"
    t.datetime "closed_at"
    t.boolean  "reconsidered",   default: false, null: false
    t.string   "decline_reason"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "card_offers", force: :cascade do |t|
    t.integer  "card_id",                     null: false
    t.integer  "points_awarded",              null: false
    t.integer  "spend",                       null: false
    t.integer  "cost",           default: 0,  null: false
    t.integer  "days",           default: 90, null: false
    t.integer  "status",         default: 0,  null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "link",                        null: false
    t.text     "notes"
    t.integer  "condition",      default: 0,  null: false
  end

  add_index "card_offers", ["card_id"], name: "index_card_offers_on_card_id", using: :btree
  add_index "card_offers", ["status"], name: "index_card_offers_on_status", using: :btree

  create_table "cards", force: :cascade do |t|
    t.string   "code",                              null: false
    t.string   "name",                              null: false
    t.integer  "network",                           null: false
    t.integer  "bp",                                null: false
    t.integer  "type",                              null: false
    t.integer  "annual_fee_cents",                  null: false
    t.boolean  "shown_on_survey",    default: true, null: false
    t.integer  "currency_id",                       null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "bank_id",                           null: false
    t.string   "wallaby_id"
    t.string   "image_file_name",                   null: false
    t.string   "image_content_type",                null: false
    t.integer  "image_file_size",                   null: false
    t.datetime "image_updated_at",                  null: false
  end

  add_index "cards", ["bank_id"], name: "index_cards_on_bank_id", using: :btree
  add_index "cards", ["currency_id"], name: "index_cards_on_currency_id", using: :btree
  add_index "cards", ["wallaby_id"], name: "index_cards_on_wallaby_id", using: :btree

  create_table "currencies", force: :cascade do |t|
    t.string   "name",            null: false
    t.string   "award_wallet_id", null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "currencies", ["award_wallet_id"], name: "index_currencies_on_award_wallet_id", unique: true, using: :btree
  add_index "currencies", ["name"], name: "index_currencies_on_name", unique: true, using: :btree

  create_table "destinations", force: :cascade do |t|
    t.string   "name",                       null: false
    t.string   "code",                       null: false
    t.integer  "type",                       null: false
    t.integer  "parent_id"
    t.integer  "children_count", default: 0, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "destinations", ["code", "type"], name: "index_destinations_on_code_and_type", unique: true, using: :btree
  add_index "destinations", ["name"], name: "index_destinations_on_name", using: :btree
  add_index "destinations", ["parent_id"], name: "index_destinations_on_parent_id", using: :btree
  add_index "destinations", ["type"], name: "index_destinations_on_type", using: :btree

  create_table "eligibilities", force: :cascade do |t|
    t.integer  "person_id",  null: false
    t.boolean  "eligible",   null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "eligibilities", ["person_id"], name: "index_eligibilities_on_person_id", using: :btree

  create_table "flights", force: :cascade do |t|
    t.integer  "travel_plan_id",                       null: false
    t.integer  "position",       limit: 2, default: 0, null: false
    t.integer  "from_id",                              null: false
    t.integer  "to_id",                                null: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "flights", ["from_id"], name: "index_flights_on_from_id", using: :btree
  add_index "flights", ["to_id"], name: "index_flights_on_to_id", using: :btree
  add_index "flights", ["travel_plan_id", "position"], name: "index_flights_on_travel_plan_id_and_position", unique: true, using: :btree
  add_index "flights", ["travel_plan_id"], name: "index_flights_on_travel_plan_id", using: :btree

  create_table "people", force: :cascade do |t|
    t.integer  "account_id",                         null: false
    t.string   "first_name",                         null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.boolean  "main",               default: true,  null: false
    t.boolean  "onboarded_cards",    default: false, null: false
    t.boolean  "onboarded_balances", default: false, null: false
  end

  add_index "people", ["account_id", "main"], name: "index_people_on_account_id_and_main", unique: true, using: :btree

  create_table "readiness_statuses", force: :cascade do |t|
    t.integer  "person_id",          null: false
    t.boolean  "ready",              null: false
    t.string   "unreadiness_reason"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "readiness_statuses", ["person_id"], name: "index_readiness_statuses_on_person_id", unique: true, using: :btree

  create_table "spending_infos", force: :cascade do |t|
    t.integer  "person_id",                             null: false
    t.integer  "credit_score",                          null: false
    t.boolean  "will_apply_for_loan",   default: false, null: false
    t.integer  "business_spending_usd"
    t.integer  "has_business",          default: 0,     null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "spending_infos", ["person_id"], name: "index_spending_infos_on_person_id", unique: true, using: :btree

  create_table "travel_plans", force: :cascade do |t|
    t.integer   "account_id",                       null: false
    t.integer   "type",                 default: 0, null: false
    t.daterange "departure_date_range",             null: false
    t.integer   "no_of_passengers",     default: 1, null: false
    t.datetime  "created_at",                       null: false
    t.datetime  "updated_at",                       null: false
    t.text      "further_information"
    t.integer   "acceptable_classes",               null: false
  end

  add_index "travel_plans", ["account_id"], name: "index_travel_plans_on_account_id", using: :btree
  add_index "travel_plans", ["type"], name: "index_travel_plans_on_type", using: :btree

  add_foreign_key "balances", "currencies", on_delete: :cascade
  add_foreign_key "balances", "people", on_delete: :cascade
  add_foreign_key "card_accounts", "card_offers", column: "offer_id", on_delete: :cascade
  add_foreign_key "card_accounts", "cards", on_delete: :restrict
  add_foreign_key "card_accounts", "people", on_delete: :cascade
  add_foreign_key "card_offers", "cards", on_delete: :cascade
  add_foreign_key "cards", "currencies", on_delete: :restrict
  add_foreign_key "destinations", "destinations", column: "parent_id", on_delete: :restrict
  add_foreign_key "eligibilities", "people", on_delete: :cascade
  add_foreign_key "flights", "destinations", column: "from_id", on_delete: :restrict
  add_foreign_key "flights", "destinations", column: "to_id", on_delete: :restrict
  add_foreign_key "flights", "travel_plans", on_delete: :cascade
  add_foreign_key "people", "accounts", on_delete: :cascade
  add_foreign_key "readiness_statuses", "people", on_delete: :cascade
  add_foreign_key "travel_plans", "accounts", on_delete: :cascade
end
