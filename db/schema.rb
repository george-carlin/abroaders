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

ActiveRecord::Schema.define(version: 20160205001951) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "airports", force: :cascade do |t|
    t.string   "name",                 null: false
    t.string   "iata_code",  limit: 3, null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["iata_code"], name: "index_airports_on_iata_code", using: :btree
    t.index ["name"], name: "index_airports_on_name", using: :btree
  end

  create_table "card_accounts", force: :cascade do |t|
    t.integer  "card_id",                        null: false
    t.integer  "user_id",                        null: false
    t.integer  "status",                         null: false
    t.datetime "recommended_at"
    t.datetime "applied_at"
    t.datetime "opened_at"
    t.datetime "earned_at"
    t.datetime "closed_at"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.boolean  "reconsidered",   default: false, null: false
    t.integer  "offer_id"
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
    t.index ["identifier"], name: "index_card_offers_on_identifier", using: :btree
    t.index ["status"], name: "index_card_offers_on_status", using: :btree
  end

  create_table "cards", force: :cascade do |t|
    t.string   "identifier",                      null: false
    t.string   "name",                            null: false
    t.integer  "brand",                           null: false
    t.integer  "bp",                              null: false
    t.string   "type",                            null: false
    t.integer  "annual_fee_cents",                null: false
    t.boolean  "active",           default: true, null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "bank",                            null: false
    t.string   "currency_id",                     null: false
    t.index ["bank"], name: "index_cards_on_bank", using: :btree
    t.index ["identifier"], name: "index_cards_on_identifier", unique: true, using: :btree
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

  create_table "travel_plan_legs", force: :cascade do |t|
    t.integer  "travel_plan_id",                           null: false
    t.integer  "position",           limit: 2, default: 0, null: false
    t.integer  "origin_id",                                null: false
    t.integer  "destination_id",                           null: false
    t.date     "earliest_departure",                       null: false
    t.date     "latest_departure",                         null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.index ["destination_id"], name: "index_travel_plan_legs_on_destination_id", using: :btree
    t.index ["origin_id"], name: "index_travel_plan_legs_on_origin_id", using: :btree
    t.index ["travel_plan_id", "position"], name: "index_travel_plan_legs_on_travel_plan_id_and_position", unique: true, using: :btree
    t.index ["travel_plan_id"], name: "index_travel_plan_legs_on_travel_plan_id", using: :btree
  end

  create_table "travel_plans", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_travel_plans_on_user_id", using: :btree
  end

  create_table "user_infos", force: :cascade do |t|
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
    t.integer  "has_business",        default: 0,     null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "business_spending",   default: 0,     null: false
    t.index ["user_id"], name: "index_user_infos_on_user_id", using: :btree
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

  add_foreign_key "card_accounts", "card_offers", column: "offer_id", on_delete: :restrict
  add_foreign_key "card_accounts", "cards", on_delete: :restrict
  add_foreign_key "card_accounts", "users", on_delete: :cascade
  add_foreign_key "card_offers", "cards", on_delete: :cascade
  add_foreign_key "destinations", "destinations", column: "parent_id", on_delete: :restrict
  add_foreign_key "travel_plan_legs", "airports", column: "destination_id"
  add_foreign_key "travel_plan_legs", "airports", column: "origin_id"
  add_foreign_key "travel_plan_legs", "travel_plans", on_delete: :cascade
  add_foreign_key "travel_plans", "users", on_delete: :cascade
  add_foreign_key "user_infos", "users", on_delete: :cascade
end
