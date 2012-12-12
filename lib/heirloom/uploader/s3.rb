module Heirloom
  class Uploader
    class S3

      def initialize(args)
        @config = args[:config]
        @region = args[:region]
        @logger = args[:logger]
      end

      def upload_file(args)
        bucket          = args[:bucket]
        file            = args[:file]
        id              = args[:id]
        key_name        = args[:key_name]
        key_folder      = args[:key_folder]
        name            = args[:name]
        public_readable = args[:public_readable]

        body      = File.open file
        s3_bucket = s3.get_bucket bucket

        @logger.info "Uploading s3://#{bucket}/#{key_folder}/#{key_name}"

        s3_bucket.files.create :key    => "#{key_folder}/#{key_name}",
                               :body   => body,
                               :public => public_readable
        if public_readable
          @logger.warn "File is readable by the public internet." 
        end
      end

      def add_endpoint_attributes(args)
        bucket     = args[:bucket]
        id         = args[:id]
        name       = args[:name]
        key_name   = args[:key_name]
        domain     = "heirloom_#{name}"
        key_folder = name
        endpoint   = endpoints[@region]

        path           = "#{bucket}/#{key_folder}/#{key_name}"
        s3_endpoint    = "s3://#{path}"
        http_endpoint  = "http://#{endpoint}/#{path}"
        https_endpoint = "https://#{endpoint}/#{path}"

        s3_url = "#{@region}-s3-url"
        sdb.put_attributes domain, id, { s3_url => s3_endpoint }
        @logger.info "Adding tag #{s3_url}."
        @logger.debug "Adding tag #{s3_endpoint}."

        http_url = "#{@region}-http-url"
        sdb.put_attributes domain, id, { http_url => http_endpoint }
        @logger.debug "Adding tag #{http_url}."
        @logger.debug "Adding tag #{http_endpoint}."

        https_url = "#{@region}-https-url"
        sdb.put_attributes domain, id, { "#{https_url}" => https_endpoint }
        @logger.debug "Adding tag #{https_url}."
        @logger.debug "Adding tag #{https_endpoint}."
      end

      private

      def endpoints
        {
          'us-east-1' => 's3.amazonaws.com',
          'us-west-1' => 's3-us-west-1.amazonaws.com',
          'us-west-2' => 's3-us-west-2.amazonaws.com'
        }
      end

      def s3
        @s3 ||= AWS::S3.new :config => @config,
                            :region => @region
      end

      def sdb
        @sdb ||= AWS::SimpleDB.new :config => @config
      end

    end
  end
end
