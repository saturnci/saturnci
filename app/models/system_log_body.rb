class SystemLogBody
  def initialize(content)
    @content = content
  end

  def scrub
    content.gsub(/ saturnci-[\w-]+ /, " ")
  end

  private

  attr_reader :content
end
