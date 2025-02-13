class SaturnCIRunnerAPI::ScreenshotTarFile
  def initialize(source:)
    @source = source
    system("tar -czf #{path} -C #{@source} .")
  end

  def path
    "#{@source}/screenshots.tar.gz"
  end
end
