module Heirloom

  class ArtifactDownloader

    def initialize(args)
      @config = args[:config]
      @logger = args[:logger]
    end

    def download(args)
      @id = args[:id]
      @name = args[:name]
      @output = args[:output]
      @region = args[:region]

      s3_downloader = Downloader::S3.new :config => @config,
                                         :logger => @logger,
                                         :region => @region

      bucket = artifact_reader.get_bucket :region => @region,
                                          :name   => @name,
                                          :id     => @id

      key = artifact_reader.get_key :region => @region,
                                    :name   => @name,
                                    :id     => @id

      @logger.info "Downloading s3://#{bucket}/#{key} from #{@region}."

      file = s3_downloader.download_file :bucket => bucket,
                                         :key    => key

      @logger.info "Writing file to #{@output}."

      File.open(@output, 'w') do |local_file|
        local_file.write file
      end
    end

    private

    def get_bucket
      artifact = artifact_reader.show :name => @name,
                                      :id   => @id

      url = artifact["#{@region}-s3-url"].first

      bucket = url.gsub('s3://', '').split('/').first
    end

    def get_key
      artifact = artifact_reader.show :name => @name,
                                      :id   => @id

      url = artifact["#{@region}-s3-url"].first

      bucket = url.gsub('s3://', '').gsub(get_bucket, '')
      bucket.slice!(0)
      bucket
    end

    def artifact_reader
      @artifact_reader ||= ArtifactReader.new :config => @config
    end

  end
end
