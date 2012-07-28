module Heirloom
  class Config

    attr_accessor :access_key, :secret_key, :logger

    def initialize(args = {})
      @config = args[:config]
      self.logger = args[:logger] ||= HeirloomLogger.new
      load_config_file
    end

    def load_config_file
      config_file = "#{ENV['HOME']}/.heirloom.yml"
      c = @config ? @config : YAML::load( File.open( config_file ) )

      aws = c['aws']

      self.access_key = aws['access_key']
      self.secret_key = aws['secret_key']
    end

  end
end
