require 'detonator/key'
module Detonator
  class EmbeddedModel
    include Key
    include ActiveModelCompliance
  end
end
