module Representable
  # TODO: make sure we can still have polymorphic representers with :extend/:prepare.
  module Cached
    # The main point here is that the decorator instance simply saves its mapper. Since the mapper
    # in turn stores the bindings, we have a straight-forward way of "caching" the bindings without
    # having to mess around on the class level: this all happens in the decorator _instance_.
    #
    # Every binding in turn stores its nested representer (if it has one), implementing a recursive caching.
    #
    # Decorator -> Mapper -> [Binding->Decorator, Binding]
    def representable_mapper(*)
      @mapper ||= super.tap do |mapper|
        mapper.bindings.each { |binding| binding.extend(Binding) }
      end
    end

    # replace represented for each property in this representer.
    # DISCUSS: not sure if we need to replace self and user_options.
    def update!(represented, user_options)
      representable_mapper.bindings.each do |binding|
        binding.update!(represented, self, user_options)
        # binding.instance_variable_set(:@represented, represented)
        # binding.instance_variable_set(:@exec_context, represented)
      end
    end

    # TODO: also for deserializer.
    # TODO: create Populator in Binding, too (easier to override).
    module Binding
      def serializer
        @__serializer ||= super.tap do |serializer|
          puts "extendin"
          serializer.extend(Serializer)
        end
      end

      attr_accessor :cached_representer # keeps the representer used for this property.
    end

    module Serializer
      def prepare_for(mod, object)
        if representer = @binding.cached_representer
          representer.update!(object, @binding.user_options) # FIXME: @binding.user_options is wrong, it's the old options in case this class gets cached.
          return representer
        end

        @binding.cached_representer = super(mod, object)
      end
    end
  end
end