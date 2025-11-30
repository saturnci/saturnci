namespace :worker do
  task test_provision: :environment do
    worker = Worker.provision
    puts "Provisioning #{worker.name}..."

    loop do
      sleep 5
      worker.reload
      puts worker.status
      break if worker.status == "Available"
    end

    worker.destroy
    puts "Done."
  end
end
