require 'rubygems'
require 'jira-ruby'

host = ENV['JIRA_HOST']
username = ENV['JIRA_USERNAME']
password = ENV['JIRA_PASSWORD']
project_query = ENV['JIRA_BOARD_QUERY']

options = {
  username: username,
  password: password,
  context_path: '',
  site: host,
  auth_type: :basic,
  read_timeout: 120
}

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

SCHEDULER.every '5m', :first_in => 0 do |job|
  client = JIRA::Client.new(options)

  in_progress_issues = client.Issue.jql(
    "#{project_query} AND STATUS = '#{STATUS[:in_dev]}'"
  ).count

  review_issues = client.Issue.jql(
    "#{project_query} AND \
    (STATUS = '#{STATUS[:ready_qa]}' OR STATUS = '#{STATUS[:in_qa]}')"
  ).count

  staging_issues = client.Issue.jql(
    "#{project_query} AND \
    (STATUS = '#{STATUS[:ready_homolog]}' OR STATUS = '#{STATUS[:in_homolog]}')"
  ).count

  wip_issues = client.Issue.jql(
    "#{project_query} AND \
    STATUS != '#{STATUS[:backlog]}' AND \
    #{not_finished_query}"
  ).count

  stuck_staging_issues = client.Issue.jql(
    "#{project_query} AND \
    status changed to '#{STATUS[:in_homolog]}' before -3d AND \
    status = '#{STATUS[:in_homolog]}'"
  ).count

  blocked_issues = client.Issue.jql(
    "#{project_query} AND \
    flagged is not empty"
  ).count

  expedite_issues = client.Issue.jql(
    "#{project_query} AND \
    'Class of Service'='Expedite' AND \
    #{not_finished_query}"
  ).count

  send_event('jiraInProgressIssues', current: in_progress_issues)
  send_event('jiraReviewIssues', current: review_issues)
  send_event('jiraStagingIssues', current: staging_issues)
  send_event('jiraWorkInProgress', current: wip_issues)
  send_event('jiraStuckInStaging', current: stuck_staging_issues)
  send_event('jiraBlockedIssues', current: blocked_issues)
  send_event('jiraExpediteIssues', current: expedite_issues)
end
