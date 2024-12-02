module TurboStreamsExtension
  def self.logger
    @turbo_stream_logger ||= ActiveSupport::Logger.new(Rails.root.join("log", "turbo_stream_#{Rails.env}.log")).tap do |logger|
      logger.formatter = Logger::Formatter.new
    end
  end

  def logger
    TurboStreamsExtension.logger
  end
end

ActionCable::Channel::Base.prepend(TurboStreamsExtension)
