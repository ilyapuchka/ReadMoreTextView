Pod::Spec.new do |s|

  s.name         = "ReadMoreTextView"
  s.version      = "0.0.1"
  s.summary      = 'UITextView subclass with "Read more" behavior.'

  s.description  = <<-DESC
			UITextView subclass with "Read more" behavior.
			
			* Set trim text as an NSString or NSAttributedString
			* Set maximum number of lines to display
			* Turn trim on/off
			* Live updates in Interface Builder 
                   DESC

  s.homepage     = "http://ilya.puchka.me/custom-uitextview-in-swift/"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "Ilya Puchka" => "ilya@puchka.me" }
  s.social_media_url   = "http://twitter.com/ilyapuchka"

  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/ilyapuchka/ReadMoreTextView.git", :tag => s.version }

  s.source_files  = "ReadMoreTextView.swift"

end
