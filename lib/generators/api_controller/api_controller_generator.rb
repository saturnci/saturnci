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
    add_route
  end

  def target_dir
    "app/controllers/api/"
  end

  private

  def add_route
    route_path = "config/routes/api.rb"
    route_entry = generate_route_entry

    inject_into_file route_path, route_entry, after: "namespace :#{version.underscore} do\n"
  end

  def generate_route_entry
    route_lines = []
    route_lines << "    resources :#{name.underscore.pluralize}, only: #{actions.map(&:to_sym).inspect}" if actions.any?
    route_lines.join("\n") + "\n"
  end
end
