module Citizn
  class Identity
    attr_reader :identity

    def initialize(template)
      @template = template
    end

    def get_identity()
      raise "Citizn::Passport requires a root key in the Identity template" if @template.keys[0].blank?
      raise "Citizn::Passport, there can only be one root key" if @template.keys.length > 1
      @identity = get(@template.keys[0],true)
      sync_identity(@template,@identity)
    end

    private
    def get(key, recurse = false)
      return Diplomat::Kv.get(key,{recurse: recurse})
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
      template_arr = convert_template_to_array(parent,template)
      plan = {leave:{}, create:{}, delete:{}}

      template_arr.each do |item|
        found = identity.find{|i| i.keys[0] == item.keys[0]}
        if found
          plan[:leave][item.keys[0]] = found
        else
          plan[:create][item.keys[0]] = item
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

    def convert_template_to_array(parent,hash)
      array = []
      hash.each do |key, value|
        if value.class == Hash
          array.concat convert_template_to_array("#{parent}/#{key}",value)
        else
          array << {"#{parent}/#{key}" => value.to_s}
        end
      end
      return array
    end

  end
end
