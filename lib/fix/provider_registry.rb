class ProviderRegistry
  def self.provider_for(name)
    Logger.debug "Looking up class for #{name}"
    begin
      Kernel.const_get(name).new
    rescue StandardError => e
      Logger.error e
      nil
    end
  end
end