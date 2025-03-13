require "rails_helper"

describe TestRunnerPool do
  describe "#scale" do
    let!(:client) { double }

    before do
      admin_user = double
      allow(admin_user).to receive(:id).and_return(1)
      allow(admin_user).to receive(:api_token).and_return("token")
      allow(User).to receive(:find_by).and_return(admin_user)

      droplet_request = double
      allow(droplet_request).to receive(:id) { rand(10000000) }
      allow(client).to receive_message_chain(:droplets, :create).and_return(droplet_request)

      ssh_key = double
      allow(ssh_key).to receive(:id).and_return("333")
      allow(client).to receive_message_chain(:ssh_keys, :create).and_return(ssh_key)
    end

    context "scaling to 10" do
      it "creates 10 test runners" do
        expect { TestRunnerPool.scale(10, client:) }
          .to change { TestRunner.count }
          .from(0).to(10)
      end
    end

    context "scaling to 2" do
      it "creates 2 test runners" do
        expect { TestRunnerPool.scale(2, client:) }
          .to change { TestRunner.count }
          .from(0).to(2)
      end
    end

    context "scaling up and then back down" do
      before do
        allow(client).to receive_message_chain(:droplets, :delete)
      end

      it "works" do
        TestRunnerPool.scale(10, client:)
        expect { TestRunnerPool.scale(2, client:) }
          .to change { TestRunner.count }
          .from(10).to(2)
      end
    end

    context "scaling and then scaling again to the same number" do
      it "does not delete test runners" do
        TestRunnerPool.scale(2, client:)
        expect { TestRunnerPool.scale(2, client:) }
          .not_to change { TestRunner.all.map(&:id) }
      end
    end
  end
end
