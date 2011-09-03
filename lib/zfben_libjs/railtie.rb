if defined?(Rails)
  module Rails
    module ActionView::Helpers::AssetTagHelper
      include Zfben_libjs::Helper
    end
  end
end
