Rails.application.config.solid_queue.on_thread_error = ->(exception) {
  Bugsnag.notify(exception)
}
