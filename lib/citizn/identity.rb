module Citizn
  class Identity
    attr_reader :identity

    def initialize(template)
      @template = template
    end

    def get_identity()
      raise "Citizn::Passport requires a root key in the Identity template" if @template.keys[0].blank?
      raise "Citizn::Passport, there can only be one root key" if @template.keys.length > 1
      @identity = get(@template.keys[0], true, false)
      sync_identity(@template,@identity)
    end

    private
    def get(key, recurse = false, convert = false)
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

      # puts plan.inspect
      plan[:create].each do |key, value|
        create(key,value)
      end
    end

    def get_update_plan(parent,template,identity)
      template_arr = Citizn.convert_hash_to_array_of_hashes(parent,template)
      plan = {leave:{}, create:{}, delete:{}}

      template_arr.each do |item|
        item_arr = item.first
        found = identity.find{|i| i.keys[0] == item_arr[0]}
        if found
          plan[:leave][item_arr[0]] = found
        else
          plan[:create][item_arr[0]] = item_arr[1]
        end
      end

      # # find delete
      # identity.each do |key,value|
      #   if template[:key].blank?
      #     plan[:delete]["#{parent}/#{key}"] = value
      #   end
      # end
      return plan
    end

  end
end
