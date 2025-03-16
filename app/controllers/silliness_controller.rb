class SillinessController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user_or_404!

  def index
    skip_authorization
    render json: {
      date: Date.today.iso8601,
      name_of_the_day: random_name
    }
  end

  private

  def random_name
    time = Time.now
    # Only use the day as seed so it changes once per day
    seed = time.day
    
    srand(seed)
    
    modifier = SillyName::MODIFIERS[rand(SillyName::MODIFIERS.length)]
    noun = SillyName::NOUNS[rand(SillyName::NOUNS.length)]
    
    srand
    
    "#{modifier} #{noun}"
  end
end
