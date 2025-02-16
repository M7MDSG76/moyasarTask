# require_relative "storage/local_storage_service"
class LocalStorageService
  def initialize(config = {})
    @storage_path = config[:path]
    puts "LocalStorageService initialized with storage_path: #{@storage_path}"
    FileUtils.mkdir_p(@storage_path)
  end

  def store(id, data)
    puts "LocalStorageService: storing data with id: #{id}"
    file_path = File.join(@storage_path, id)
    puts "LocalStorageService: storing data to #{file_path}"
    File.binwrite(file_path, data)
    { identifier: id }
  end

  def retrieve(identifier)
    File.binread(File.join(@storage_path, identifier))
  end
end
