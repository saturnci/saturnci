class RunnerScript
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

    <<~SCRIPT
      #!/usr/bin/bash
      export HOST=#{ENV["SATURNCI_HOST"]}
      export RUN_ID=#{@run.id}
      export SATURNCI_API_USERNAME=#{ENV["SATURNCI_API_USERNAME"]}
      export SATURNCI_API_PASSWORD=#{ENV["SATURNCI_API_PASSWORD"]}
      export JOB_ORDER_INDEX=#{@run.order_index}
      export NUMBER_OF_CONCURRENT_RUNS=#{Build::NUMBER_OF_CONCURRENT_RUNS}
      export COMMIT_HASH=#{@run.build.commit_hash}
      export RSPEC_SEED=#{@run.build.seed}
      export GITHUB_INSTALLATION_ID=#{@github_installation_id}
      export GITHUB_REPO_FULL_NAME=#{@run.build.project.github_repo_full_name}

      export USER_ENV_VAR_KEYS="#{@run.build.project.project_secrets.map(&:key).join(",")}"
      #{@run.build.project.project_secrets.map { |secret| "export #{secret.key}=#{secret.value}" }.join("\n")}

      RUBY_SCRIPT_PATH=/tmp/runner_script.rb
      echo #{encoded_script} | base64 --decode > $RUBY_SCRIPT_PATH
      ruby $RUBY_SCRIPT_PATH
    SCRIPT
  end
end