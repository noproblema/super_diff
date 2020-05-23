module SuperDiff
  module ColorizedDocumentExtensions
    def self.extended(extendee)
      extendee.singleton_class.class_eval do
        alias_method :normal, :text
      end
    end

    def alpha(*args, **opts, &block)
      colorize(*args, **opts, fg: SuperDiff::COLORS.fetch(:alpha), &block)
    end

    def beta(*args, **opts, &block)
      colorize(*args, **opts, fg: SuperDiff::COLORS.fetch(:beta), &block)
    end

    def gamma(*args, **opts, &block)
      colorize(*args, **opts, fg: SuperDiff::COLORS.fetch(:gamma), &block)
    end

    def border(*args, **opts, &block)
      colorize(*args, **opts, fg: SuperDiff::COLORS.fetch(:border), &block)
    end
  end
end
