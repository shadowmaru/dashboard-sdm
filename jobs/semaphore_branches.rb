require 'semaphoreapp'

class SemaphoreConnector
  def initialize(auth_key=ENV['SEMAPHORE_AUTH_KEY'])
    Semaphoreapp.auth_token = auth_key
  end

  def project_list
    Semaphoreapp::Project.all.map(&:name)
  end

  def get_project(project_name)
    Semaphoreapp::Project.find_by_name(project_name)
  end

  def get_branches(project_name)
    Semaphoreapp::Project.find_by_name(project_name).branches.map { |branch| branch.branch_name }
  end

  def branch_status(project_name, branch_title)
    requested_branch = get_project(project_name).
      branches.
      find {|branch| branch.branch_name == branch_title }

    requested_branch_info = {
      "name" => requested_branch.branch_name,
      "build_number" => requested_branch.build_number,
      "build_status" => requested_branch.result,
      "last_build" => requested_branch.build_url,
      "last_build_time" => requested_branch.finished_at,
      "latest_commit_author" => requested_branch.commit.author_name,
      "latest_commit_message" => requested_branch.commit.message,
      "latest_commit_link" => requested_branch.commit.url
    }
  end

  def number_of_branches(project_name)
    get_branches(project_name).count
  end
end

@semaphore = SemaphoreConnector.new

def build_branch_list(project, branches)
  branch_list = @semaphore.get_branches(project).map do |branch|
    this_branch = @semaphore.branch_status(project, branch)

    {
      label: this_branch['name'],
      branch_status: this_branch['build_status'],
      last_build: this_branch['last_build_time']
    }
  end

  branch_list.select! { |branch| branches.include?(branch[:label]) }

  branch_list
end

SCHEDULER.every '10m', first_in: 0 do |job|
  send_event(
    'semaphoreAcessos',
    {
      title: 'Acessos',
      items: build_branch_list('acessos', ['master'])
    }
  )
  send_event('semaphoreNPS', {
    title: 'NPS',
    items: build_branch_list('nps', ['master'])
  })
end
