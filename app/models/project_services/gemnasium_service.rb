require "gemnasium/gitlab_service"

class GemnasiumService < Service
  prop_accessor :token, :api_key
  validates :token, :api_key, presence: true, if: :activated?
  validate :deprecation_validation

  def title
    'Gemnasium'
  end

  def description
    'Gemnasium 监视项目依赖关系，并提醒您有关更新和安全漏洞。'
  end

  def self.to_param
    'gemnasium'
  end

  def fields
    [
      { type: 'text', name: 'api_key', placeholder: 'Your personal API KEY on gemnasium.com ', required: true },
      { type: 'text', name: 'token', placeholder: 'The project\'s slug on gemnasium.com', required: true }
    ]
  end

  def self.supported_events
    %w(push)
  end

  def deprecated?
    true
  end

  def deprecation_message
    "Gemnasium has been acquired by GitLab in January 2018. Since May 15, 2018, the service provided by Gemnasium is no longer available."
  end

  def deprecation_validation
    errors[:base] << deprecation_message
  end

  def execute(data)
    return unless supported_events.include?(data[:object_kind])

    # Gitaly: this class will be removed https://gitlab.com/gitlab-org/gitlab-ee/issues/6010
    repo_path = Gitlab::GitalyClient::StorageSettings.allow_disk_access do
      project.repository.path_to_repo
    end

    Gemnasium::GitlabService.execute(
      ref: data[:ref],
      before: data[:before],
      after: data[:after],
      token: token,
      api_key: api_key,
      repo: repo_path
    )
  end
end
