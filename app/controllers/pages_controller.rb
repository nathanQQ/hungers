class PagesController < ApplicationController
  def about
  	@disable_container = true
  end

  def contact
  end

  def welcome
  	@disable_container = true
  end
end
