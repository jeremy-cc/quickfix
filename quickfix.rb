require 'rubygems'
require 'java'

require 'newfix'

require 'lib/java/quickfixj-core-1.6.0.jar'
require 'lib/java/quickfixj-messages-fix42-1.6.0.jar'
require 'lib/java/quickfixj-messages-fix43-1.6.0.jar'
require 'lib/java/quickfixj-messages-fix44-1.6.0.jar'

require 'lib/java/slf4j-api-1.7.12.jar'
require 'lib/java/slf4j-log4j12-1.7.12.jar'
require 'lib/java/log4j-1.2.17.jar'
require 'lib/java/mina-core-2.0.9.jar'

require 'lib/logger'
require 'lib/app/cli'
require 'lib/fix/fix'
require 'lib/fix/fix_handler'
require 'lib/fix/provider_registry'
require 'lib/connection/fix_connection'

require 'lib/fix/providers/barclays'

$CLASSPATH << File.expand_path('config', File.dirname(__FILE__))

begin
  QuickFix::CLI.parse
  QuickFix::CLI.test
rescue => e
  raise e if $DEBUG
  STDERR.puts e.message
  STDERR.puts e.backtrace.join "\n"
  exit 1
end