class Api::V1::RegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters, only: [:create]
  skip_before_filter :verify_authenticity_token
  include Api::V1::RegistrationsDoc
  clear_respond_to
  respond_to :json


  def create
    binding.pry
    self.resource = build_resource(sign_up_params.merge params['user'])
    resource.save
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        sign_up(resource_name, resource)
        @resource = resource
        render 'api/v1/users/success'
      else
        expire_data_after_sign_in!
        respond_with resource #, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:user_name, :email, :password) }
  end

end