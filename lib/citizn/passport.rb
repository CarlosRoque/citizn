module Citizn
  class Passport

    def initialize(template)
      @env = Citizn.env
      @template = template
      @identity = Citizn::Identity.new(@template)
      @cached_identity = {}
    end

    def get_identity
      @cached_identity ||= @identity.get_identity
      return @cached_identity
    end


  end
end
