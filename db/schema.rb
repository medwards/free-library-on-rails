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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 16) do

  create_table "item_taggings", :force => true do |t|
    t.integer "thing_id", :null => false
    t.integer "tag_id",   :null => false
  end

  create_table "items", :force => true do |t|
    t.string   "type",            :null => false
    t.string   "title",           :null => false
    t.text     "description"
    t.datetime "created",         :null => false
    t.integer  "owner_id",        :null => false
    t.string   "isbn"
    t.string   "author_first"
    t.string   "author_last"
    t.integer  "current_loan_id"
    t.string   "lcc_number"
    t.string   "cover_url"
  end

  create_table "loans", :force => true do |t|
    t.integer  "item_id",     :null => false
    t.integer  "borrower_id", :null => false
    t.string   "status",      :null => false
    t.datetime "return_date"
    t.string   "memo"
  end

  create_table "regions", :force => true do |t|
    t.string "name",      :null => false
    t.string "subdomain", :null => false
  end

  create_table "tags", :force => true do |t|
    t.string "name", :null => false
  end

  add_index "tags", ["name"], :name => "name", :unique => true

  create_table "user_comments", :force => true do |t|
    t.integer  "user_id",   :null => false
    t.integer  "author_id", :null => false
    t.datetime "created",   :null => false
    t.text     "text",      :null => false
  end

  create_table "user_taggings", :force => true do |t|
    t.integer "thing_id", :null => false
    t.integer "tag_id",   :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "address"
    t.string   "city"
    t.string   "postalcode",                                                                           :null => false
    t.decimal  "latitude",                                :precision => 6, :scale => 3,                :null => false
    t.decimal  "longitude",                               :precision => 6, :scale => 3,                :null => false
    t.string   "cellphone",                 :limit => 10
    t.string   "cellphone_provider"
    t.integer  "region_id",                                                             :default => 1
    t.text     "about"
  end

end
