module Citizn
  class Identity
    attr_reader :identity

    def initialize(template)
      @template = template
    end

    def get_identity()
      raise "Citizn::Passport requires a root key in the Identity template" if @template.keys[0].blank?
      raise "Citizn::Passport, there can only be one root key" if @template.keys.length > 1
      @identity = get(@template.keys[0], false)
      sync_identity(@template,@identity)
      @identity = get(@template.keys[0], true)
    end

    private
    def get(key, convert = false, recurse = true)
      begin
        return Diplomat::Kv.get(key,{recurse: recurse, convert_to_hash: convert})
      rescue => e
        return (convert)? {}: []
      end
    end
    def create(key, value)
      Diplomat::Kv.put(key, value)
    end

    def sync_identity(template,identity)

      root = template.first
      plan = get_update_plan(root[0],root[1],identity)

      plan[:create].each do |key, value|
        create(key,value)
      end
    end

    def get_update_plan(parent,template,identity)
      template_arr = Citizn.convert_hash_to_array_of_hashes(parent,template)
      plan = {create:{}, delete:{}}

      # find all keys that do not exist in the identity
      template_arr.each do |item|
        found = identity.find{|i| i[:key] == item[:key]}
        unless found
          plan[:create][item[:key]] = item[:value]
        end
      end

      # find all keys that do not exist in the template
      indentity.each do |item|
        found = template_arr.find{|i| i[:key] == item[:key]}
        unless found
          plan[:delete][item[:key]] = item[:value]
        end
      end

      return plan
    end

  end
end
