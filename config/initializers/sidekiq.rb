require 'cf-app-utils'

if ENV['VCAP_SERVICES']
  credentials = CF::App::Credentials.find_by_service_name('redis') || {}
  redis = "redis://:#{credentials['password']}@#{credentials['hostname']}:#{credentials['port']}"

  Sidekiq.configure_server do |config|
    config.redis = {url: redis}
  end

  Sidekiq.configure_client do |config|
    config.redis = {url: redis}
  end
end

Sidekiq.configure_server do |config|
  schedule_file = "config/sidekiq_schedule.yml"

  if File.exists?(schedule_file) && Sidekiq.server?
    Sidekiq::Cron::Job.load_from_hash! YAML.load_file(schedule_file)
  end
end
