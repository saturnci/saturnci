# frozen_string_literal: true

require "rails_helper"

RSpec.describe BuildFilterComponent, type: :component do
  let!(:build_filter_component) do
    BuildFilterComponent.new(
      job: nil,
      build_list: nil,
      statuses: ["Passed"],
      current_tab_name: nil
    )
  end

  context "status is checked" do
    it "returns true" do
      expect(build_filter_component.checked?("Passed")).to be true
    end
  end

  context "status is not checked" do
    it "returns false" do
      expect(build_filter_component.checked?("Failed")).to be false
    end
  end
end
