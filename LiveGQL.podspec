Pod::Spec.new do |s|
 s.name         = "LiveGQL"
  s.version      = "0.0.1"
  s.summary      = "Implementation of GraphQL Subscription Websocket in Swift"
  s.description  = <<-DESC
                    Simple implementation in Swift of the PROTOCOL to communicate with a GraphQL Apollo WS server.
                   DESC

  s.homepage     = "https://github.com/florianmari/LiveGQL"
  s.license      = "MIT"
  s.author             = { "Florian Mari" => "florian.mari@epitech.eu" }
  s.source       = { :git => "https://github.com/florianmari/LiveGQL.git", :tag => "0.0.1" }
  s.source_files  = "Source/Classes/**/*.{h,m, swift}"
  s.ios.deployment_target  = '9.0'
  s.exclude_files = "Classes/Exclude"
  s.dependency "Starscream", "~> 2.0.3"
  s.dependency "JSONCodable", "~> 3.0.1"
end
