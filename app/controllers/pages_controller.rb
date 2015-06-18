class PagesController < ApplicationController
  def about
  end

  def contact
  end

  def welcome
  	@disable_container = true
  end
end
