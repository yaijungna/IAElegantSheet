Pod::Spec.new do |s|
  s.name         = "IAElegantSheet"
  s.version      = "0.1.0"
  s.summary      = "Another block based UIActionSheet but more elegant. Elegant to code and elegant to see."
  s.description  = "Block based UIActionSheet but more elegant. Using Roboto Condensed as default font. Support multiple orientation"
  s.homepage     = "http://ikhsan.me"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Ikhsan Assaat" => "ikhsan.assaat@gmail.com" }
  s.source       = { :git => "https://github.com/ixnixnixn/IAElegantSheet", :tag => s.version.to_s }
  s.platform     = :ios, '6.0'
  s.source_files = 'IAElegantSheet/*.{h,m}'
  s.resources    = 'IAElegantSheet/IAElegantSheet.bundle'
  s.requires_arc = true
  
  s.post_install do |library_representation|
    require 'rexml/document'

    lib = library_representation.library    
    proj = Xcodeproj::Project.new(lib.user_project_path)
    target = proj.targets.first # good guess for simple projects

    info_plists = target.build_configurations.inject([]) do |memo, item|
      memo << item.build_settings['INFOPLIST_FILE']
    end.uniq
    info_plists = info_plists.map { |plist| File.join(File.dirname(proj_path), plist) }

    # resources = lib.file_accessors.collect(&:resources).flatten
    # fonts = resources.find_all { |file| File.extname(file) == '.otf' || File.extname(file) == '.ttf' }
    # fonts = fonts.map { |f| File.basename(f) }
    
    fonts = ['RobotoCondensed-Bold.ttf', 'RobotoCondensed-Light.ttf', 'RobotoCondensed-Regular.ttf']

    info_plists.each do |plist|
      doc = REXML::Document.new(File.open(plist))
      main_dict = doc.elements["plist"].elements["dict"]
      app_fonts = main_dict.get_elements("key[text()='UIAppFonts']").first
      if app_fonts.nil?
        elem = REXML::Element.new 'key'
        elem.text = 'UIAppFonts'
        main_dict.add_element(elem)
        font_array = REXML::Element.new 'array'
        main_dict.add_element(font_array)
      else
        font_array = app_fonts.next_element
      end

      fonts.each do |font|
        if font_array.get_elements("string[text()='#{font}']").empty?
          font_elem = REXML::Element.new 'string'
          font_elem.text = font
          font_array.add_element(font_elem)
        end
      end

      doc.write(File.open(plist, 'wb'))
    end
  end
  
end
