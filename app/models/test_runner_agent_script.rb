class TestRunnerAgentScript
  def initialize(run, github_installation_id)
    @run = run
    @github_installation_id = github_installation_id
  end

  def library_content
    Dir.glob(Rails.root.join("lib", "saturnci_runner_api", "*")).sort.map do |file_path|
      File.read(file_path)
    end.join("\n")
  end

  def script_content
    File.read(File.join(Rails.root, "lib", "script.rb"))
  end

  def content
    encoded_script = Base64.strict_encode64(library_content + script_content)

    secrets = @run.test_suite_run.repository.project_secrets.map do |secret| 
      "#{secret.key}=#{secret.value}"
    end

    <<~SCRIPT
      #!/usr/bin/bash

      #{secrets.map { |secret| "export #{secret}" }.join("\n")}

      export SATURNCI_ENV_FILE_PATH=/tmp/.saturnci.env
      #{secrets.map { |secret| "echo '#{secret}' >> $SATURNCI_ENV_FILE_PATH" }.join("\n")}

      export HOST=#{ENV["SATURNCI_HOST"]}
      export DOCKER_REGISTRY_CACHE_USERNAME=#{ENV["DOCKER_REGISTRY_CACHE_USERNAME"]}
      export DOCKER_REGISTRY_CACHE_PASSWORD=#{ENV["DOCKER_REGISTRY_CACHE_PASSWORD"]}
      export TEST_SUITE_RUN_ID=#{@run.test_suite_run.id}
      export PROJECT_NAME=#{@run.test_suite_run.repository.name}
      export BRANCH_NAME=#{@run.test_suite_run.branch_name}
      export RUN_ID=#{@run.id}
      export RUN_ORDER_INDEX=#{@run.order_index}
      export TEST_RUNNER_ID=#{@run.test_runner.id}
      export TEST_RUNNER_ACCESS_TOKEN=#{@run.test_runner.access_token.value}
      export NUMBER_OF_CONCURRENT_RUNS=#{@run.test_suite_run.repository.concurrency}
      export COMMIT_HASH=#{@run.test_suite_run.commit_hash}
      export RSPEC_SEED=#{@run.test_suite_run.seed}
      export GITHUB_INSTALLATION_ID=#{@github_installation_id}
      export GITHUB_REPO_FULL_NAME=#{@run.test_suite_run.repository.github_repo_full_name}

      RUBY_SCRIPT_PATH=/tmp/runner_script.rb
      echo #{encoded_script} | base64 --decode > $RUBY_SCRIPT_PATH
      ruby $RUBY_SCRIPT_PATH
    SCRIPT
  end
end
