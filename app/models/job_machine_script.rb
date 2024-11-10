class JobMachineScript
  def initialize(job, github_installation_id)
    @job = job
    @github_installation_id = github_installation_id
  end

  def library_content
    stream_filename = File.join(Rails.root, "lib", "saturnci_job_api", "stream.rb")
    test_suite_command_filename = File.join(Rails.root, "lib", "saturnci_job_api", "test_suite_command.rb")
    client_filename = File.join(Rails.root, "lib", "saturnci_job_api", "client.rb")
    file_content_request_filename = File.join(Rails.root, "lib", "saturnci_job_api", "file_content_request.rb")
    content_request_filename = File.join(Rails.root, "lib", "saturnci_job_api", "content_request.rb")
    request_filename = File.join(Rails.root, "lib", "saturnci_job_api", "request.rb")
    script_filename = File.join(Rails.root, "lib", "saturnci_job_api", "script.rb")

    File.read(stream_filename) +
      File.read(test_suite_command_filename) +
      File.read(client_filename) +
      File.read(file_content_request_filename) +
      File.read(content_request_filename) +
      File.read(request_filename) +
      File.read(script_filename)
  end

  def content
    encoded_script = Base64.strict_encode64(library_content)

    <<~SCRIPT
      #!/usr/bin/bash
      export HOST=#{ENV["SATURNCI_HOST"]}
      export JOB_ID=#{@job.id}
      export SATURNCI_API_USERNAME=#{ENV["SATURNCI_API_USERNAME"]}
      export SATURNCI_API_PASSWORD=#{ENV["SATURNCI_API_PASSWORD"]}
      export JOB_ORDER_INDEX=#{@job.order_index}
      export NUMBER_OF_CONCURRENT_JOBS=#{Build::NUMBER_OF_CONCURRENT_JOBS}
      export COMMIT_HASH=#{@job.build.commit_hash}
      export RSPEC_SEED=#{@job.build.seed}
      export GITHUB_INSTALLATION_ID=#{@github_installation_id}
      export GITHUB_REPO_FULL_NAME=#{@job.build.project.github_repo_full_name}

      export USER_ENV_VAR_KEYS="#{@job.build.project.project_secrets.map(&:key).join(",")}"
      #{@job.build.project.project_secrets.map { |secret| "export #{secret.key}=#{secret.value}" }.join("\n")}

      RUBY_SCRIPT_PATH=/tmp/job_machine_script.rb
      echo #{encoded_script} | base64 --decode > $RUBY_SCRIPT_PATH
      ruby $RUBY_SCRIPT_PATH
    SCRIPT
  end
end
