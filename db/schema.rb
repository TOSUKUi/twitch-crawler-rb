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

ActiveRecord::Schema[7.1].define(version: 2024_03_09_095354) do
  create_table "chats", id: { type: :string, limit: 64 }, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "stream_id", null: false
    t.string "channel", null: false
    t.string "error"
    t.integer "bits"
    t.datetime "ts", null: false
    t.text "text", null: false
    t.string "emote_only"
    t.string "emotes"
    t.integer "posinega", limit: 1
    t.string "user_id", limit: 36, null: false
    t.string "user_name", null: false
    t.string "user_display_name", null: false
    t.boolean "user_is_broadcaster", null: false
    t.boolean "user_is_moderator", null: false
    t.boolean "user_is_subscriber", null: false
    t.string "user_badge_info"
    t.string "user_badges"
    t.string "user_client_nonce"
    t.string "user_color"
    t.boolean "user_first_msg"
    t.string "user_flags"
    t.boolean "user_mod"
    t.boolean "user_returning_chatter"
    t.string "user_room_id", limit: 36
    t.bigint "user_tmi_sent_ts"
    t.boolean "user_turbo"
    t.string "user_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stream_id"], name: "fk_rails_22f3ab2af0"
  end

  create_table "o_auth_tokens", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "access_token"
    t.string "oauth_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "streams", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.integer "game_id", null: false
    t.string "game_name", null: false
    t.boolean "is_mature", null: false
    t.integer "status", default: 1, null: false
    t.string "language", null: false
    t.datetime "started_at", null: false
    t.datetime "ended_at"
    t.text "thumbnail_url", null: false
    t.text "title", null: false
    t.string "data_type", null: false
    t.bigint "user_id", null: false
    t.string "user_login", null: false
    t.string "user_name", null: false
    t.integer "max_viewer", null: false
    t.integer "viewer_count", null: false
    t.string "tag_ids", limit: 1024
    t.string "tags", limit: 1024
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "chats", "streams"
end
