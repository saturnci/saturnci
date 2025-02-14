class Quote
  QUOTES = [
    "\"An investment in knowledge pays the best interest.\" - Benjamin Franklin",
    "\"Do what you can, with what you have, where you are.\" - Theodore Roosevelt",
    "\"Experience keeps a dear school, but fools will learn in no other.\" - Benjamin Franklin",
    "\"No man ever steps in the same river twice, for it's not the same river and he's not the same man.\" - Heraclitus",
    "\"Nothing is good or bad, but thinking makes it so\" - William Shakespeare",
    "\"Opportunity is missed by most people because it is dressed in overalls and looks like work.\" - Thomas A. Edison",
    "\"The hen is the wisest of all the animal creation, because she never cackles until the egg is laid.\" - Abraham Lincoln",
    "\"The recipe for great work is: very exacting taste, plus the ability to gratify it.\" - Paul Graham",
    "\"The used key is always bright.\" - Benjamin Franklin",
  ]

  def self.random
    QUOTES.sample
  end
end
