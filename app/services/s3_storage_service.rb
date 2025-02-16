require "net/http"
require "uri"
require "openssl"
require "base64"
require "faraday"
require "faraday_middleware/aws_sigv4"

class S3StorageService
  def initialize(config)
    @logger = Logger.new(STDOUT)
    @logger.level = :debug
    config = config.transform_values(&:to_s)
    @bucket_name = config[:bucket_name]
    @region = config[:region]
    @access_key_id = config[:access_key_id]
    @secret_access_key = config[:secret_access_key]
    @logger.debug("S3StorageService initialized with region: #{@region}")
    @logger.debug("Region type: #{@region.class}")
  end
  # app/services/s3_storage_service.rb
  def store(id, data)
  # 1. Generate AWS SigV4 headers manually
  headers = generate_aws_sigv4_headers(
    method: :put,
    region: @region,
    bucket: @bucket_name,
    key: id,
    data: data
  )

  # 2. Use Faraday to send the request WITHOUT middleware
  uri = URI("https://#{@bucket_name}.s3.#{@region}.amazonaws.com/#{id}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Put.new(uri.request_uri, headers)
  request.body = data
  response = http.request(request)


  # response = conn.put("/#{id}") do |req|
  #   req.headers = headers
  #   req.body = data
  # end
  if response.code == "200"
          {
            id: id,
            data: data,
            size: data.size.to_s,
            created_at: Time.now.utc.iso8601
          }
  else
          raise "Failed to store blob: #{response.status} - #{response.body}"
  end
  rescue => e
      @logger.error("Error in S3StorageService(store): #{e.message}")
      raise "Failed to store blob due to error: #{e.message}"
  end


  def generate_aws_sigv4_headers(method:, region:, bucket:, key:, data:)
    uri = "host:#{bucket}.s3.#{region}.amazonaws.com"
    datetime = Time.now.utc.strftime("%Y%m%dT%H%M%SZ")
    date = datetime[0, 8]
    canonical_request = [
      method.to_s.upcase,
      "/#{key}",
      "",
      uri,
      "x-amz-content-sha256:#{Digest::SHA256.hexdigest(data)}",
      "x-amz-date:#{datetime}",
      "",
      "host;x-amz-content-sha256;x-amz-date",
      Digest::SHA256.hexdigest(data)
    ].join("\n")

    credential_scope = "#{date}/#{region}/s3/aws4_request"
    string_to_sign = [
      "AWS4-HMAC-SHA256",
      datetime,
      credential_scope,
      Digest::SHA256.hexdigest(canonical_request)
    ].join("\n")

    signing_key = get_signing_key(@secret_access_key, date, region, "s3")
    signature = OpenSSL::HMAC.hexdigest("SHA256", signing_key, string_to_sign)

    {
      "Authorization" => "AWS4-HMAC-SHA256 Credential=#{@access_key_id}/#{credential_scope}, SignedHeaders=host;x-amz-content-sha256;x-amz-date, Signature=#{signature}",
      "x-amz-date" => datetime,
      "x-amz-content-sha256" => Digest::SHA256.hexdigest(data)
    }
  end

  def get_signing_key(secret_access_key, date, region, service)
    k_date = OpenSSL::HMAC.digest("SHA256", "AWS4" + secret_access_key, date)
    k_region = OpenSSL::HMAC.digest("SHA256", k_date, region)
    k_service = OpenSSL::HMAC.digest("SHA256", k_region, service)
    OpenSSL::HMAC.digest("SHA256", k_service, "aws4_request")
  end


  def retrieve(id)
    @logger.debug("Retrieving blob from S3 with id: #{id}")
    begin
      # Generate AWS SigV4 headers manually
      headers = generate_aws_sigv4_headers(
        method: :get,
        region: @region,
        bucket: @bucket_name,
        key: id,
        data: ""
      )

      # Use Net::HTTP to send the request WITHOUT middleware
      uri = URI("https://#{@bucket_name}.s3.#{@region}.amazonaws.com/#{id}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(uri.request_uri, headers)
      response = http.request(request)

      if response.code == "200"
        {
          id: id,
          data: response.body,
          size: response["Content-Length"],
          created_at: Time.now.utc.iso8601
        }
      else
        raise "Failed to retrieve blob: #{response.code} - #{response.body}"
      end
    rescue => e
      @logger.error("Error in S3StorageService(retrieve): #{e.message}")
      raise "Failed to retrieve blob due to error: #{e.message}"
    end
  end

  def self.create_bucket(bucket_name, region, access_key_id, secret_access_key)
    # Implementation for creating the bucket in S3 if it doesn't exist
    # Make sure to handle AWS Signature Version 4 authentication
  end
end
