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

ActiveRecord::Schema.define(version: 2018_06_10_221741) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "link_visits", force: :cascade do |t|
    t.bigint "link_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_link_visits_on_created_at"
    t.index ["link_id"], name: "index_link_visits_on_link_id"
  end

  create_table "links", force: :cascade do |t|
    t.string "slug"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_links_on_slug", unique: true
    t.index ["url"], name: "index_links_on_url", unique: true
  end

  add_foreign_key "link_visits", "links"
end
