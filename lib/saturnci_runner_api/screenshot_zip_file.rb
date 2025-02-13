class SaturnCIRunnerAPI::ScreenshotZipFile
  def initialize(source:)
    @source = source
  end

  def add_files
    Zip::File.open(path, Zip::File::CREATE) do |zipfile|
      Dir.glob("#{@source}/*").each do |file|
        zipfile.add(File.basename(file), file)
      end
    end
  end

  def path
    "#{@source}/screenshots.zip"
  end
end
