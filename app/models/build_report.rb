class BuildReport
  def initialize(content)
    @content = content || ""
  end

  def to_s
    @content.split("\n").map do |line|
      BuildReportRow.new(line).colorized
    end.join("\n")
  end
end
