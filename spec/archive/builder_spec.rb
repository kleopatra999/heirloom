require 'spec_helper'

describe Heirloom::Builder do
  before do
    @config_double   = double 'config'
    @logger_double   = double :debug => 'true', :info => 'true', :warn => 'true'
    @config_double.stub(:logger).and_return(@logger_double)
    @simpledb_double = double 'simple db'
    @builder         = Heirloom::Builder.new :config => @config_double,
                                           :name   => 'tim',
                                           :id     => '123'
  end

  describe 'build' do
    context 'when successful' do
      before do
          @author_double    = double :name => 'weaver'
          @directory_double = double :build_artifact_from_directory => '/tmp/build_dir',
                                     :local_build                   => '/var/tmp/file.tar.gz'

          Heirloom::Directory.should_receive(:new).
                              with(:path    => 'path_to_build',
                                   :exclude => ['.dir_to_exclude'],
                                   :file    => '/tmp/file.tar.gz',
                                   :config  => @config_double).
                              and_return @directory_double
          @builder.should_receive(:create_artifact_record)
      end

    end

    it "should return false if the build fails" do
      directory_double = double :build_artifact_from_directory => false
      Heirloom::Directory.should_receive(:new).with(:path    => 'path_to_build',
                                                    :exclude => ['.dir_to_exclude'],
                                                    :file    => '/tmp/file.tar.gz',
                                                    :config  => @config_double).
                                               and_return directory_double
      @builder.build(:exclude   => ['.dir_to_exclude'],
                     :directory => 'path_to_build',
                     :file      => '/tmp/file.tar.gz').should be_false
    end

  end

end
