module AuthenticationHelper
  extend ActiveSupport::Concern

  def authenticate_user!
    if current_user.present?
      unless current_user.terms_of_service
        redirect_to accept_terms_url(subdomain: false) and return
      end
    else
      flash[:error] = "You gotta log in!"
      redirect_to new_session_url(subdomain: false) and return
    end
  end

protected
  def strict_transport_security
    if request.ssl?
      response.headers['Strict-Transport-Security'] = "max-age=31536000;"
    end
  end

  def current_user
    @current_user ||= User.from_auth(cookies.signed[:auth])
  end

  # def permitted_params
  #   @permitted_params ||= PermittedParams.new(params, current_user)
  # end

  def require_member!
    if current_user.is_member_of?(current_organization)
      return true
      # unless current_user.vendor_terms_of_service
      #   redirect_to accept_vendor_terms_url(subdomain: false) and return
      # end
    else
      flash[:error] = "You're not a member of that organization!"
      redirect_to user_home_url(subdomain: false) and return
    end
  end

  def require_admin!
    unless current_user.is_admin_of?(current_organization)
      flash[:error] = "You gotta be an organization administrator to do that!"
      redirect_to user_home_url and return
    end
  end

  def require_superuser!
    unless current_user.present? and current_user.superuser?
      flash[:error] = "Gotta be an admin. Srys"
      redirect_to user_home_url(subdomain: false) and return
    end
  end

  def current_organization
    @organization ||= Organization.find_by_slug(request.subdomain)
  end

  def set_current_organization
    if Subdomain.matches?(request)
      @organzation = Organization.find_by_slug(request.subdomain)
    end
  end
end