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

ActiveRecord::Schema.define(version: 20150530043325) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "business_units", force: :cascade do |t|
    t.string   "name",            limit: 100
    t.string   "industry",        limit: 100
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "company_id"
    t.integer  "organization_id"
  end

  add_index "business_units", ["company_id"], name: "index_business_units_on_company_id", using: :btree
  add_index "business_units", ["industry"], name: "index_business_units_on_industry", using: :btree
  add_index "business_units", ["name"], name: "index_business_units_on_name", using: :btree
  add_index "business_units", ["organization_id"], name: "index_business_units_on_organization_id", using: :btree

  create_table "companies", force: :cascade do |t|
    t.string   "name_legal",             limit: 100
    t.string   "name_informal",          limit: 50
    t.string   "password",               limit: 40
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "email",                              default: "", null: false
    t.string   "encrypted_password",                 default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
  end

  add_index "companies", ["email"], name: "index_companies_on_email", unique: true, using: :btree
  add_index "companies", ["name_informal"], name: "index_companies_on_name_informal", using: :btree
  add_index "companies", ["name_legal"], name: "index_companies_on_name_legal", using: :btree
  add_index "companies", ["reset_password_token"], name: "index_companies_on_reset_password_token", unique: true, using: :btree

  create_table "organizations", force: :cascade do |t|
    t.string   "name_legal",    limit: 100
    t.string   "name_informal", limit: 50
    t.string   "industry",      limit: 100
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "organizations", ["industry"], name: "index_organizations_on_industry", using: :btree
  add_index "organizations", ["name_informal"], name: "index_organizations_on_name_informal", using: :btree
  add_index "organizations", ["name_legal"], name: "index_organizations_on_name_legal", using: :btree

  create_table "questions", force: :cascade do |t|
    t.string   "question_type"
    t.string   "selector"
    t.string   "sub_selector"
    t.text     "question_text"
    t.string   "question_identifier"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "questions", ["question_identifier"], name: "index_questions_on_question_identifier", using: :btree

  create_table "responses", force: :cascade do |t|
    t.integer  "business_unit_id"
    t.string   "qualtrics_response_id"
    t.string   "qualtrics_response_set"
    t.string   "name"
    t.string   "email"
    t.string   "ip_address"
    t.integer  "status"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "finished"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "responses", ["business_unit_id"], name: "index_responses_on_business_unit_id", using: :btree
  add_index "responses", ["end_date"], name: "index_responses_on_end_date", using: :btree
  add_index "responses", ["finished"], name: "index_responses_on_finished", using: :btree
  add_index "responses", ["start_date"], name: "index_responses_on_start_date", using: :btree

  create_table "survey_questions", force: :cascade do |t|
    t.integer  "question_id"
    t.integer  "survey_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "survey_questions", ["question_id"], name: "index_survey_questions_on_question_id", using: :btree
  add_index "survey_questions", ["survey_id"], name: "index_survey_questions_on_survey_id", using: :btree

  create_table "surveys", force: :cascade do |t|
    t.integer  "business_unit_id"
    t.string   "survey_name"
    t.integer  "is_active"
    t.string   "owner_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "surveys", ["is_active"], name: "index_surveys_on_is_active", using: :btree
  add_index "surveys", ["owner_id"], name: "index_surveys_on_owner_id", using: :btree
  add_index "surveys", ["survey_name"], name: "index_surveys_on_survey_name", using: :btree

  create_table "surveys_business_units", id: false, force: :cascade do |t|
    t.integer "survey_id"
    t.integer "business_unit_id"
  end

  add_index "surveys_business_units", ["business_unit_id"], name: "index_surveys_business_units_on_business_unit_id", using: :btree
  add_index "surveys_business_units", ["survey_id"], name: "index_surveys_business_units_on_survey_id", using: :btree

end
