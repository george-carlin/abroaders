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

ActiveRecord::Schema.define(version: 20160209220912) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "balances", force: :cascade do |t|
    t.integer  "user_id",                 null: false
    t.integer  "currency_id",             null: false
    t.integer  "value",       default: 0, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["currency_id"], name: "index_balances_on_currency_id", using: :btree
    t.index ["user_id", "currency_id"], name: "index_balances_on_user_id_and_currency_id", unique: true, using: :btree
    t.index ["user_id"], name: "index_balances_on_user_id", using: :btree
  end

  create_table "card_accounts", force: :cascade do |t|
    t.integer  "card_id"
    t.integer  "user_id",                        null: false
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
    t.string   "identifier",                  null: false
    t.integer  "points_awarded",              null: false
    t.integer  "spend",                       null: false
    t.integer  "cost",           default: 0,  null: false
    t.integer  "days",           default: 90, null: false
    t.integer  "status",         default: 0,  null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.index ["card_id"], name: "index_card_offers_on_card_id", using: :btree
    t.index ["identifier"], name: "index_card_offers_on_identifier", unique: true, using: :btree
    t.index ["status"], name: "index_card_offers_on_status", using: :btree
  end

  create_table "cards", force: :cascade do |t|
    t.string   "identifier",                      null: false
    t.string   "name",                            null: false
    t.integer  "brand",                           null: false
    t.integer  "bp",                              null: false
    t.integer  "bank",                            null: false
    t.integer  "type",                            null: false
    t.integer  "annual_fee_cents",                null: false
    t.boolean  "active",           default: true, null: false
    t.integer  "currency_id",                     null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.index ["bank"], name: "index_cards_on_bank", using: :btree
    t.index ["currency_id"], name: "index_cards_on_currency_id", using: :btree
    t.index ["identifier"], name: "index_cards_on_identifier", unique: true, using: :btree
  end

  create_table "currencies", force: :cascade do |t|
    t.string   "name",            null: false
    t.string   "award_wallet_id", null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["award_wallet_id"], name: "index_currencies_on_award_wallet_id", unique: true, using: :btree
    t.index ["name"], name: "index_currencies_on_name", unique: true, using: :btree
  end

  create_table "destinations", force: :cascade do |t|
    t.string   "name",                       null: false
    t.string   "code",                       null: false
    t.integer  "type",                       null: false
    t.integer  "parent_id"
    t.integer  "children_count", default: 0, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["code", "type"], name: "index_destinations_on_code_and_type", unique: true, using: :btree
    t.index ["name"], name: "index_destinations_on_name", using: :btree
    t.index ["parent_id"], name: "index_destinations_on_parent_id", using: :btree
    t.index ["type"], name: "index_destinations_on_type", using: :btree
  end

  create_table "surveys", force: :cascade do |t|
    t.integer  "user_id",                             null: false
    t.string   "first_name",                          null: false
    t.string   "middle_names"
    t.string   "last_name",                           null: false
    t.string   "phone_number",                        null: false
    t.boolean  "text_message",        default: false, null: false
    t.boolean  "whatsapp",            default: false, null: false
    t.boolean  "imessage",            default: false, null: false
    t.string   "time_zone",                           null: false
    t.integer  "citizenship",         default: 0,     null: false
    t.integer  "credit_score",                        null: false
    t.boolean  "will_apply_for_loan", default: false, null: false
    t.integer  "personal_spending",   default: 0,     null: false
    t.integer  "business_spending",   default: 0
    t.integer  "has_business",        default: 0,     null: false
    t.boolean  "has_added_cards",     default: false, null: false
    t.boolean  "has_added_balances",  default: false, null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["user_id"], name: "index_surveys_on_user_id", unique: true, using: :btree
  end

  create_table "travel_legs", force: :cascade do |t|
    t.integer  "travel_plan_id",                       null: false
    t.integer  "position",       limit: 2, default: 0, null: false
    t.integer  "from_id",                              null: false
    t.integer  "to_id",                                null: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.index ["from_id"], name: "index_travel_legs_on_from_id", using: :btree
    t.index ["to_id"], name: "index_travel_legs_on_to_id", using: :btree
    t.index ["travel_plan_id", "position"], name: "index_travel_legs_on_travel_plan_id_and_position", unique: true, using: :btree
    t.index ["travel_plan_id"], name: "index_travel_legs_on_travel_plan_id", using: :btree
  end

  create_table "travel_plans", force: :cascade do |t|
    t.integer   "user_id"
    t.integer   "type",                 null: false
    t.daterange "departure_date_range", null: false
    t.datetime  "created_at",           null: false
    t.datetime  "updated_at",           null: false
    t.index ["type"], name: "index_travel_plans_on_type", using: :btree
    t.index ["user_id"], name: "index_travel_plans_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.boolean  "admin",                  default: false, null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.index ["admin"], name: "index_users_on_admin", using: :btree
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "balances", "currencies", on_delete: :cascade
  add_foreign_key "balances", "users", on_delete: :cascade
  add_foreign_key "card_accounts", "card_offers", column: "offer_id", on_delete: :cascade
  add_foreign_key "card_accounts", "cards", on_delete: :restrict
  add_foreign_key "card_accounts", "users", on_delete: :cascade
  add_foreign_key "card_offers", "cards", on_delete: :cascade
  add_foreign_key "cards", "currencies", on_delete: :restrict
  add_foreign_key "destinations", "destinations", column: "parent_id", on_delete: :restrict
  add_foreign_key "surveys", "users", on_delete: :cascade
  add_foreign_key "travel_legs", "destinations", column: "from_id", on_delete: :restrict
  add_foreign_key "travel_legs", "destinations", column: "to_id", on_delete: :restrict
  add_foreign_key "travel_legs", "travel_plans", on_delete: :cascade
  add_foreign_key "travel_plans", "users", on_delete: :cascade
end
