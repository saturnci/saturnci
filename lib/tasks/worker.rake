namespace :worker do
  task test_provision: :environment do
    start_time = Time.now
    worker = Worker.provision
    puts "Provisioning #{worker.name}..."

    loop do
      sleep 10
      worker.reload
      elapsed = (Time.now - start_time).round
      puts "#{worker.status} (#{elapsed}s)"
      break if worker.status == "Available"
    end

    worker.destroy
    puts "Done."
  end
end
