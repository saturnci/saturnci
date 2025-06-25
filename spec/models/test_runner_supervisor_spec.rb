require "rails_helper"

describe TestRunnerSupervisor do
  before do
    allow(TestRunner).to receive(:create_vm)
    allow_any_instance_of(TestRunner).to receive(:deprovision)
    allow(TestRunnerSupervisor).to receive(:log)
  end

  describe ".check" do
    describe "pool" do
      before do
        allow(TestRunnerSupervisor).to receive(:test_runner_pool_size).and_return(4)
      end

      context "there are 3 test runners" do
        it "creates 1 test runner" do
          create_list(:test_runner, 3)
          expect { TestRunnerSupervisor.check }.to change(TestRunner, :count).by(1)
        end
      end

      context "there are 4 test runners" do
        it "does not create a test runner" do
          create_list(:test_runner, 4)
          expect { TestRunnerSupervisor.check }.to_not change(TestRunner, :count)
        end
      end

      context "there are 4 test runners, but one is in error" do
        it "deletes one and creates one" do
          create_list(:test_runner, 3)
          test_runner = create(:test_runner)
          test_runner.test_runner_events.create!(type: :error)

          TestRunnerSupervisor.check
          expect(TestRunner.count).to eq(4)
        end
      end

      context "there are 5 test runners but 4 of them are assigned" do
        it "creates 4 - 1 = 3 test runners" do
          create_list(:test_runner_assignment, 4)
          create(:test_runner)
          expect { TestRunnerSupervisor.check }.to change(TestRunner, :count).by(3)
        end
      end

      context "there are 6 unassigned test runners" do
        it "deletes an unassigned test runner" do
          create_list(:test_runner, 5)
          expect { TestRunnerSupervisor.check }.to change(TestRunner, :count).by(-1)
        end
      end

      context "there are 4 unassigned test runners and 2 more in error" do
        it "deletes the 2 errored test runners" do
          create_list(:test_runner, 4)

          2.times do
            test_runner = create(:test_runner)
            test_runner.test_runner_events.create!(type: :error)
          end

          expect { TestRunnerSupervisor.check }.to change(TestRunner, :count).by(-2)
        end
      end

      context "there's an unassigned test runner that's more than an hour old" do
        it "deletes it" do
          test_runner = create(:test_runner)

          travel_to(2.hours.from_now) do
            expect { TestRunnerSupervisor.check }.to change { TestRunner.exists?(test_runner.id) }.to(false)
          end
        end
      end

      context "there's an assigned test runner that's more than an hour old" do
        it "does not delete it" do
          test_runner = create(:test_runner_assignment).test_runner

          travel_to(2.hours.from_now) do
            expect { TestRunnerSupervisor.check }.to_not change { TestRunner.exists?(test_runner.id) }
          end
        end
      end
    end

    context "run already finished" do
      let!(:run) { create(:run, :passed) }

      before do
        allow(TestRunner).to receive(:available).and_return([create(:test_runner)])
      end

      it "does not add an assignment" do
        expect { TestRunnerSupervisor.check }.to_not change(TestRunnerAssignment, :count)
      end
    end

    context "an assigned test runner hasn't started running within 30 seconds" do
      let!(:test_runner_assignment) { create(:test_runner_assignment) }

      it "deletes the assignment" do
        travel_to(60.seconds.from_now) do
          TestRunnerSupervisor.check
          expect(TestRunnerAssignment.exists?(test_runner_assignment.id)).to be false
        end
      end

      it "puts the test runner in error status" do
        travel_to(60.seconds.from_now) do
          TestRunnerSupervisor.check
          expect(test_runner_assignment.test_runner.status).to eq("Error")
        end
      end

      context "run is more than a day old" do
        before do
          allow(TestRunnerSupervisor).to receive(:delete_old_test_runners)
        end

        it "does not delete the assignment" do
          travel_to(25.hours.from_now) do
            TestRunnerSupervisor.check
            expect(TestRunnerAssignment.exists?(test_runner_assignment.id)).to be true
          end
        end
      end
    end

    context "an assigned test runner HAS started running within 30 seconds" do
      it "does not delete the assignment" do
        test_runner_assignment = create(:test_runner_assignment)

        create(
          :test_runner_event,
          test_runner: test_runner_assignment.test_runner,
          type: :assignment_acknowledged
        )

        travel_to(60.seconds.from_now) do
          TestRunnerSupervisor.check
          expect(TestRunnerAssignment.exists?(test_runner_assignment.id)).to be true
        end
      end
    end

    context "a run has already been executed but its assignment was deleted" do
      it "does not reassign the run" do
        completed_run = create(:run, :passed)

        test_runner_assignment = create(:test_runner_assignment, run: completed_run)
        test_runner_assignment.destroy

        test_runner = create(:test_runner)
        allow(TestRunner).to receive(:available).and_return([test_runner])

        expect { TestRunnerSupervisor.check }.to_not change(TestRunnerAssignment, :count)
      end
    end
  end

  describe ".test_runner_pool_size" do
    before do
      stub_const("ENV", ENV.to_hash.merge("TEST_RUNNER_POOL_SIZE" => "10"))
      create(:run)
    end

    context "a run has been created within the last hour" do
      it "returns TEST_RUNNER_POOL_SIZE" do
        expect(TestRunnerSupervisor.test_runner_pool_size).to eq(10)
      end
    end

    context "a run has not been created within the last hour" do
      it "returns 0" do
        travel_to(2.hours.from_now) do
          expect(TestRunnerSupervisor.test_runner_pool_size).to eq(0)
        end
      end
    end
  end
end
