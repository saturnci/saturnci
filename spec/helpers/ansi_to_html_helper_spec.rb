require "rails_helper"

describe ANSIToHTMLHelper do
  include ANSIToHTMLHelper

  it "converts ANSI color codes to HTML" do
    ansi_string = "\e[32mHello\e[0m"
    expect(ansi_to_html(ansi_string)).to eq('<div><span style="color:green;">Hello</span></div>')
  end

  it "removes cursor movement and line clearing codes" do
    ansi_string = "\e[1A\e[2KHello"
    expect(ansi_to_html(ansi_string)).to eq("<div>Hello</div>")
  end

  it "removes null characters" do
    ansi_string = "Hello\x00"
    expect(ansi_to_html(ansi_string)).to eq("<div>Hello</div>")
  end

  it "cleans up 'Creating..." do
    ansi_string = '#033[1A#033[2K#015Creating saturnci_saturn_test_app_run ... #033[32mdone#033[0m#015#033[1B^@'
    expect(ansi_to_html(ansi_string)).to eq('<div>Creating saturnci_saturn_test_app_run ... <span style="color:green;">done</span></div>')
  end
end
