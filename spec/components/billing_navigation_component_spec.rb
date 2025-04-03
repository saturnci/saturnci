require "rails_helper"

describe BillingNavigationComponent, type: :component do
  context "there was a run in January 2020 with a charge" do
    let!(:run) do
      create(:run, created_at: "01-01-2020").finish!
    end

    let!(:billing_navigation_component) do
      BillingNavigationComponent.new(project: run.build.project)
    end

    it "includes a date for January 2020" do
      expect(billing_navigation_component.dates).to eq([["2020", "01"]])
    end
  end

  context "there was a run in January 2020 without a charge" do
    let!(:run) do
      create(:run, created_at: "01-01-2020")
    end

    let!(:billing_navigation_component) do
      BillingNavigationComponent.new(project: run.build.project)
    end

    it "does not include a date for January 2020" do
      expect(billing_navigation_component.dates).to eq([])
    end
  end
end
