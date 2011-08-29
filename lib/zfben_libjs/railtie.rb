if defined?(Rails)
  Lib_version = Time.now.strftime('?%s')
  module Rails
    module ActionView::Helpers::AssetTagHelper
      def lib *opts
        html = lib_js('lib.js')
        unless opts.blank?
          preload = []
          lib_preload = []
          opts.each do |name|
            name = name.to_s
            if name.end_with?('.css') || name.end_with?('.js')
              preload.push name
            else
              lib_preload.push name
            end
          end
          if preload.length > 0
            preload.each do |url|
              if url.end_with?('.css')
                html << lib_css(url)
              else
                html << lib_js(url)
              end
            end
          end
          if lib_preload.length > 0
            html << "<script>lib('#{lib_preload.join(' ')}')</script>"
          end
        end
        return html
      end

      def lib_js url
        return "<script src='/javascripts/#{url}#{Lib_version}'></script>"
      end

      def lib_css url
        return "<link rel='stylesheet' href='/stylesheets/#{url}#{Lib_version}' />"
      end
    end
  end
end
