class SillinessController < ApplicationController
  def index
    skip_authorization
    render plain: SillyName.random
  end
end
