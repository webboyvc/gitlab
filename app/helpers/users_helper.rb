module UsersHelper
  def user_link(user)
    link_to(user.name, user_path(user),
            title: user.email,
            class: 'has-tooltip commit-committer-link')
  end

  def user_email_help_text(user)
    return '如果用户未上传头像的话，我们也会使用该邮件地址来自动寻找头像。' unless user.unconfirmed_email.present?

    confirmation_link = link_to '重新发送确认电子邮件', user_confirmation_path(user: { email: @user.unconfirmed_email }), method: :post

    h('请在继续前点击确认邮件中的链接，邮件被发往 ') +
      content_tag(:strong) { user.unconfirmed_email } + h('.') +
      content_tag(:p) { confirmation_link }
  end

  def profile_tabs
    @profile_tabs ||= get_profile_tabs
  end

  def profile_tab?(tab)
    profile_tabs.include?(tab)
  end

  def current_user_menu_items
    @current_user_menu_items ||= get_current_user_menu_items
  end

  def current_user_menu?(item)
    current_user_menu_items.include?(item)
  end

  private

  def get_profile_tabs
    [:activity, :groups, :contributed, :projects, :snippets]
  end

  def get_current_user_menu_items
    items = []

    items << :sign_out if current_user

    # TODO: Remove these conditions when the permissions are prevented in
    # https://gitlab.com/gitlab-org/gitlab-ce/issues/45849
    terms_not_enforced = !Gitlab::CurrentSettings
                                .current_application_settings
                                .enforce_terms?
    required_terms_accepted = terms_not_enforced || current_user.terms_accepted?

    items << :help if required_terms_accepted

    if can?(current_user, :read_user, current_user) && required_terms_accepted
      items << :profile
    end

    if can?(current_user, :update_user, current_user) && required_terms_accepted
      items << :settings
    end

    items
  end
end
