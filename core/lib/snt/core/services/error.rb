class SNT::Core::Services::Error
  VALIDATION_ERROR = 'VALIDATION_ERROR'.freeze

  attr_accessor :code, :message

  def initialize(args)
    args.each { |key, value| instance_variable_set("@#{key}", value) }
  end

  def self.new_validation_error(obj)
    message =
      if obj.is_a?(Symbol)
        I18n.t(obj)
      elsif obj.is_a?(String)
        obj
      end

    logger.debug(message)
    new(code: VALIDATION_ERROR, message: message)
  end

  def to_hash
    { code: code, message: message }
  end
end
