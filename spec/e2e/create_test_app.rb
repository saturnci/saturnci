#!/usr/bin/env ruby

require "tmpdir"

# 1. Use fixed repository name
repo_name = "saturnci-e2e-test-app"
username = `gh api user --jq .login`.strip

puts "Using repository: #{repo_name}"
# Create repo if it doesn't exist (will fail silently if it already exists)
system("gh repo create #{repo_name} --public 2>/dev/null")

# 2. Run rails new
temp_dir = Dir.mktmpdir("rails-app")
Dir.chdir(temp_dir) do
  puts "Generating Rails app in #{temp_dir}"
  system("rails new #{repo_name} --database=postgresql")

  # 3. Set up RSpec and create a test
  Dir.chdir(repo_name) do
    puts "Setting up RSpec..."

    # Add rspec-rails to Gemfile
    gemfile_content = File.read("Gemfile")
    gemfile_content = gemfile_content.gsub(
      /(group :development, :test do\n)/,
      "\\1  gem \"rspec-rails\"\n"
    )
    File.write("Gemfile", gemfile_content)

    # Install gems and generate RSpec configuration
    system("bundle install")
    system("rails generate rspec:install")

    # Create a simple passing test
    system("mkdir -p spec/models")
    File.write("spec/models/application_record_spec.rb", <<~RSPEC)
      require 'rails_helper'

      RSpec.describe ApplicationRecord, type: :model do
        it "exists" do
          expect(ApplicationRecord).to be_a(Class)
        end
      end
    RSPEC

    puts "Committing initial Rails app with RSpec..."
    # Remove workflow file that requires special permissions
    system("rm -rf .github")
    system("git add .")
    system("git commit -m 'Initial Rails app with RSpec test suite'")
    token = `gh auth token`.strip

    puts "Applying SaturnCI template..."
    system("rails app:template LOCATION=https://raw.githubusercontent.com/saturnci/saturnci-config-templates/main/rails/template.rb")

    puts "Committing SaturnCI configuration..."
    system("git add .")
    system("git commit -m 'Add SaturnCI configuration via Rails template'")

    # 4. Add multiple database support
    puts "Adding multiple database configuration..."

    # Update config/database.yml to use proper multi-database structure
    database_yml = File.read("config/database.yml")

    # Replace the test: section with primary + analytics nested structure
    database_yml = database_yml.gsub(
      /^test:\n  <<: \*default\n  database: #{repo_name}_test$/,
      <<~YAML.chomp
        test:
          primary:
            <<: *default
            database: #{repo_name}_test
          analytics:
            <<: *default
            database: #{repo_name}_analytics_test
            migrations_paths: db/analytics_migrate
      YAML
    )
    File.write("config/database.yml", database_yml)

    # Also update .saturnci/database.yml (used by test runner)
    saturnci_database_yml = File.read(".saturnci/database.yml")

    # Replace the test: section with primary + analytics nested structure
    saturnci_database_yml = saturnci_database_yml.gsub(
      /^test:\n(.*\n)+?(?=\n\S|\z)/m,
      <<~YAML.chomp
        test:
          primary:
            database: saturn_test
            adapter: postgresql
            encoding: unicode
            username: <%= ENV.fetch("DATABASE_USERNAME") %>
            host: <%= ENV.fetch("DATABASE_HOST") %>
            port: <%= ENV.fetch("DATABASE_PORT") %>
          analytics:
            database: #{repo_name}_analytics_test
            adapter: postgresql
            encoding: unicode
            username: <%= ENV.fetch("DATABASE_USERNAME") %>
            host: <%= ENV.fetch("DATABASE_HOST") %>
            port: <%= ENV.fetch("DATABASE_PORT") %>
            migrations_paths: db/analytics_migrate
      YAML
    )
    File.write(".saturnci/database.yml", saturnci_database_yml)

    # Update ApplicationRecord to connect to primary database
    application_record_content = File.read("app/models/application_record.rb")
    application_record_content = application_record_content.gsub(
      /class ApplicationRecord < ActiveRecord::Base\n  self\.abstract_class = true\nend/,
      <<~RUBY.chomp
        class ApplicationRecord < ActiveRecord::Base
          self.abstract_class = true

          connects_to database: { writing: :primary }
        end
      RUBY
    )
    File.write("app/models/application_record.rb", application_record_content)

    # Create AnalyticsRecord base class
    File.write("app/models/analytics_record.rb", <<~RUBY)
      class AnalyticsRecord < ActiveRecord::Base
        self.abstract_class = true

        connects_to database: { writing: :analytics }
      end
    RUBY

    # Create analytics migrations directory
    system("mkdir -p db/analytics_migrate")

    # Create a simple analytics model and migration
    File.write("app/models/event.rb", <<~RUBY)
      class Event < AnalyticsRecord
      end
    RUBY

    File.write("db/analytics_migrate/#{Time.now.utc.strftime('%Y%m%d%H%M%S')}_create_events.rb", <<~RUBY)
      class CreateEvents < ActiveRecord::Migration[8.0]
        def change
          create_table :events do |t|
            t.string :name
            t.timestamps
          end
        end
      end
    RUBY

    # Add a test for the analytics database
    File.write("spec/models/event_spec.rb", <<~RSPEC)
      require 'rails_helper'

      RSpec.describe Event, type: :model do
        it "can be created in the analytics database" do
          event = Event.create(name: "test_event")
          expect(event).to be_persisted
          expect(event.name).to eq("test_event")
        end
      end
    RSPEC

    # Update pre.sh to handle multiple databases
    File.write(".saturnci/pre.sh", <<~SCRIPT)
      #!/bin/bash
      bundle exec rails db:create
      bundle exec rails db:migrate:primary
      bundle exec rails db:migrate:analytics
    SCRIPT
    system("chmod +x .saturnci/pre.sh")

    puts "Committing multiple database configuration..."
    system("git add .")
    system("git commit -m 'Add multiple database support with analytics database'")

    # Important: this script should do one git push and one git push only.
    system("git remote add origin https://#{token}@github.com/#{username}/#{repo_name}.git")
    system("git push -u origin main --force")
  end
end

puts "Done! Repository: https://github.com/#{username}/#{repo_name}"
