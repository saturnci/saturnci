class SystemLogBody
  def initialize(content)
    @content = content
  end

  def scrub
    @content.to_s.gsub(/ \w+-[\w-]+ /, " ")
  end
end
