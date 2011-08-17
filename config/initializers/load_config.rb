ENV_CONFIG    = YAML.load_file("#{Rails.root.to_s}/config/environment.yml")[RAILS_ENV]
AKAMAI_CONFIG = YAML.load_file("#{Rails.root.to_s}/lib/config/akamai.yml")