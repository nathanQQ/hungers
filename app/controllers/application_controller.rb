class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # configured for adding name field in Devise model
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected
  def configure_permitted_parameters
  	devise_parameter_sanitizer.for(:sign_up).push(:name, :aka_name, :address_line1, :address_line2, :city, :state, :zip_code, :tax_rate)
  	devise_parameter_sanitizer.for(:account_update).push(:name, :aka_name, :address_line1, :address_line2, :city, :state, :zip_code, :tax_rate)
  end

end
