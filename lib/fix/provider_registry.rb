class ProviderRegistry
  def self.provider_for(name)
    Logger.debug "Looking up class for #{name}"
    begin
      Kernel.const_get(name.to_s).new
    rescue StandardError => e
      Logger.error e
      nil
    end
  end
end