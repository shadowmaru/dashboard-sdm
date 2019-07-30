require 'sinatra/cyclist'
require 'dashing'

configure do
  set :auth_token, 'YOUR_AUTH_TOKEN'

  # See http://www.sinatrarb.com/intro.html > Available Template Languages on
  # how to add additional template languages.
  set :template_languages, %i[html erb]

  helpers do
    def protected!
      # Define allowed ips
      ips_from_env_var = ENV['ALLOWED_IP_ADDRESSES'].split(',').map(&:strip)
      @ips = ['127.0.0.1'] + ips_from_env_var

      # If request IP is not included
      unless @ips.include?(request.ip) || ENV['RACK_ENV'] == 'development'
        # Deny request
        throw(:halt, [401, "Not authorized\n"])
      end
    end
  end
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

set :routes_to_cycle_through, %i[apoio-jira apoio-semaphore apoio-honeybadger apoio-flowclimate]

run Sinatra::Application
