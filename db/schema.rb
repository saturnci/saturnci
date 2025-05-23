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

ActiveRecord::Schema[8.0].define(version: 2025_05_19_130909) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

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

  create_table "github_check_runs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "build_id", null: false
    t.string "github_check_run_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["build_id", "github_check_run_id"], name: "index_github_check_runs_on_build_id_and_github_check_run_id", unique: true
    t.index ["build_id"], name: "index_github_check_runs_on_build_id"
  end

  create_table "github_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.jsonb "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "project_id"
    t.string "type", null: false
    t.index ["project_id"], name: "index_github_events_on_project_id"
  end

  create_table "github_oauth_tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "value"], name: "index_github_oauth_tokens_on_user_id_and_value", unique: true
    t.index ["user_id"], name: "index_github_oauth_tokens_on_user_id"
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

  create_table "repositories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "github_repo_full_name"
    t.uuid "github_account_id"
    t.boolean "active", default: true, null: false
    t.boolean "start_builds_automatically_on_git_push", default: false, null: false
    t.datetime "deleted_at"
    t.integer "concurrency", default: 2, null: false
    t.index ["github_account_id"], name: "index_repositories_on_github_account_id"
  end

  create_table "rsa_keys", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "public_key_value", null: false
    t.text "private_key_value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "run_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "run_id", null: false
    t.integer "type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["run_id", "type"], name: "index_run_events_on_run_id_and_type", unique: true
    t.index ["run_id"], name: "index_run_events_on_run_id"
  end

  create_table "run_test_runners", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "run_id", null: false
    t.uuid "test_runner_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["run_id"], name: "index_run_test_runners_on_run_id"
    t.index ["run_id"], name: "run_test_runners_run_id", unique: true
    t.index ["test_runner_id"], name: "index_run_test_runners_on_test_runner_id"
    t.index ["test_runner_id"], name: "run_test_runners_test_runner_id", unique: true
  end

  create_table "runner_system_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "run_id", null: false
    t.text "content", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["run_id"], name: "index_runner_system_logs_on_run_id"
  end

  create_table "runs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "build_id", null: false
    t.string "runner_id"
    t.text "test_output"
    t.text "test_report"
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

  create_table "screenshots", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "run_id", null: false
    t.index ["run_id"], name: "index_screenshots_on_run_id"
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
    t.string "description", null: false
    t.text "exception"
    t.text "exception_message"
    t.text "exception_backtrace"
    t.index ["run_id"], name: "index_test_case_runs_on_run_id"
  end

  create_table "test_runner_assignments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "test_runner_id", null: false
    t.uuid "run_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["run_id"], name: "index_test_runner_assignments_on_run_id"
    t.index ["run_id"], name: "unique_runs", unique: true
    t.index ["test_runner_id"], name: "index_test_runner_assignments_on_test_runner_id"
    t.index ["test_runner_id"], name: "unique_test_runners", unique: true
  end

  create_table "test_runner_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "test_runner_id", null: false
    t.integer "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["test_runner_id", "type"], name: "index_test_runner_events_on_test_runner_id_and_type", unique: true
    t.index ["test_runner_id"], name: "index_test_runner_events_on_test_runner_id"
  end

  create_table "test_runner_snapshots", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "cloud_id", null: false
    t.string "os", null: false
    t.string "size", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "test_runners", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "cloud_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "rsa_key_id"
    t.boolean "terminate_on_completion", default: true, null: false
    t.index ["cloud_id"], name: "index_test_runners_on_cloud_id", unique: true
    t.index ["name"], name: "index_test_runners_on_name", unique: true
    t.index ["rsa_key_id"], name: "index_test_runners_on_rsa_key_id"
  end

  create_table "test_suite_runs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
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
    t.index ["project_id"], name: "index_test_suite_runs_on_project_id"
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

  add_foreign_key "charges", "runs"
  add_foreign_key "github_accounts", "users"
  add_foreign_key "github_check_runs", "test_suite_runs", column: "build_id"
  add_foreign_key "github_events", "repositories", column: "project_id"
  add_foreign_key "github_oauth_tokens", "users"
  add_foreign_key "project_secrets", "repositories", column: "project_id"
  add_foreign_key "repositories", "github_accounts"
  add_foreign_key "run_events", "runs"
  add_foreign_key "run_test_runners", "runs"
  add_foreign_key "run_test_runners", "test_runners"
  add_foreign_key "runner_system_logs", "runs"
  add_foreign_key "runs", "test_suite_runs", column: "build_id"
  add_foreign_key "screenshots", "runs"
  add_foreign_key "test_case_runs", "runs"
  add_foreign_key "test_runner_assignments", "runs"
  add_foreign_key "test_runner_assignments", "test_runners"
  add_foreign_key "test_runner_events", "test_runners"
  add_foreign_key "test_runners", "rsa_keys"
  add_foreign_key "test_suite_runs", "repositories", column: "project_id"
end
