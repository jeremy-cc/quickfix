class FixConnection
  attr_reader :config_file, :listener

  attr_reader :session_settings, :socket_initiator, :session_id

  def initialize(config, listener=nil)
    @config_file = config
    @listener ||= listener
  end

  def connect
    @session_settings = Fix::SessionSettings.new("/Users/jeremyb/development/quickfix/config/#{config_file}")

    @app = FixHandler.new(session_settings)
    @app.register_listener(listener)

    @fsf = Fix::FileStoreFactory.new(session_settings)
    @flf = Fix::FileLogFactory.new(session_settings)

    @message_factory = Fix::DefaultMessageFactory.new

    @socket_initiator = Fix::SocketInitiator.new(@app, @fsf, session_settings, @flf, @message_factory)
    socket_initiator.start
    @session_id = socket_initiator.get_sessions.get(0);

    counter = 0
    while !socket_initiator.isLoggedOn && counter < 300
      sleep(0.5)
    end
    Logger.info "Checking for login : #{socket_initiator.isLoggedOn}"
  end

  def shutdown
    Logger.warn "Calling shutdown hook"
    unless socket_initiator.nil?
      socket_initiator.stop
    end

    Logger.debug "Closed, exiting at " + Time.now.to_s
  end

  def executeOrder(provider, reference, side, pair, ccy, amount, settlement_date)
    ProviderRegistry.provider_for(provider).executeOrder(session_settings, session, reference, side, pair, ccy, amount, settlement_date)
  end

  def requestQuote(provider, reference, pairs, amount)
    ProviderRegistry.provider_for(provider).requestPrice(session_settings, session, reference, pairs, amount)
  end

  def session
    Fix::Session.lookup_session(session_id)
  end

  def test
    Logger.debug "Started at " + Time.now.to_s

    if socket_initiator.isLoggedOn
      requestQuote(:Barclays, "TCCQ-#{Time.now.to_i}", ["GBP/USD"], 10000.0)
      executeOrder(:Barclays, "TCCO-#{Time.now.to_i}", 1, "GBP/USD", "USD", 10000.0, "SP")
    else
      Logger.debug "Unable to send message"
    end

    sleep(300)
  end
end
