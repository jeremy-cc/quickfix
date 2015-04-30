class FixConnection
  attr_reader :config_file

  def initialize(config)
    @config_file = config
  end

  def test
    Logger.debug "Started at " + Time.now.to_s
    # quickfix.SocketInitiator.new
    session_settings = Fix::SessionSettings.new("/Users/jeremyb/development/quickfix/config/#{config_file}")

    app = FixHandler.new(session_settings)

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

    if socket_initiator.isLoggedOn
      Barclays.new.executeOrder(session_settings, Fix::Session.lookup_session(session_id), "TCCO-#{Time.now.to_i}", 1, "GBP/USD", "USD", 10000.0, "SP")   # requestPrice(sessionSettings, Session.lookupSession(sessionId), new String[] {"GBP/USD" });
    else
      Logger.debug "Unable to send message"
    end

    sleep(300)

    Logger.warn "Calling shutdown hook"
    unless socket_initiator.nil?
      socket_initiator.stop
    end

    Logger.debug "Closed, exiting at " + Time.now.to_s
  end
end
