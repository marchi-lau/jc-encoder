# Cycles through autoload_paths and requires them so that class methods are loaded

Rails::Application.config.autoload_paths.each do |d|
    Dir["#{d}/*.rb"].each do |p|
        puts "Auto-required #{p}"
        require p
    end
end