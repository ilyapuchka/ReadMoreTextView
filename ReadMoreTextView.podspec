Pod::Spec.new do |s|

  s.name         = "ReadMoreTextView"
  s.version      = "3.0.1"
  s.summary      = 'UITextView subclass with "read more"/"read less" capabilities and UITextView extensions to handle touches in characters range.'

  s.description  = <<-DESC
			UITextView subclass with "Read more" behavior.
			UITextView extensions to handle touches in characters range. 
			
			* Set "read more"/"read less" text as a String or NSAttributedString
			* Set maximum number of lines to display
			* Turn trim on/off
			* Live updates and setup in Interface Builder
			* Use UITextView extension methods to detect touches in arbitrary text ranges.
                   DESC

  s.homepage     = "http://ilya.puchka.me/custom-uitextview-in-swift/"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "Ilya Puchka" => "ilya@puchka.me" }
  s.social_media_url   = "http://twitter.com/ilyapuchka"

  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/ilyapuchka/ReadMoreTextView.git", :tag => s.version }

  s.source_files  = "Sources/*.swift"

end
