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

ActiveRecord::Schema[8.0].define(version: 2025_06_05_184003) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "cart_items", force: :cascade do |t|
    t.bigint "cart_id", null: false
    t.integer "quantity", default: 1, null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "product_variant_id", null: false
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["product_variant_id"], name: "index_cart_items_on_product_variant_id"
  end

  create_table "carts", force: :cascade do |t|
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "product_id"
    t.string "product_name", null: false
    t.string "product_sku", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.integer "quantity", null: false
    t.decimal "line_total", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "user_id"
    t.string "email", null: false
    t.string "stripe_session_id", null: false
    t.string "order_number", null: false
    t.string "status", default: "pending", null: false
    t.decimal "subtotal_amount", precision: 10, scale: 2, null: false
    t.decimal "vat_amount", precision: 10, scale: 2, null: false
    t.decimal "shipping_amount", precision: 10, scale: 2, null: false
    t.decimal "total_amount", precision: 10, scale: 2, null: false
    t.string "shipping_name", null: false
    t.string "shipping_address_line1", null: false
    t.string "shipping_address_line2"
    t.string "shipping_city", null: false
    t.string "shipping_postal_code", null: false
    t.string "shipping_country", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_orders_on_email"
    t.index ["order_number"], name: "index_orders_on_order_number", unique: true
    t.index ["status"], name: "index_orders_on_status"
    t.index ["stripe_session_id"], name: "index_orders_on_stripe_session_id", unique: true
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "product_variants", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.string "name", null: false
    t.string "sku", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.integer "length_in_mm"
    t.integer "height_in_mm"
    t.integer "width_in_mm"
    t.integer "depth_in_mm"
    t.integer "weight_in_g"
    t.integer "volume_in_ml"
    t.integer "diameter_in_mm"
    t.integer "pac_size"
    t.boolean "active", default: true
    t.integer "sort_order", default: 0
    t.integer "stock_quantity", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id", "sku"], name: "index_product_variants_on_product_id_and_sku", unique: true
    t.index ["product_id", "sort_order"], name: "index_product_variants_on_product_id_and_sort_order"
    t.index ["product_id"], name: "index_product_variants_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "short_description"
    t.decimal "vat_rate", precision: 5, scale: 2, default: "20.0"
    t.boolean "active", default: true
    t.boolean "sample_eligible", default: false
    t.bigint "category_id"
    t.string "meta_title"
    t.string "meta_description"
    t.boolean "featured", default: false
    t.integer "sort_order"
    t.string "colour"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.string "pac_size"
    t.integer "diameter_in_mm"
    t.integer "volume_in_ml"
    t.integer "weight_in_g"
    t.integer "depth_in_mm"
    t.integer "height_in_mm"
    t.integer "width_in_mm"
    t.decimal "price"
    t.string "sku"
    t.string "material"
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["slug"], name: "index_products_on_slug", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "customer"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "product_variants"
  add_foreign_key "carts", "users"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "orders", "users"
  add_foreign_key "product_variants", "products"
  add_foreign_key "products", "categories"
  add_foreign_key "sessions", "users"
end
