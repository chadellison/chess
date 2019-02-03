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

ActiveRecord::Schema.define(version: 2019_02_03_050112) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ai_players", force: :cascade do |t|
    t.string "color"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "black_attack_signatures", force: :cascade do |t|
    t.string "signature"
    t.integer "rank", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["signature"], name: "index_black_attack_signatures_on_signature"
  end

  create_table "black_threat_signatures", force: :cascade do |t|
    t.string "signature"
    t.integer "rank", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["signature"], name: "index_black_threat_signatures_on_signature"
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
    t.integer "outcome"
    t.string "status"
    t.integer "white_player"
    t.integer "black_player"
    t.string "game_type", default: "machine vs machine"
    t.integer "ai_player_id"
    t.index ["notation"], name: "index_games_on_notation"
  end

  create_table "general_attack_signatures", force: :cascade do |t|
    t.string "signature"
    t.integer "rank", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["signature"], name: "index_general_attack_signatures_on_signature"
  end

  create_table "group_chats", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "material_signatures", force: :cascade do |t|
    t.string "signature"
    t.integer "rank", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["signature"], name: "index_material_signatures_on_signature"
  end

  create_table "moves", force: :cascade do |t|
    t.integer "game_id"
    t.integer "setup_id"
    t.string "value"
    t.integer "move_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "promoted_pawn"
    t.index ["game_id"], name: "index_moves_on_game_id"
    t.index ["setup_id"], name: "index_moves_on_setup_id"
    t.index ["value"], name: "index_moves_on_value"
  end

  create_table "setups", force: :cascade do |t|
    t.text "position_signature"
    t.integer "rank", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "attack_signature_id"
    t.integer "material_signature_id"
    t.integer "threat_signature_id"
    t.integer "general_attack_signature_id"
    t.integer "white_threat_signature_id"
    t.integer "black_threat_signature_id"
    t.integer "white_attack_signature_id"
    t.integer "black_attack_signature_id"
    t.index ["black_attack_signature_id"], name: "index_setups_on_black_attack_signature_id"
    t.index ["black_threat_signature_id"], name: "index_setups_on_black_threat_signature_id"
    t.index ["general_attack_signature_id"], name: "index_setups_on_general_attack_signature_id"
    t.index ["material_signature_id"], name: "index_setups_on_material_signature_id"
    t.index ["position_signature"], name: "index_setups_on_position_signature"
    t.index ["white_attack_signature_id"], name: "index_setups_on_white_attack_signature_id"
    t.index ["white_threat_signature_id"], name: "index_setups_on_white_threat_signature_id"
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

  create_table "white_attack_signatures", force: :cascade do |t|
    t.string "signature"
    t.integer "rank", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["signature"], name: "index_white_attack_signatures_on_signature"
  end

  create_table "white_threat_signatures", force: :cascade do |t|
    t.string "signature"
    t.integer "rank", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["signature"], name: "index_white_threat_signatures_on_signature"
  end

end
