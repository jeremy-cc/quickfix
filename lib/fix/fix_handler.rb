class FixHandler <  Java::Quickfix::MessageCracker
  include  Java::Quickfix::Application

  attr_reader :session_settings, :provider

  def initialize(session_settings)
    @session_settings = session_settings
  end

  def fromAdmin(message, session_id)
    Logger.debug "from_admin message=#{message}, session_id=#{session_id}"
  end

  def fromApp(message, session_id)
    crack(message, session_id);
  end

  def onCreate(session_id)
    Logger.debug "on_create session_id=#{session_id}"
  end

  def onLogon(session_id)
    Logger.debug "on_logon session_id=#{session_id}"
  end

  def onLogout(session_id)
    Logger.debug "on_logout session_id=#{session_id}"
  end

  def toAdmin(message, session_id)
    if message.getHeader().getString(Fix::Fields::MsgType::FIELD) == Fix::Fields::MsgType::LOGON
      begin
        session_settings.getString(session_id, "Password")

        password = session_settings.getString(session_id, "Password") rescue nil
        unless password.nil?
          if session_settings.getString(session_id, "FixVersion") == '4.2'
            message.setString(Fix::Fields::RawDataLength::FIELD, password.to_java_bytes.length.to_s)
            message.setString(Fix::Fields::RawData::FIELD, password)
          else
            message.setString(Fix::Fields::Password::FIELD, password)
          end
        end
      rescue StandardError => e
        Logger.error e
      end
    end
    Logger.debug "to_admin message=#{message}, session_id=#{session_id}"
  end

  def toApp(message, session_id)
    Logger.debug "to_app message=#{message}, session_id=#{session_id}"
  end

  def onMessage(message, session_id)
    Logger.debug "on_message message=#{message}, session_id=#{session_id}"

    case message.getHeader.getString(Fix::Fields::MsgType::FIELD)
      when Fix::Fields::MsgType::EXECUTION_REPORT
        begin
          Logger.debug "Trying to dispatch to provider"
          parsed_response = ProviderRegistry.provider_for(session_settings.getString(session_id, "Provider")).handleExecutionReport(message)

          Logger.info parsed_response.inspect
        rescue StandardError => e
          Logger.error e
        end
      else
        Logger.debug "Unhandled message type"
    end
  end

  def sessionFixVersion
    sessionSettings.getString(session.getSessionID, "SenderCompID")
  end
end