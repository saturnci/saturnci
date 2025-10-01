#!/usr/bin/env ruby

require "tmpdir"

# 1. Create a new repository
timestamp = Time.now.to_i
repo_name = "saturnci-test-app-#{timestamp}"
username = `gh api user --jq .login`.strip

puts "Creating GitHub repository: #{repo_name}"
system("gh repo create #{repo_name} --public")

# 2. Run rails new
temp_dir = Dir.mktmpdir("rails-app")
Dir.chdir(temp_dir) do
  puts "Generating Rails app in #{temp_dir}"
  system("rails new #{repo_name} --database=postgresql")

  # 3. Push the resulting code to the repo
  Dir.chdir(repo_name) do
    puts "Pushing to GitHub..."
    # Remove workflow file that requires special permissions
    system("rm -rf .github")
    system("git add .")
    system("git commit -m 'Initial commit'")
    token = `gh auth token`.strip
    system("git remote add origin https://#{token}@github.com/#{username}/#{repo_name}.git")
    system("git push -u origin main")
  end
end

puts "Done! Repository: https://github.com/#{username}/#{repo_name}"
