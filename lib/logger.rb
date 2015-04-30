require 'colorize'

class Logger
  @@verbose = false

  def self.verbose!
    info "Setting verbose logging on"
    @@verbose = true
  end

  def self.taciturn!
    info "Setting verbose logging off"
    @@verbose = false
  end

  def self.verbose?
    @@verbose
  end

  def self.info(msg, color=nil)
    log $stdout, "INFO  #{in_color msg, color}\n"
  end

  def self.warn(msg)
    log $stdout, "WARN  #{in_color msg, :yellow}\n"
  end

  def self.debug(msg, color=nil)
    log $stdout, "DEBUG #{in_color msg, color}\n"
  end

  def self.verbose(msg)
    if verbose?
      log $stdout, "VERBOSE #{in_color msg, :light_blue}\n"
    end
  end

  def self.error(e)
    if e.is_a?(Exception)
      log $stderr, "ERROR #{in_color e.message, :red}\n"
      log $stderr, e.backtrace.join("\n")
    else

    end
  end

  private

  def self.in_color(msg, color)
    color.nil? ? msg : msg.colorize(color)
  end

  def self.log(stream, msg)
    stream << "#{Time.now.strftime('%Y%m%d %H:%M:%S')} #{msg}"
  end
end