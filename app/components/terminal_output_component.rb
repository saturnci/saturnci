class TerminalOutputComponent < ViewComponent::Base
  attr_reader :current_tab_name, :run, :body

  def initialize(current_tab_name:, run:, body:)
    @current_tab_name = current_tab_name
    @run = run
    @body = body
  end
end
