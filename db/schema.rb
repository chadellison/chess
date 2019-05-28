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

ActiveRecord::Schema.define(version: 2019_05_28_001649) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ai_players", force: :cascade do |t|
    t.string "color"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "chat_messages", force: :cascade do |t|
    t.text "content"
    t.integer "game_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_chat_messages_on_game_id"
  end

  create_table "games", force: :cascade do |t|
    t.text "notation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "outcome"
    t.string "status"
    t.integer "white_player"
    t.integer "black_player"
    t.string "game_type", default: "machine vs machine"
    t.integer "ai_player_id"
    t.boolean "analyzed", default: false
    t.index ["notation"], name: "index_games_on_notation"
  end

  create_table "group_chats", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "moves", force: :cascade do |t|
    t.integer "game_id"
    t.integer "setup_id"
    t.string "value"
    t.integer "move_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "promoted_pawn"
    t.integer "material_value"
    t.index ["game_id"], name: "index_moves_on_game_id"
    t.index ["setup_id"], name: "index_moves_on_setup_id"
    t.index ["value"], name: "index_moves_on_value"
  end

  create_table "setup_signatures", force: :cascade do |t|
    t.integer "setup_id"
    t.integer "signature_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["setup_id"], name: "index_setup_signatures_on_setup_id"
    t.index ["signature_id"], name: "index_setup_signatures_on_signature_id"
  end

  create_table "setups", force: :cascade do |t|
    t.text "position_signature"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "outcomes"
    t.index ["position_signature"], name: "index_setups_on_position_signature", unique: true
  end

  create_table "signatures", force: :cascade do |t|
    t.integer "value"
    t.string "signature_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["value"], name: "index_signatures_on_value"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.string "first_name"
    t.string "last_name"
    t.string "token"
    t.string "hashed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_users_on_token"
  end

  create_table "weights", force: :cascade do |t|
    t.integer "weight_count"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
