module Detonator
  module ActiveModelCompliance
    # Active Model related methods
    def to_model
      self
    end

    # NOTE: Not sure if this is needed with the latest release (beta2)
    def new_record?
      @new_record ||= false
    end

    # NOTE: Not sure if this is needed with the latest release (beta2)
    def destroyed?
      @destroyed ||= false
    end

    # NOTE: Required by beta 2
    def persisted?
      !new_record?
    end

    # NOTE: Required by beta 2
    def to_key
      persisted? ? id.to_s : nil
    end

    def to_param
      id.to_s
    end
  end
end
