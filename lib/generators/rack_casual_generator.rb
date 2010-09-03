class RackCasualGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  
  def copy_initializer
    copy_file "initializer.rb", "config/initializers/rack-casual.rb"
  end
  
  def print_usage
    puts
    puts "Remember to include the middleware in your application."
    puts "You can put this into config/application.rb:"
    puts "  config.middleware.use 'Rack::Casual::Authentication'"
    puts
  end    
  
end