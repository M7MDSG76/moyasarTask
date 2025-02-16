
class DatabaseStorageService
  def initialize(config = {})
    @config = config
    Rails.logger.info "DatabaseStorageService initialized"
  end

  def store(id, data)
    # record = Blob.create!(
    #   uid: id,
    #   size: data.bytesize,
    #   created_at: Time.now.utc,
    #   storage_backend: ENV["STORAGE_BACKEND"],
    #   storage_identifier: id,
    # )
    # { identifier: record.id }
  end

  def retrieve(uid)
    Blob.find_by!(uid: uid)
  end
end
