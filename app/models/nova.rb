module Nova
  def self.provision_worker(task)
    access_token = AccessToken.create!
    worker = Worker.create!(name: "nova-#{SecureRandom.hex(4)}", access_token: access_token)
    WorkerAssignment.create!(worker: worker, task: task)

    puts "Worker created. Run locally:"
    puts "  ./ops/nova_run.sh #{worker.id} #{access_token.value} #{task.id}"

    worker
  end
end
