class Quote
  QUOTES = [
    "\"Nothing is good or bad, but thinking makes it so\" - William Shakespeare",
    "\"The hen is the wisest of all the animal creation, because she never cackles until the egg is laid.\" - Abraham Lincoln",
    "\"Do what you can, with what you have, where you are.\" - Theodore Roosevelt",
  ]

  def self.random
    QUOTES.sample
  end
end
