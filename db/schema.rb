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

ActiveRecord::Schema[8.0].define(version: 2025_02_06_023126) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "builds", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "report"
    t.string "branch_name", null: false
    t.string "commit_hash", null: false
    t.string "commit_message", null: false
    t.string "author_name", null: false
    t.string "build_machine_id"
    t.text "test_output"
    t.integer "seed", null: false
    t.string "cached_status"
    t.datetime "deleted_at"
    t.string "api_token"
    t.index ["project_id"], name: "index_builds_on_project_id"
  end

  create_table "charges", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "run_id", null: false
    t.decimal "rate", null: false
    t.decimal "run_duration", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["run_id"], name: "index_charges_on_run_id"
    t.index ["run_id"], name: "unique_index_on_charges_job_id", unique: true
  end

  create_table "github_accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "github_installation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "account_name"
    t.datetime "deleted_at"
    t.string "github_app_installation_url"
    t.jsonb "installation_response_payload"
    t.index ["user_id", "github_installation_id"], name: "index_saturn_installations_on_user_and_github_id", unique: true
    t.index ["user_id"], name: "index_github_accounts_on_user_id"
  end

  create_table "github_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.jsonb "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "project_secrets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "project_id", null: false
    t.string "key", null: false
    t.string "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id", "key"], name: "index_project_secrets_on_project_id_and_key", unique: true
    t.index ["project_id"], name: "index_project_secrets_on_project_id"
  end

  create_table "projects", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "github_repo_full_name"
    t.uuid "user_id", null: false
    t.uuid "github_account_id"
    t.boolean "active", default: true, null: false
    t.boolean "start_builds_automatically_on_git_push", default: false, null: false
    t.datetime "deleted_at"
    t.integer "concurrency", default: 2, null: false
    t.index ["github_account_id"], name: "index_projects_on_github_account_id"
    t.index ["user_id"], name: "index_projects_on_user_id"
  end

  create_table "run_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "run_id", null: false
    t.integer "type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["run_id", "type"], name: "index_run_events_on_run_id_and_type", unique: true
    t.index ["run_id"], name: "index_run_events_on_run_id"
  end

  create_table "runs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "build_id", null: false
    t.string "runner_id"
    t.text "test_output"
    t.text "test_report"
    t.text "system_logs"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "order_index", null: false
    t.string "runner_rsa_key_path"
    t.integer "exit_code"
    t.string "snapshot_image_id"
    t.datetime "deleted_at"
    t.boolean "terminate_on_completion", default: true, null: false
    t.jsonb "json_output"
    t.index ["build_id", "order_index"], name: "index_runs_on_build_id_and_order_index", unique: true
    t.index ["build_id"], name: "index_runs_on_build_id"
    t.index ["runner_id"], name: "index_runs_on_runner_id", unique: true
  end

  create_table "solid_cable_messages", force: :cascade do |t|
    t.binary "channel", null: false
    t.binary "payload", null: false
    t.datetime "created_at", null: false
    t.bigint "channel_hash", null: false
    t.index ["channel"], name: "index_solid_cable_messages_on_channel"
    t.index ["channel_hash"], name: "index_solid_cable_messages_on_channel_hash"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end

  create_table "test_case_runs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "identifier", null: false
    t.string "path", null: false
    t.integer "line_number", null: false
    t.integer "status", null: false
    t.float "duration", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "run_id", null: false
    t.index ["run_id"], name: "index_test_case_runs_on_run_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: ""
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "provider"
    t.string "uid"
    t.boolean "super_admin", default: false
    t.datetime "deleted_at"
    t.string "api_token"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "builds", "projects"
  add_foreign_key "charges", "runs"
  add_foreign_key "github_accounts", "users"
  add_foreign_key "project_secrets", "projects"
  add_foreign_key "projects", "github_accounts"
  add_foreign_key "projects", "users"
  add_foreign_key "run_events", "runs"
  add_foreign_key "runs", "builds"
  add_foreign_key "test_case_runs", "runs"
end
