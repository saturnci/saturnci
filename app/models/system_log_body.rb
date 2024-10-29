class SystemLogBody
  def initialize(content)
    @content = content
  end

  def scrub
    content.to_s.gsub(/ saturnci-[\w-]+ /, " ")
  end

  private

  attr_reader :content
end
