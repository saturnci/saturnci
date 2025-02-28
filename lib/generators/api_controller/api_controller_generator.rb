require "rails/generators/named_base"

class ApiControllerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  argument :version, type: :string
  argument :controller_class_name, type: :string
  argument :actions, type: :array

  def create_controller_file
    raise ArgumentError, "You must specify a version and controller name" unless version && controller_class_name

    path = File.join(
      target_dir,
      version.underscore,
      "#{controller_class_name.underscore}_controller.rb"
    )

    @version = version.camelize
    @controller_class_name = controller_class_name.camelize
    @actions = actions

    template "controller.rb.tt", path
  end

  def target_dir
    "app/controllers/api/"
  end
end
