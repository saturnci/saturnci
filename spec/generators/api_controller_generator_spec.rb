require "rails_helper"
require "fileutils"
require "rails/generators"
require "generators/api_controller/api_controller_generator"

describe ApiControllerGenerator do
  let(:destination_root) { Rails.root.join("tmp/generators") }

  before do
    allow_any_instance_of(ApiControllerGenerator).to receive(:target_dir).and_return(destination_root)
    FileUtils.rm_rf(destination_root)
    FileUtils.mkdir_p(destination_root)
  end

  it "creates the correct controller file" do
    ApiControllerGenerator.start(%w[orphaned_runner_collection v1 destroy index show])

    file_path = "#{destination_root}/v1/orphaned_runner_collection_controller.rb"

    expect(File).to exist(file_path)
  end
end
