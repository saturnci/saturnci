require "rails_helper"

RSpec.describe ProjectSecretCollection, type: :model do
  let!(:project_secret_collection) { ProjectSecretCollection.new }

  describe "#project_secrets_attributes=" do
    it "creates a project secret for each key and value" do
      project_secret_collection.project_secrets_attributes = {
        "0" => {
          "key"=>"DATABASE_USERNAME",
          "value"=>"steve"
        }
      }

      project_secret = project_secret_collection.project_secrets[0]
      expect(project_secret.key).to eq("DATABASE_USERNAME")
      expect(project_secret.value).to eq("steve")
    end

    context "empty attributes" do
      let!(:project_secret_collection) do
        ProjectSecretCollection.new(
          project_secrets_attributes: {
            "0" => {
              "key"=>"DATABASE_USERNAME",
              "value"=>"steve"
            },
            "1" => {
              "key"=>"",
              "value"=>""
            }
          }
        )
      end

      it "skips the empty attributes" do
        expect(project_secret_collection.project_secrets.count).to eq(1)
      end
    end
  end

  describe "#save!" do
    it "creates a project secret for each key and value" do
      project_secret_collection = ProjectSecretCollection.new
      project_secret_collection.project_secrets_attributes = {
        "0" => {
          "key"=>"DATABASE_USERNAME",
          "value"=>"steve"
        }
      }

      project_secret_collection.project = create(:project)

      expect {
        project_secret_collection.save!
      }.to change { ProjectSecret.count }.by(1)
    end
  end
end
