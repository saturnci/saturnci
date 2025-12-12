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

ActiveRecord::Schema[8.0].define(version: 2025_12_12_005803) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "access_tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "charges", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "task_id", null: false
    t.decimal "rate", null: false
    t.decimal "run_duration", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id"], name: "index_charges_on_task_id"
    t.index ["task_id"], name: "unique_index_on_charges_job_id", unique: true
  end

  create_table "failure_reruns", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "original_test_suite_run_id", null: false
    t.uuid "test_suite_run_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["original_test_suite_run_id", "test_suite_run_id"], name: "idx_on_original_test_suite_run_id_test_suite_run_id_d4e9789963", unique: true
    t.index ["original_test_suite_run_id"], name: "index_failure_reruns_on_original_test_suite_run_id"
    t.index ["test_suite_run_id"], name: "index_failure_reruns_on_test_suite_run_id"
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
    t.index ["user_id", "github_installation_id"], name: "index_github_accounts_on_user_and_github_id", unique: true
    t.index ["user_id"], name: "index_github_accounts_on_user_id"
  end

  create_table "github_check_runs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "test_suite_run_id", null: false
    t.string "github_check_run_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["test_suite_run_id", "github_check_run_id"], name: "idx_on_test_suite_run_id_github_check_run_id_3b7f89aa62", unique: true
    t.index ["test_suite_run_id"], name: "index_github_check_runs_on_test_suite_run_id"
  end

  create_table "github_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.jsonb "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "repository_id"
    t.string "type", null: false
    t.index ["repository_id"], name: "index_github_events_on_repository_id"
  end

  create_table "github_oauth_tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "value"], name: "index_github_oauth_tokens_on_user_id_and_value", unique: true
    t.index ["user_id"], name: "index_github_oauth_tokens_on_user_id"
  end

  create_table "personal_access_tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "access_token_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["access_token_id"], name: "index_personal_access_tokens_on_access_token_id"
    t.index ["user_id"], name: "index_personal_access_tokens_on_user_id"
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
    t.boolean "start_test_suite_runs_automatically_on_git_push", default: false, null: false
    t.datetime "deleted_at"
    t.integer "concurrency", default: 2, null: false
    t.boolean "create_github_checks_automatically_upon_pull_request_creation", default: false, null: false
    t.uuid "worker_architecture_id", null: false
    t.index ["github_account_id"], name: "index_repositories_on_github_account_id"
    t.index ["worker_architecture_id"], name: "index_repositories_on_worker_architecture_id"
  end

  create_table "rsa_keys", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "public_key_value", null: false
    t.text "private_key_value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sent_emails", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "to", null: false
    t.string "subject", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "task_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "task_id", null: false
    t.integer "type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id", "type"], name: "index_task_events_on_task_id_and_type", unique: true
    t.index ["task_id"], name: "index_task_events_on_task_id"
  end

  create_table "task_workers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "task_id", null: false
    t.uuid "worker_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id"], name: "index_task_workers_on_task_id"
    t.index ["task_id"], name: "run_test_runners_run_id", unique: true
    t.index ["worker_id"], name: "index_task_workers_on_worker_id"
    t.index ["worker_id"], name: "run_test_runners_test_runner_id", unique: true
  end

  create_table "tasks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "test_suite_run_id", null: false
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
    t.index ["runner_id"], name: "index_tasks_on_runner_id", unique: true
    t.index ["test_suite_run_id", "order_index"], name: "index_tasks_on_test_suite_run_id_and_order_index", unique: true
    t.index ["test_suite_run_id"], name: "index_tasks_on_test_suite_run_id"
  end

  create_table "test_case_runs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "identifier", null: false
    t.string "path", null: false
    t.integer "line_number", null: false
    t.integer "status", null: false
    t.float "duration", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "task_id", null: false
    t.string "description", null: false
    t.text "exception"
    t.text "exception_message"
    t.text "exception_backtrace"
    t.index ["task_id"], name: "index_test_case_runs_on_task_id"
  end

  create_table "test_failure_screenshots", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "test_case_run_id", null: false
    t.string "path", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["test_case_run_id", "path"], name: "index_test_failure_screenshots_on_test_case_run_id_and_path", unique: true
  end

  create_table "test_suite_run_result_notifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "test_suite_run_id", null: false
    t.uuid "sent_email_id", null: false
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sent_email_id"], name: "index_test_suite_run_result_notifications_on_sent_email_id"
    t.index ["test_suite_run_id", "email"], name: "index_tsrrn_on_test_suite_run_and_email", unique: true
    t.index ["test_suite_run_id"], name: "index_test_suite_run_result_notifications_on_test_suite_run_id"
  end

  create_table "test_suite_runs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "repository_id", null: false
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
    t.integer "dry_run_example_count"
    t.uuid "started_by_user_id"
    t.index ["repository_id"], name: "index_test_suite_runs_on_repository_id"
    t.index ["started_by_user_id"], name: "index_test_suite_runs_on_started_by_user_id"
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

  create_table "worker_architectures", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_worker_architectures_on_slug", unique: true
  end

  create_table "worker_assignments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "worker_id", null: false
    t.uuid "task_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id"], name: "index_worker_assignments_on_task_id"
    t.index ["task_id"], name: "unique_runs", unique: true
    t.index ["worker_id"], name: "index_worker_assignments_on_worker_id"
    t.index ["worker_id"], name: "unique_test_runners", unique: true
  end

  create_table "worker_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "worker_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.text "notes"
    t.index ["worker_id"], name: "index_worker_events_on_worker_id"
  end

  create_table "worker_snapshots", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "cloud_id", null: false
    t.string "os", null: false
    t.string "size", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "worker_system_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "task_id", null: false
    t.text "content", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id"], name: "index_worker_system_logs_on_task_id"
  end

  create_table "workers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "cloud_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "rsa_key_id"
    t.boolean "terminate_on_completion", default: true, null: false
    t.uuid "access_token_id", null: false
    t.uuid "task_id", null: false
    t.index ["cloud_id"], name: "index_workers_on_cloud_id", unique: true
    t.index ["name"], name: "index_workers_on_name", unique: true
    t.index ["rsa_key_id"], name: "index_workers_on_rsa_key_id"
    t.index ["task_id"], name: "index_workers_on_task_id"
  end

  add_foreign_key "charges", "tasks"
  add_foreign_key "failure_reruns", "test_suite_runs"
  add_foreign_key "failure_reruns", "test_suite_runs", column: "original_test_suite_run_id"
  add_foreign_key "github_accounts", "users"
  add_foreign_key "github_check_runs", "test_suite_runs"
  add_foreign_key "github_events", "repositories"
  add_foreign_key "github_oauth_tokens", "users"
  add_foreign_key "personal_access_tokens", "access_tokens"
  add_foreign_key "personal_access_tokens", "users"
  add_foreign_key "project_secrets", "repositories", column: "project_id"
  add_foreign_key "repositories", "github_accounts"
  add_foreign_key "repositories", "worker_architectures"
  add_foreign_key "task_events", "tasks"
  add_foreign_key "task_workers", "tasks"
  add_foreign_key "task_workers", "workers"
  add_foreign_key "tasks", "test_suite_runs"
  add_foreign_key "test_case_runs", "tasks"
  add_foreign_key "test_failure_screenshots", "test_case_runs"
  add_foreign_key "test_suite_run_result_notifications", "sent_emails"
  add_foreign_key "test_suite_run_result_notifications", "test_suite_runs"
  add_foreign_key "test_suite_runs", "repositories"
  add_foreign_key "test_suite_runs", "users", column: "started_by_user_id"
  add_foreign_key "worker_assignments", "tasks"
  add_foreign_key "worker_assignments", "workers"
  add_foreign_key "worker_events", "workers"
  add_foreign_key "worker_system_logs", "tasks"
  add_foreign_key "workers", "rsa_keys"
  add_foreign_key "workers", "tasks"
end
