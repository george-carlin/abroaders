require 'representable/json'

class TravelPlan::Representer < Representable::Decorator
  include Representable::JSON

  property :id
  property :account_id
  property :type
  property :no_of_passengers
  property :created_at
  property :further_information
  property :acceptable_classes
  property :depart_on
  property :return_on

  # create_table "flights", force: :cascade do |t|
  #   t.integer  "travel_plan_id",                       null: false
  #   t.integer  "position",       limit: 2, default: 0, null: false
  #   t.integer  "from_id",                              null: false
  #   t.integer  "to_id",                                null: false
  #   t.datetime "created_at",                           null: false
  #   t.datetime "updated_at",                           null: false
  #   t.index ["from_id"], name: "index_flights_on_from_id", using: :btree
  #   t.index ["to_id"], name: "index_flights_on_to_id", using: :btree
  #   t.index ["travel_plan_id", "position"], name: "index_flights_on_travel_plan_id_and_position", unique: true, using: :btree
  #   t.index ["travel_plan_id"], name: "index_flights_on_travel_plan_id", using: :btree
  # end
end
