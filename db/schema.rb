# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150324143230) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "games", force: :cascade do |t|
    t.integer  "round_id"
    t.integer  "participant1_id"
    t.integer  "participant2_id"
    t.integer  "score1"
    t.integer  "score2"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.float    "elo_rating1_in"
    t.float    "elo_rating1_out"
    t.float    "elo_rating2_in"
    t.float    "elo_rating2_out"
    t.datetime "finished_at"
  end

  add_index "games", ["participant1_id"], name: "index_games_on_participant1_id", using: :btree
  add_index "games", ["participant2_id"], name: "index_games_on_participant2_id", using: :btree
  add_index "games", ["round_id"], name: "index_games_on_round_id", using: :btree

  create_table "matches", force: :cascade do |t|
    t.integer  "participant_id"
    t.integer  "game_id"
    t.integer  "score"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "matches", ["game_id"], name: "index_matches_on_game_id", using: :btree
  add_index "matches", ["participant_id"], name: "index_matches_on_participant_id", using: :btree

  create_table "participants", force: :cascade do |t|
    t.integer  "player_id"
    t.integer  "round_id"
    t.integer  "tier_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "participants", ["player_id"], name: "index_participants_on_player_id", using: :btree
  add_index "participants", ["round_id"], name: "index_participants_on_round_id", using: :btree
  add_index "participants", ["tier_id"], name: "index_participants_on_tier_id", using: :btree

  create_table "players", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "avatar"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "uid"
    t.integer  "last_round_id"
    t.string   "image"
    t.string   "nickname"
    t.boolean  "admin",         default: false,  null: false
    t.float    "elo_rating",    default: 1000.0, null: false
    t.boolean  "active",        default: true,   null: false
  end

  create_table "players_tiers", id: false, force: :cascade do |t|
    t.integer "player_id"
    t.integer "tier_id"
  end

  add_index "players_tiers", ["player_id"], name: "index_players_tiers_on_player_id", using: :btree
  add_index "players_tiers", ["tier_id"], name: "index_players_tiers_on_tier_id", using: :btree

  create_table "rounds", force: :cascade do |t|
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "round_number"
    t.boolean  "public",       default: true, null: false
  end

  create_table "tiers", force: :cascade do |t|
    t.integer  "round_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "name"
    t.integer  "level"
  end

  add_index "tiers", ["round_id"], name: "index_tiers_on_round_id", using: :btree

  add_foreign_key "matches", "games"
  add_foreign_key "matches", "participants"
  add_foreign_key "tiers", "rounds"
end
