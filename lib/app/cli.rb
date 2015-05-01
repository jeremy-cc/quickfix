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

    class MockListener
      def handleExecutionReport(msg)
        Logger.warn "Handling Execution Report: #{msg.inspect}"
      end

      def handleQuote(msg)
        Logger.warn "Handling Quote: #{msg.inspect}"
      end
    end

    def test
      Logger.info "Connecting"
      run
      Logger.info "Testing"
      @conn.test
      Logger.info "Shutting down"
      shutdown
    end

    def run
      @conn = FixConnection.new(@config_file, MockListener.new)
      @conn.connect
    end

    def shutdown
      @conn.shutdown
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
