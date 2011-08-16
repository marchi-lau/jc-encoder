  task :export, [:source] => :environment do |t, args|
    time_start = Time.now
    
    source    = args.source    
    Rake::Task[:akamai].invoke(source)
    Rake::Task[:atnext].invoke(source) if source.include?("replay-full")
    Rake::Task[:legacy].invoke(source)
    Rake::Task[:archive].invoke(source)
    
    time_elapsed = distance_of_time_in_words(Time.now, time_start)
    Notifier::Status("[All Tasks] Complete. 
                      Time Elapsed: #{time_elapsed}", "#{source}")     
    
  end
  
  task :archive, [:source] => :environment do |t, args|
    source  = args.source
    filename = File.basename(source,  File.extname(source))
    handbraking = HandBrake::CLI.new(:bin_path => "#{Rails.root.to_s}/bin/HandBrakeCLI", :trace => true).input("#{source}")
    titles = handbraking.scan
    
    duration = titles[1].seconds            # => "01:21:18"
    video = Video.create(:source => source, :filename => filename, :duration => duration)
  end
  
  task :hosuekeep, [:source] => :environment do |t, args|
    time_start = Time.now
    
    source    = args.source    
#    Rake::Task[:akamai:housekeep].invoke
        
    time_elapsed = distance_of_time_in_words(Time.now, time_start)
    Notifier::Status("[All Tasks] Complete. 
                      Time Elapsed: #{time_elapsed}", "#{source}")     
    
  end
  
  task :archive, [:source] => :environment do |t, args|
    source  = args.source
    filename = File.basename(source,  File.extname(source))
    handbraking = HandBrake::CLI.new(:bin_path => "#{Rails.root.to_s}/bin/HandBrakeCLI", :trace => true).input("#{source}")
    titles = handbraking.scan
    
    duration = titles[1].seconds            # => "01:21:18"
    video = Video.create(:source => source, :filename => filename, :duration => duration)
  end