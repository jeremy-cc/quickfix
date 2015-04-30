require File.join(File.dirname(__FILE__), '..', 'fix')

class Barclays

  def requestPrice(sessionSettings, session, pairs)

    pairs.each do |pair|
      message = Fix::Fix42::QuoteRequest.new

      message.setField(Fix::Fields::SenderCompID::FIELD, Fix::Fields::SenderCompID.new(sessionSettings.getString(session.getSessionID, "SenderCompID")))
      message.setField(Fix::Fields::TargetCompID::FIELD, Fix::Fields::TargetCompID.new(sessionSettings.getString(session.getSessionID, "TargetCompID")))

      message.setField(Fix::Fields::OrdType::FIELD, Fix::Fields::OrdType.new(67)) # 'C'
      message.setField(Fix::Fields::SecurityType::FIELD, Fix::Fields::SecurityType.new("FOR"))
      message.set(Fix::Fields::QuoteReqID.new("TCC-" + Time.now.to_i.to_s))

      message.setField(Fix::Fields::NoRelatedSym::FIELD, Fix::Fields::NoRelatedSym.new(1))
      message.setField(Fix::Fields::Symbol::FIELD, Fix::Fields::Symbol.new(pair))
      message.setField(Fix::Fields::Currency::FIELD, Fix::Fields::Currency.new(pair[4..6]))
      message.setField(Fix::Fields::OrderQty::FIELD, Fix::Fields::OrderQty.new(10000.0))
      message.setField(Fix::Fields::FutSettDate::FIELD, Fix::Fields::FutSettDate.new("SP"))

      Logger.debug "SESSION %s: Sending %s" % [session.getSessionID(), message.to_s]
      unless Fix::Session.sendToTarget(message, session.getSessionID())
          Logger.debug  "Message delivery failed"
      end
    end
  end

  def executeOrder(sessionSettings, session, reference, side, pair, ccy, amount, deliveryDate)

    message = Fix::Fix42::NewOrderSingle.new()

    message.setField(Fix::Fields::SenderCompID::FIELD, Fix::Fields::SenderCompID.new(sessionSettings.getString(session.getSessionID, "SenderCompID")))
    message.setField(Fix::Fields::TargetCompID::FIELD, Fix::Fields::TargetCompID.new(sessionSettings.getString(session.getSessionID, "TargetCompID")))

    message.setField(Fix::Fields::OrdType::FIELD, Fix::Fields::OrdType.new(67)) # 'C'
    message.setField(Fix::Fields::SecurityType::FIELD, Fix::Fields::SecurityType.new("FOR"))
    message.setField(Fix::Fields::HandlInst::FIELD, Fix::Fields::HandlInst.new(50)) # '2'
    message.set(Fix::Fields::ClOrdID.new(reference))

    message.setField(Fix::Fields::Symbol::FIELD, Fix::Fields::Symbol.new(pair))
    message.setField(Fix::Fields::Currency::FIELD,  Fix::Fields::Currency.new(ccy))
    message.set(Fix::Fields::Side.new(side == 1 ? 49 : 50)) # 1 or 2
    message.set(Fix::Fields::OrderQty.new(amount))
    message.set(Fix::Fields::FutSettDate.new(deliveryDate))

    Logger.debug "SESSION %s: Sending %s" % [session.getSessionID(), message.to_s]
    unless Fix::Session.sendToTarget(message, session.getSessionID())
        Logger.debug  "Message delivery failed"
    end
  end

  def handleExecutionReport(message)
    begin
      FIX::Message.from_fix(message.to_s).to_hash
    rescue StandardError => e
      Logger.error e
      nil
    end
  end
end