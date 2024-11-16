require "rails_helper"

RSpec.describe ProjectSecretCollection, type: :model do
  describe "#project_secrets_attributes=" do
    let!(:project_secret_collection) do
      ProjectSecretCollection.new(project: create(:project))
    end

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
          project: create(:project),
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
        project_secret_collection.save!
        expect(project_secret_collection.project.project_secrets.count).to eq(1)
      end
    end
  end

  describe "#save!" do
    let!(:project_secret_collection) do
      ProjectSecretCollection.new(project: create(:project))
    end

    it "creates a project secret for each key and value" do
      project_secret_collection.project_secrets_attributes = {
        "0" => {
          "key"=>"DATABASE_USERNAME",
          "value"=>"steve"
        }
      }

      expect {
        project_secret_collection.save!
      }.to change { ProjectSecret.count }.from(0).to(1)
    end

    context "project secret already exists" do
      let!(:project_secret) do
        create(:project_secret, key: "DATABASE_USERNAME", value: "steve")
      end

      before do
        project_secret_collection.project = project_secret.project

        project_secret_collection.project_secrets_attributes = {
          "0" => {
            "key"=>"DATABASE_USERNAME",
            "value"=>"gleve"
          }
        }
      end

      it "updates the existing project secret" do
        project_secret_collection.save!
        expect(ProjectSecret.find_by(key: "DATABASE_USERNAME").value).to eq("gleve")
      end

      it "does not create a new project secret" do
        expect { project_secret_collection.save! }.not_to change(ProjectSecret, :count)
      end
    end

    context "adding a project secret" do
      let!(:project_secret_collection) do
        ProjectSecretCollection.new(project: create(:project))
      end

      it "creates a project secret" do
        project_secret_collection.project_secrets_attributes = {
          "0" => {
            "key"=>"DATABASE_USERNAME",
            "value"=>"steve"
          }
        }
        project_secret_collection.save!

        project_secret_collection.project_secrets_attributes = {
          "0" => {
            "key"=>"DATABASE_USERNAME",
            "value"=>"steve"
          },
          "1" => {
            "key"=>"DATABASE_PASSWORD",
            "value"=>"mypassword"
          }
        }
        project_secret_collection.save!

        expect(project_secret_collection.project.project_secrets.count).to eq(2)
      end
    end
  end
end
