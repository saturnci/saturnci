RSpec.configure do |config|
  config.around :each do |example|
    attempts = 0
    max_attempts = 5

    loop do
      attempts += 1
      example.run

      break if example.exception.nil?
      break if attempts >= max_attempts

      puts "Retry #{attempts}/#{max_attempts}: #{example.full_description}"
      example.instance_variable_set(:@exception, nil)
    end
  end
end
