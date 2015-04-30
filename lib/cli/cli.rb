require 'optparse'

module QuickFix
  module CLI
    extend self

    DEFAULT_CONFIG_FILE = File.expand_path '../../config/config.ini', File.dirname(__FILE__)

    def parse args=ARGV
      opts = parse_options args

      @config_file = opts[:config_file]

      setup_logger
    end

    def run
      FixConnection.new(@config_file).test
    end

    private

    def handle_signals
      %w(TERM INT).each do |signal|
        Signal.trap(signal) do
          Logger.warn 'Killed. Disconnecting. Please, wait...'

          yield

          Logger.info 'QuickFix shut down successfully', :green
          Kernel.exit! 0
        end
      end
    end

    def parse_options(argv)
      opts = {}

      parser = OptionParser.new do |o|
        o.on('-f', '--file CONFIG_FILE', 'Configuration file to load') do |arg|
          opts[:config_file] = arg
        end
      end

      parser.parse! argv
      opts
    end

    def setup_logger
      Logger.verbose!
    end
  end
end
