module Admin
  class AdminController < ApplicationController
    def index
      authorize :admin, :index?
    end
  end
end
