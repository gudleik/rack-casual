class RackCasualGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  
  def copy_initializer
    copy_file "initializer.rb", "config/initializers/rack-casual.rb"
  end
  
end