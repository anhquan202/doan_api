# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_11_17_144911) do
  create_table "admins", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.string "address"
    t.integer "gender"
    t.date "date_of_birth"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "jti", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["jti"], name: "index_admins_on_jti", unique: true
    t.index ["unlock_token"], name: "index_admins_on_unlock_token", unique: true
  end

  create_table "contract_customers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "contract_id", null: false
    t.bigint "customer_id", null: false
    t.boolean "is_represent"
    t.datetime "move_in_date"
    t.datetime "move_out_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contract_id"], name: "index_contract_customers_on_contract_id"
    t.index ["customer_id"], name: "index_contract_customers_on_customer_id"
  end

  create_table "contract_utilities", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "contract_id"
    t.bigint "utility_id"
    t.integer "quantity", default: 1
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contract_id"], name: "index_contract_utilities_on_contract_id"
    t.index ["utility_id"], name: "index_contract_utilities_on_utility_id"
  end

  create_table "contracts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "room_id"
    t.string "contract_code"
    t.datetime "start_date"
    t.datetime "end_date"
    t.decimal "deposit", precision: 10
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "term_months"
    t.index ["room_id"], name: "index_contracts_on_room_id"
  end

  create_table "customers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "identity_code"
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "phone"
    t.string "address"
    t.integer "gender"
    t.date "date_of_birth"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "room_supplies", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "room_id"
    t.bigint "supply_id"
    t.integer "quantity"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["room_id"], name: "index_room_supplies_on_room_id"
    t.index ["supply_id"], name: "index_room_supplies_on_supply_id"
  end

  create_table "room_utilities", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "room_id"
    t.bigint "utility_id"
    t.boolean "is_required"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["room_id"], name: "index_room_utilities_on_room_id"
    t.index ["utility_id"], name: "index_room_utilities_on_utility_id"
  end

  create_table "rooms", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "room_type"
    t.string "room_name"
    t.decimal "price", precision: 10
    t.integer "status"
    t.integer "max_customers"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "supplies", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.integer "unit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "utilities", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "utility_type"
    t.decimal "fee", precision: 10
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "vehicles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "customer_id"
    t.string "license_plate"
    t.integer "vehicle_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_vehicles_on_customer_id"
  end

  add_foreign_key "contract_customers", "contracts"
  add_foreign_key "contract_customers", "customers"
  add_foreign_key "contracts", "rooms"
  add_foreign_key "room_supplies", "rooms", on_delete: :cascade
  add_foreign_key "room_supplies", "supplies"
  add_foreign_key "room_utilities", "rooms", on_delete: :cascade
  add_foreign_key "room_utilities", "utilities"
  add_foreign_key "vehicles", "customers"
end
