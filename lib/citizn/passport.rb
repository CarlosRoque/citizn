module Citizn
  class Passport

    def initialize(template)
      @env = Citizn.env
      @template = template
      @identity = Citizn::Identity.new(@template)
      @cached_identity = nil
    end

    def get_identity
      @cached_identity ||= @identity.get_identity
      return @cached_identity
    end
    def update_identity_with_identity(hash)
      @identity.update_identity_with_identity(hash)
      @cached_identity = @identity.get_identity
      return @cached_identity
    end

  end
end
