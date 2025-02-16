module V1
  class BlobsController < ApplicationController
    include Authenticable
    before_action :authenticate_request
    skip_before_action :verify_authenticity_token, only: [ :create ]

    def create
      puts "params: #{params.inspect}"
      begin
        uid = SecureRandom.uuid
        if Blob.exists?(uid: uid)
          uid = SecureRandom.uuid
          # return render json: { error: "uid already exists" }, status: :conflict
        end
        blob_data = Base64.decode64(params[:data])
        puts "blob_data: #{blob_data}"
      rescue ArgumentError => e
        puts "Base64 decoding error: #{e.message}"
        render json: { error: "Invalid Base64 data" }, status: :bad_request
        return
      end

      storage_service = StorageServiceFactory.build
      puts "storage_service: #{storage_service}"
      storage_info = storage_service.store(uid, blob_data)
      puts "storage_info: #{storage_info}"
      puts "ENV storage backend: #{ENV["STORAGE_BACKEND"]}"
      if ENV["STORAGE_BACKEND"] == "database"
        blob = Blob.create!(
          uid: uid,
          size: blob_data.bytesize,
          created_at: Time.now.utc,
          storage_backend: ENV["STORAGE_BACKEND"],
          storage_identifier: uid
        )
      else
        puts "Creating blob for s3"
        blob = Blob.create!(
          uid: uid,
          size: blob_data.bytesize,
          created_at: Time.now.utc,
          storage_backend: ENV["STORAGE_BACKEND"],
          storage_identifier: storage_info[:id]
        )
      end


      puts("Blob created: #{blob.inspect}")


      if blob.save
        render json: { id: uid }, status: :created
      else
        render json: { errors: blob.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def show
      blob = Blob.find_by!(uid: params[:id])
      storage_service = StorageServiceFactory.build
      data = storage_service.retrieve(blob.storage_identifier)
      puts("Retrieved blob data: #{data.inspect}")
      render json: {
        id: blob.uid,
        data: Base64.strict_encode64(data.to_s),
        size: blob.size,
        created_at: blob.created_at.iso8601
      }, status: :ok
    end
  end
end
