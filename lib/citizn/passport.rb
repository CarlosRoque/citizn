module Citizn
  class Passport

    attr_accessor :cached_identity

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
    def update_identity
      @identity.update_identity_with(@cached_identity)
      @cached_identity = @identity.get_identity
      return @cached_identity
    end

  end
end
