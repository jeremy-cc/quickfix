require 'rubygems'
require 'java'

require '/Users/jeremyb/java/org.quickfixj-1.6.0/quickfixj-core-1.6.0.jar'
require '/Users/jeremyb/java/org.quickfixj-1.6.0/quickfixj-messages-fix42-1.6.0.jar'
require '/Users/jeremyb/java/org.quickfixj-1.6.0/quickfixj-messages-fix43-1.6.0.jar'
require '/Users/jeremyb/java/org.quickfixj-1.6.0/quickfixj-messages-fix44-1.6.0.jar'

require '/Users/jeremyb/java/org.quickfixj-1.6.0/lib/slf4j-api-1.7.12.jar'
require '/Users/jeremyb/java/slf4j-1.6.3/slf4j-log4j12-1.6.3.jar'
require '/Users/jeremyb/java/apache-log4j-1.2.17/log4j-1.2.17.jar'
require '/Users/jeremyb/java/org.quickfixj-1.6.0/lib/mina-core-2.0.9.jar'

require 'lib/fix/providers/barclays'

$CLASSPATH << "/Users/jeremyb/development/quickfix/config"

class MessageCracker <  Java::Quickfix::MessageCracker
  include  Java::Quickfix::Application

  def fromAdmin(message, session_id)
    puts "from_admin message=#{message}, session_id=#{session_id}"
  end

  def fromApp(message, session_id)
    # puts "from_app message=#{message}, session_id=#{session_id}"
    crack(message, session_id);
  end

  def onCreate(session_id)
    puts "on_create session_id=#{session_id}"
  end

  def onLogon(session_id)
    puts "on_logon session_id=#{session_id}"
  end

  def onLogout(session_id)
    puts "on_logout session_id=#{session_id}"
  end

  def toAdmin(message, session_id)
    if message.getHeader().getString(Fix::Fields::MsgType::FIELD) == Fix::Fields::MsgType::LOGON
      begin
        message.setString(Fix::Fields::Username::FIELD, 'SW-FXCAPITALtest')
      rescue StandardError => e
        puts e.message
      end
      puts "LOGON MESSAGE BEING SENT"
    end
    puts "to_admin message=#{message}, session_id=#{session_id}"
  end

  def toApp(message, session_id)
    puts "to_app message=#{message}, session_id=#{session_id}"
  end

  def onMessage(message, session_id)
    puts "on_message message=#{message}, session_id=#{session_id}"

    case message.getHeader().getString(Fix::Fields::MsgType::FIELD)
      when Fix::Fields::MsgType::EXECUTION_REPORT
        puts "Execution Report response from remote provider"
        puts "Executed rate: %s " % message.get_last_px.value
        puts "Settles on   : %s" % message.get_fut_sett_date.value
        puts "Purchased amt: %s" % message.get_field(6054).value
      else
        puts "Unhandled message type"
    end
  end
end

def test_connection
  puts "Started at " + Time.now.to_s
  # quickfix.SocketInitiator.new
  session_settings = Fix::SessionSettings.new("/Users/jeremyb/development/quickfix/config/#{$ARGV[1]}")

  app = MessageCracker.new

  fsf = Fix::FileStoreFactory.new(session_settings)
  flf = Fix::FileLogFactory.new(session_settings)

  message_factory = Fix::DefaultMessageFactory.new

  socket_initiator = Fix::SocketInitiator.new(app, fsf, session_settings, flf, message_factory)
  socket_initiator.start
  session_id = socket_initiator.get_sessions.get(0);

  counter = 0
  while !socket_initiator.isLoggedOn && counter < 300
      sleep(0.5)
  end

  # if socket_initiator.isLoggedOn
    # Barclays.new.executeOrder(session_settings, Fix::Session.lookup_session(session_id), "TCCO-#{Time.now.to_i}", 1, "GBP/USD", "USD", 10000.0, "SP")   # requestPrice(sessionSettings, Session.lookupSession(sessionId), new String[] {"GBP/USD" });
  # else
  #   puts "Unable to send message"
  # end

  sleep(300)

  puts "Calling shutdown hook"
  unless socket_initiator.nil?
    socket_initiator.stop
  end

  puts "Closed, exiting"
end

test_connection

puts "Stopped at " + Time.now.to_s