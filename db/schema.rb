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

ActiveRecord::Schema[8.0].define(version: 2025_10_21_230816) do
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
    t.index ["created_at"], name: "index_carts_on_created_at"
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.string "meta_title"
    t.text "meta_description"
    t.index ["slug"], name: "index_categories_on_slug", unique: true
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
    t.bigint "product_variant_id", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
    t.index ["product_variant_id"], name: "index_order_items_on_product_variant_id"
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

  create_table "organizations", force: :cascade do |t|
    t.string "name", null: false
    t.string "billing_email", null: false
    t.string "phone"
    t.jsonb "default_shipping_address", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["billing_email"], name: "index_organizations_on_billing_email"
  end

  create_table "product_option_assignments", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "product_option_id", null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id", "product_option_id"], name: "index_product_option_assignments_uniqueness", unique: true
    t.index ["product_id"], name: "index_product_option_assignments_on_product_id"
    t.index ["product_option_id"], name: "index_product_option_assignments_on_product_option_id"
  end

  create_table "product_option_values", force: :cascade do |t|
    t.bigint "product_option_id", null: false
    t.string "value", null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["position"], name: "index_product_option_values_on_position"
    t.index ["product_option_id", "value"], name: "index_product_option_values_on_product_option_id_and_value", unique: true
    t.index ["product_option_id"], name: "index_product_option_values_on_product_option_id"
  end

  create_table "product_options", force: :cascade do |t|
    t.string "name", null: false
    t.string "display_type", null: false
    t.boolean "required", default: true, null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["position"], name: "index_product_options_on_position"
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
    t.jsonb "option_values", default: {}
    t.index ["active"], name: "index_product_variants_on_active"
    t.index ["option_values"], name: "index_product_variants_on_option_values", using: :gin
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
    t.string "sku"
    t.string "material"
    t.string "base_sku"
    t.string "product_type", default: "standard", null: false
    t.bigint "parent_product_id"
    t.bigint "organization_id"
    t.jsonb "configuration_data", default: {}
    t.index ["active"], name: "index_products_on_active"
    t.index ["base_sku"], name: "index_products_on_base_sku", unique: true
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["featured"], name: "index_products_on_featured"
    t.index ["organization_id", "product_type"], name: "index_products_on_organization_id_and_product_type"
    t.index ["organization_id"], name: "index_products_on_organization_id"
    t.index ["parent_product_id"], name: "index_products_on_parent_product_id"
    t.index ["product_type"], name: "index_products_on_product_type"
    t.index ["slug"], name: "index_products_on_slug", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_sessions_on_created_at"
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role"
    t.string "first_name"
    t.string "last_name"
    t.boolean "email_address_verified", default: false
    t.bigint "organization_id"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["organization_id", "role"], name: "index_users_on_organization_id_and_role"
    t.index ["organization_id"], name: "index_users_on_organization_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "product_variants"
  add_foreign_key "carts", "users"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "product_variants"
  add_foreign_key "order_items", "products"
  add_foreign_key "orders", "users"
  add_foreign_key "product_option_assignments", "product_options"
  add_foreign_key "product_option_assignments", "products"
  add_foreign_key "product_option_values", "product_options"
  add_foreign_key "product_variants", "products"
  add_foreign_key "products", "categories"
  add_foreign_key "products", "organizations"
  add_foreign_key "products", "products", column: "parent_product_id"
  add_foreign_key "sessions", "users"
  add_foreign_key "users", "organizations"
end
