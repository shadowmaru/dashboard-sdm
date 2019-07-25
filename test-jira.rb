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

STATUS = {
  backlog: 'Backlog',
  ready_dev: 'Ready to Dev',
  in_dev: 'In Dev',
  ready_qa: 'Ready to QA',
  in_qa: 'In QA',
  ready_homolog: 'Ready to Homolog',
  in_homolog: 'In Homolog',
  done: 'Done',
  archived: 'Archived',
  cancelled: 'Canceled'
}.freeze

CLASS_OF_SERVICE = {
  expedite: 'Expedite',
  standard: 'Standard',
  fixed_date: 'Fixed Date',
  intangible: 'Intangible'
}.freeze

not_finished_query = "STATUS != '#{STATUS[:done]}' AND \
                      STATUS != '#{STATUS[:archived]}' AND \
                      STATUS != '#{STATUS[:cancelled]}'"


# Show all projects
query = "(project in (AC, NPS, MON, AUTH, Workflow, Malote, Portal) OR project = PNT AND fixVersion in ('Sustentação Q3/2019 AP', 'Sustentação Q2/2019 AP'))"
# issues = client.Issue.jql(query)
  wip_issues = client.Issue.jql(
    "#{query} AND \
    STATUS != '#{STATUS[:backlog]}' AND \
    #{not_finished_query}"
  )

    in_progress_issues = client.Issue.jql(
    "#{query} AND STATUS = '#{STATUS[:in_dev]}'"
  )


in_progress_issues.each do |issue|
  puts "Issue -> key: #{issue.key}, name: #{issue.summary}"
end
