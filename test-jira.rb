require 'rubygems'
require 'pp'
require 'jira-ruby'

# Consider the use of :use_ssl and :ssl_verify_mode options if running locally
# for tests.

username = "ricardo.yasuda@bioritmo.com.br"
password = "P3eeMwda60okV7ij45Yq8B19"

options = {
            :username => username,
            :password => password,
            :site     => 'https://devbio.atlassian.net',
            :context_path => '',
            :auth_type => :basic,
            :read_timeout => 120
          }

client = JIRA::Client.new(options)

# Show all projects
project = 'AP'
issues = client.Issue.jql("project = '#{project}'")

issues.each do |issue|
  puts "Issue -> key: #{issue.key}, name: #{issue.summary}"
end
