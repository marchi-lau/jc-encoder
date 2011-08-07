  task :import, [:source] => :environment do |t, args|
    source    = args.source    
    Rake::Task[:akamai].invoke(source)
    Rake::Task[:archive].invoke(source)
    
  end
  
  task :archive, [:source] => :environment do |t, args|
    source  = args.source
    filename = File.basename(source,  File.extname(source))
    handbraking = HandBrake::CLI.new(:bin_path => "#{Rails.root.to_s}/bin/HandBrakeCLI", :trace => true).input("#{source}")
    titles = handbraking.scan
    
    duration = titles[1].seconds            # => "01:21:18"
    video = Video.create(:source => source, :filename => filename, :duration => duration)
  end