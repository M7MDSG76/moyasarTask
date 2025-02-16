require_relative "storage/local_storage_service"
require_relative "database_storage_service"
class StorageServiceFactory
  def self.build
    puts "S3StorageService initialized with bucket_name: #{ENV["S3_BUCKET"]}, region: #{ENV["AWS_REGION"]}, access_key_id: #{ENV["AWS_ACCESS_KEY_ID"]}, secret_access_key: #{ENV["AWS_SECRET_ACCESS_KEY"]}"

    case ENV["STORAGE_BACKEND"]
    when "s3"
      s3_service = S3StorageService.new(
        bucket_name: ENV["S3_BUCKET"],
        region: ENV["AWS_REGION"],
        access_key_id: ENV["AWS_ACCESS_KEY_ID"],
        secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]
      )
      puts "S3StorageService initialized with bucket_name: #{s3_service}"
      s3_service
    when "database"
      puts "creating DatabaseStorageService"
      DatabaseStorageService.new
    else
      puts "creating LocalStorageService"
      LocalStorageService.new(path: ENV["LOCAL_STORAGE_PATH"])
    end
  end
end
