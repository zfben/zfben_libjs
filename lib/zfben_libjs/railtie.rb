if defined?(Rails)
  module Zfben_libjs
    class Railtie < Rails::Railtie
      initializer 'zfben_libjs.helper' do
        ActionView::Base.send :include, Helpers
      end
    end
  end
end
