require "rails/generators/named_base"

class APIControllerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  argument :actions, type: :array, default: [], banner: "action action"

  def create_controller_file
    namespaced_path = file_path
    template "controller.rb.tt", File.join("app/controllers", "#{namespaced_path}_controller.rb")
  end
end
