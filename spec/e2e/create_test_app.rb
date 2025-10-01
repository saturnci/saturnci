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

  # 3. Push the resulting code to the repo
  Dir.chdir(repo_name) do
    puts "Pushing to GitHub..."
    # Remove workflow file that requires special permissions
    system("rm -rf .github")
    system("git add .")
    system("git commit -m 'Initial commit'")
    token = `gh auth token`.strip
    system("git remote add origin https://#{token}@github.com/#{username}/#{repo_name}.git")
    system("git push -u origin main --force")
  end
end

puts "Done! Repository: https://github.com/#{username}/#{repo_name}"
