require 'rails_helper'

RSpec.describe 'dataclips' do
  # We have some dataclips on Heroku (dataclips.heroku.com) that get fed into a
  # Google Sheet. They rely on raw SQL, meaning that changes to the DB schema
  # may break them. These tests are here so that if a migration breaks the
  # dataclips I notice immediately. SQL is copied directly from the dataclips
  # to these specs.
  #
  # If one of these specs starts failing, it almost definitely means that the
  # dataclip (and thus the SQL in the spec) needs fixing, not the Rails app
  # itself or the schema.

  # https://dataclips.heroku.com/xldeizvgjrbmjltjjazsneerqgws-Abroaders-Travel-Plans-v2
  example 'Travel Plans' do
    sql = %[
      SELECT
        "travel_plans"."id",
        "travel_plans"."account_id",
        "travel_plans"."depart_on",
        "travel_plans"."return_on",
        "travel_plans"."type",
        "travel_plans"."no_of_passengers",
        "travel_plans"."accepts_economy",
        "travel_plans"."accepts_premium_economy",
        "travel_plans"."accepts_business_class",
        "travel_plans"."accepts_first_class",
        "travel_plans"."further_information" AS "notes",
        "to"."code" AS "to_code",
        "from"."code" AS "from_code",
        "to_countries"."code" AS "to_country_code",
        "from_countries"."code" AS "from_country_code",
        "to_regions"."code" AS "to_region_code",
        "from_regions"."code" AS "from_region_code",
        "travel_plans"."created_at",
        "travel_plans"."updated_at"
      FROM "travel_plans"
      INNER JOIN "flights" ON "flights"."travel_plan_id" = "travel_plans"."id"
      INNER JOIN "destinations" "to"   ON "flights"."to_id" = "to"."id"
      INNER JOIN "destinations" "from" ON "flights"."from_id" = "from"."id"
      INNER JOIN "destinations" "to_cities"   ON "to"."parent_id" = "to_cities"."id"
      INNER JOIN "destinations" "from_cities" ON "from"."parent_id" = "from_cities"."id"
      INNER JOIN "destinations" "to_countries"   ON "to_cities"."parent_id" = "to_countries"."id"
      INNER JOIN "destinations" "from_countries" ON "from_cities"."parent_id" = "from_countries"."id"
      INNER JOIN "destinations" "to_regions"   ON "to_countries"."parent_id" = "to_regions"."id"
      INNER JOIN "destinations" "from_regions" ON "from_countries"."parent_id" = "from_regions"."id"
      ORDER BY "travel_plans"."id" ASC;
    ]
    expect { ApplicationRecord.connection.execute(sql) }.not_to raise_error
  end

  # https://dataclips.heroku.com/wluninrfepdqmturgomxmglgwkrp-Abroaders-Card-Accounts
  example 'Card Accounts' do
    sql = %[
      SELECT
        "cards"."id",
        "cards"."person_id",
        "card_products"."bank_id" AS "bank_id",
        "card_products"."id" AS "card_product_id",
        "card_products"."name" AS "product_name",
        "currencies"."id" AS "currency_id",
        "currencies"."name" AS "currency_name",
        "cards"."opened_on",
        "cards"."closed_on",
      CASE "card_products"."personal" WHEN true THEN 'personal'
      WHEN false THEN 'business'
      END AS "card_bp",
        "accounts"."id" AS "account_id",
        "cards"."recommended_at" IS NOT NULL AS "is_recommendation",
        "cards"."created_at",
        "cards"."updated_at",
        "accounts"."email" AS "account_email",
        "currencies"."name" AS "currency_name",
        "card_products"."annual_fee_cents" AS "product_annual_fee_cents",
        "card_products"."network" AS "product_network",
        "card_products"."type" AS "product_type",
        "people"."first_name" AS "person_first_name",
        "people"."owner" AS "person_is_owner"
      FROM "cards"
      INNER JOIN "card_products" ON "cards"."card_product_id" = "card_products"."id"
      INNER JOIN "currencies" ON "card_products"."currency_id" = "currencies"."id"
      INNER JOIN "people" ON "cards"."person_id" = "people"."id"
      INNER JOIN "accounts" ON "people"."account_id" = "accounts"."id"
      WHERE "accounts"."test" = false
      ORDER BY "cards"."id" ASC;
    ]
    expect { ApplicationRecord.connection.execute(sql) }.not_to raise_error
  end

  # https://dataclips.heroku.com/qdmfbornjzzqmkdljcryuahcoodi-Abroaders-Card-Recommendations
  example 'Card Recommendations' do
    sql = %[
      SELECT
        "cards"."id",
        "cards"."person_id",
        "cards"."recommended_at",
        "cards"."seen_at",
        "cards"."clicked_at",
        "cards"."declined_at",
        "cards"."applied_on",
        "cards"."denied_at",
        "cards"."opened_on",
        "cards"."called_at",
        "cards"."redenied_at",
        "cards"."nudged_at",
        "cards"."called_at",
        "cards"."offer_id",
        "offers"."cost" AS "offer_cost",
        "offers"."days" AS "offer_days",
        "offers"."points_awarded" AS "offer_points_awarded",
        "offers"."spend" AS "offer_spend",
        "cards"."card_product_id",
        "card_products"."name" AS "product_name",
        "card_products"."annual_fee_cents" / 100.0 AS "annual_fee",
        CASE "card_products"."personal" WHEN true THEN 'personal'
        WHEN false THEN 'business'
        END AS "bp",
        "card_products"."bank_id",
        "currencies"."id" AS "currency_id",
        "currencies"."name" AS "currency_name",
        "accounts"."id" AS "account_id",
        "accounts"."email" AS "account_email",
        "offers"."partner" AS "offer_partner",
        "offers"."condition" AS "offer_condition",
        "people"."first_name" AS "person_first_name",
        "people"."owner" AS "person_is_owner"
      FROM "cards"
      INNER JOIN "card_products" ON "cards"."card_product_id" = "card_products"."id"
      INNER JOIN "offers" ON "cards"."offer_id" = "offers"."id"
      INNER JOIN "currencies" ON "card_products"."currency_id" = "currencies"."id"
      INNER JOIN "people" ON "cards"."person_id" = "people"."id"
      INNER JOIN "accounts" ON "people"."account_id" = "accounts"."id"
      WHERE "accounts"."test" = false
      ORDER BY "cards"."id" ASC;
    ]
    expect { ApplicationRecord.connection.execute(sql) }.not_to raise_error
  end

  # https://dataclips.heroku.com/uvlqmtqukkcgikbmeauxxqvnvqjl-Abroaders-Accounts
  example 'Accounts' do
    sql = %[
      SELECT
        "accounts"."id",
        "accounts"."email",
        "accounts"."monthly_spending_usd",
        "accounts"."onboarding_state",
        "accounts"."phone_number_us_normalized" AS "phone_number",
        CASE WHEN "accounts"."onboarding_state" = 'complete' THEN true
        ELSE false
        END AS "onboarded",
        "accounts"."updated_at",
        "accounts"."created_at",
        "owners"."id" AS "owner_id",
        "owners"."first_name" AS "owner_first_name",
        "companions"."id" AS "companion_id",
        "companions"."first_name" AS "companion_first_name",
        "award_wallet_users"."email" AS "award_wallet_email",
        "award_wallet_users"."agent_id" AS "award_wallet_agent_id"
        FROM "accounts"
        LEFT OUTER JOIN "people" "owners" ON "owners"."account_id" = "accounts"."id"
        AND "owners"."owner" = TRUE
        LEFT OUTER JOIN "people" "companions" ON "companions"."account_id" = "accounts"."id"
        AND "companions"."owner" = FALSE
        LEFT OUTER JOIN "award_wallet_users" ON "award_wallet_users"."account_id" = "accounts"."id"
      WHERE "accounts"."test" = false
      ORDER BY "accounts"."id" ASC;
    ]
    expect { ApplicationRecord.connection.execute(sql) }.not_to raise_error
  end

  # https://dataclips.heroku.com/zmrdnvvcquilibojxemaoevydpij-Abroaders-Balances
  example 'Balances' do
    sql = %[
      SELECT
        "balances"."id",
        "balances"."person_id",
        "balances"."currency_id",
        "currencies"."name" AS "currency_name",
        "balances"."value",
        "balances"."created_at",
        "balances"."updated_at"
      FROM "balances"
      INNER JOIN "currencies" ON "balances"."currency_id" = "currencies"."id"
      ORDER BY "balances"."id" ASC
    ]
    expect { ApplicationRecord.connection.execute(sql) }.not_to raise_error
  end

  # https://dataclips.heroku.com/odqfopupncmuvpkardismgmbglbi-Abroaders-People
  example 'People' do
    sql = %[
      SELECT
        "people"."id",
        "people"."account_id",
        "people"."first_name",
        "people"."owner",
        "people"."eligible",
        "people"."created_at",
        "people"."updated_at"
      FROM "people"
      ORDER BY "people"."id" ASC
    ]
    expect { ApplicationRecord.connection.execute(sql) }.not_to raise_error
  end

  # https://dataclips.heroku.com/scqzekxrcyspvmfevxpqrfkalrsb-Abroaders-People-With-Spending
  example 'People With Spending' do
    sql = %[
      SELECT
        "people"."id",
        "people"."account_id",
        "people"."first_name",
        "people"."owner",
        "people"."eligible",
        "spending_infos"."credit_score",
        "spending_infos"."will_apply_for_loan",
        "spending_infos"."business_spending_usd",
        CASE "spending_infos"."has_business"
          WHEN 'no_business' THEN 'no'
          WHEN 'with_ein' THEN 'yes, with EIN'
          WHEN 'without_ein' THEN 'yes, without EIN'
          ELSE ''
          END AS "has_business",
        "people"."created_at",
        GREATEST("people"."updated_at", "spending_infos"."updated_at") AS "updated_at",
        "people"."account_id"
      FROM "people"
      JOIN "accounts" ON "people"."account_id" = "accounts"."id"
      LEFT OUTER JOIN "spending_infos" ON "spending_infos"."person_id" = "people"."id"
      WHERE "accounts"."test" = FALSE
      ORDER BY "people"."id" ASC
    ]
    expect { ApplicationRecord.connection.execute(sql) }.not_to raise_error
  end
end
