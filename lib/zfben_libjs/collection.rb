class Zfben_libjs::Collection
  attr_accessor :css, :js, :image, :merge_css, :merge_js
  
  def initialize sources, libs
    sources = [sources] unless sources.class.to_s != 'Array'
    
    @css = []
    @js = []
    @image = []
    
    process_sources sources.flatten.uniq.compact, libs
  end
  
  def merge!
    merge_css = ''
    @css.each do |css|
      merge_css << css.to_css
    end
    @merge_css = merge_css
    
    merge_js = ''
    @js.each do |js|
      merge_js << js.to_js
    end
    @merge_js = merge_js
    
    return {
      :merge_css => @merge_css,
      :merge_js => @merge_js
    }
  end
  
  private
  
  def process_sources sources, libs
    sources.each do |source|
      if source.class.to_s == 'String'
        process_sources libs[source], libs
      elsif source.respond_to?(:to_css)
        @css.push source
      elsif source.respond_to?(:to_js)
        @js.push source
      else
        @image.push source
      end
    end
  end
end
