module Zfben_libjs::Helpers
  Lib_version = Time.now.strftime('?%s')
  def lib *opts
    html = ''
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

      html << lib_js('lib.js')

      if lib_preload.length > 0
        html << "<script>lib('#{lib_preload.join(' ')}')</script>"
      end
    end
    return html
  end

  def lib_js url
    return "<script src='#{asset_host}/javascripts/#{url}#{Lib_version}'></script>"
  end

  def lib_css url
    return "<link rel='stylesheet' href='#{asset_host}/stylesheets/#{url}#{Lib_version}' />"
  end

  def asset_host
    if defined? Rails
      if Rails.configuration.action_controller.has_key? :asset_host && !Rails.configuration.action_controller[:asset_host].nil?
        return Rails.configuration.action_controller[:asset_host] + (request.port == 80 ? '' : (':' << request.port.to_s))
      end
    end
    ''
  end
end
