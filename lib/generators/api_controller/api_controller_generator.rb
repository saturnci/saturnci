require "rails/generators/named_base"

class ApiControllerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  argument :version, type: :string
  argument :actions, type: :array

  def create_controller_file
    path = File.join(
      target_dir,
      version.underscore,
      "#{name.underscore}_controller.rb"
    )

    @version = version.camelize
    @name = name.camelize
    @actions = actions

    template "controller.rb.tt", path
  end

  def target_dir
    "app/controllers/api/"
  end
end
