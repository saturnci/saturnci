class InitSchema < ActiveRecord::Migration[7.1]
  def change
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
      t.index ["project_id"], name: "index_builds_on_project_id"
    end

    create_table "charges", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.uuid "job_id", null: false
      t.decimal "rate", null: false
      t.decimal "job_duration", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["job_id"], name: "index_charges_on_job_id"
      t.index ["job_id"], name: "unique_index_on_charges_job_id", unique: true
    end

    create_table "job_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.uuid "job_id", null: false
      t.integer "type", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["job_id", "type"], name: "index_job_events_on_job_id_and_type", unique: true
      t.index ["job_id"], name: "index_job_events_on_job_id"
    end

    create_table "jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.uuid "build_id", null: false
      t.string "job_machine_id"
      t.text "test_output"
      t.text "test_report"
      t.text "system_logs"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "order_index", null: false
      t.string "job_machine_rsa_key_path"
      t.index ["build_id", "order_index"], name: "index_jobs_on_build_id_and_order_index", unique: true
      t.index ["build_id"], name: "index_jobs_on_build_id"
      t.index ["job_machine_id"], name: "index_jobs_on_job_machine_id", unique: true
    end

    create_table "projects", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.string "name", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "github_repo_full_name"
      t.uuid "user_id", null: false
      t.uuid "saturn_installation_id"
      t.boolean "active", default: true, null: false
      t.index ["saturn_installation_id"], name: "index_projects_on_saturn_installation_id"
      t.index ["user_id"], name: "index_projects_on_user_id"
    end

    create_table "saturn_installations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.uuid "user_id", null: false
      t.string "github_installation_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "name"
      t.index ["user_id", "github_installation_id"], name: "index_saturn_installations_on_user_and_github_id", unique: true
      t.index ["user_id"], name: "index_saturn_installations_on_user_id"
    end

    create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.string "email", default: "", null: false
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
      t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
      t.index ["email"], name: "index_users_on_email", unique: true
      t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    end

    add_foreign_key "builds", "projects"
    add_foreign_key "charges", "jobs"
    add_foreign_key "job_events", "jobs"
    add_foreign_key "jobs", "builds"
    add_foreign_key "projects", "saturn_installations"
    add_foreign_key "projects", "users"
    add_foreign_key "saturn_installations", "users"
  end
end
