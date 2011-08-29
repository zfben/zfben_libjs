if defined?(Rails)
  Lib_version = Time.now.strftime('?%s')
  module Rails::ActionView::Helpers::AssetTagHelper
    def lib *opts
      html = '<script src="/javascripts/lib.js' + Lib_version + '"></script>'
      unless opts.blank?
        html << "<script>lib('#{opts.join(' ')}')</script>"
      end
      return html
    end
  end
end
