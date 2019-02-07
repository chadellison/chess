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

ActiveRecord::Schema.define(version: 2019_02_07_105816) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activity_signatures", force: :cascade do |t|
    t.string "signature"
    t.integer "rank", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["signature"], name: "index_activity_signatures_on_signature"
  end

  create_table "ai_players", force: :cascade do |t|
    t.string "color"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bba_signatures", force: :cascade do |t|
    t.string "signature"
    t.integer "rank", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["signature"], name: "index_bba_signatures_on_signature"
  end

  create_table "bka_signatures", force: :cascade do |t|
    t.string "signature"
    t.integer "rank", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["signature"], name: "index_bka_signatures_on_signature"
  end

  create_table "black_threat_signatures", force: :cascade do |t|
    t.string "signature"
    t.integer "rank", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["signature"], name: "index_black_threat_signatures_on_signature"
  end

  create_table "bna_signatures", force: :cascade do |t|
    t.string "signature"
    t.integer "rank", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["signature"], name: "index_bna_signatures_on_signature"
  end

  create_table "bpa_signatures", force: :cascade do |t|
    t.string "signature"
    t.integer "rank", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["signature"], name: "index_bpa_signatures_on_signature"
  end

  create_table "bqa_signatures", force: :cascade do |t|
    t.string "signature"
    t.integer "rank", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["signature"], name: "index_bqa_signatures_on_signature"
  end

  create_table "bra_signatures", force: :cascade do |t|
    t.string "signature"
    t.integer "rank", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["signature"], name: "index_bra_signatures_on_signature"
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
    t.boolean "analyzed", default: false
    t.index ["notation"], name: "index_games_on_notation"
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
    t.integer "rank", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "attack_signature_id"
    t.integer "material_signature_id"
    t.integer "threat_signature_id"
    t.integer "white_threat_signature_id"
    t.integer "black_threat_signature_id"
    t.integer "wpa_signature_id"
    t.integer "bpa_signature_id"
    t.integer "wna_signature_id"
    t.integer "bna_signature_id"
    t.integer "wba_signature_id"
    t.integer "bba_signature_id"
    t.integer "wra_signature_id"
    t.integer "bra_signature_id"
    t.integer "wqa_signature_id"
    t.integer "bqa_signature_id"
    t.integer "wka_signature_id"
    t.integer "bka_signature_id"
    t.integer "activity_signature_id"
    t.index ["activity_signature_id"], name: "index_setups_on_activity_signature_id"
    t.index ["bba_signature_id"], name: "index_setups_on_bba_signature_id"
    t.index ["bka_signature_id"], name: "index_setups_on_bka_signature_id"
    t.index ["black_threat_signature_id"], name: "index_setups_on_black_threat_signature_id"
    t.index ["bna_signature_id"], name: "index_setups_on_bna_signature_id"
    t.index ["bpa_signature_id"], name: "index_setups_on_bpa_signature_id"
    t.index ["bqa_signature_id"], name: "index_setups_on_bqa_signature_id"
    t.index ["bra_signature_id"], name: "index_setups_on_bra_signature_id"
    t.index ["material_signature_id"], name: "index_setups_on_material_signature_id"
    t.index ["position_signature"], name: "index_setups_on_position_signature"
    t.index ["wba_signature_id"], name: "index_setups_on_wba_signature_id"
    t.index ["white_threat_signature_id"], name: "index_setups_on_white_threat_signature_id"
    t.index ["wka_signature_id"], name: "index_setups_on_wka_signature_id"
    t.index ["wna_signature_id"], name: "index_setups_on_wna_signature_id"
    t.index ["wpa_signature_id"], name: "index_setups_on_wpa_signature_id"
    t.index ["wqa_signature_id"], name: "index_setups_on_wqa_signature_id"
    t.index ["wra_signature_id"], name: "index_setups_on_wra_signature_id"
  end

  create_table "signatures", force: :cascade do |t|
    t.string "value"
    t.integer "rank", default: 0
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

  create_table "wba_signatures", force: :cascade do |t|
    t.string "signature"
    t.integer "rank", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["signature"], name: "index_wba_signatures_on_signature"
  end

  create_table "white_threat_signatures", force: :cascade do |t|
    t.string "signature"
    t.integer "rank", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["signature"], name: "index_white_threat_signatures_on_signature"
  end

  create_table "wka_signatures", force: :cascade do |t|
    t.string "signature"
    t.integer "rank", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["signature"], name: "index_wka_signatures_on_signature"
  end

  create_table "wna_signatures", force: :cascade do |t|
    t.string "signature"
    t.integer "rank", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["signature"], name: "index_wna_signatures_on_signature"
  end

  create_table "wpa_signatures", force: :cascade do |t|
    t.string "signature"
    t.integer "rank", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["signature"], name: "index_wpa_signatures_on_signature"
  end

  create_table "wqa_signatures", force: :cascade do |t|
    t.string "signature"
    t.integer "rank", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["signature"], name: "index_wqa_signatures_on_signature"
  end

  create_table "wra_signatures", force: :cascade do |t|
    t.string "signature"
    t.integer "rank", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["signature"], name: "index_wra_signatures_on_signature"
  end

end
