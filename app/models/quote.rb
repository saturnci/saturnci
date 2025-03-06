class Quote
  QUOTES = [
    "\"An investment in knowledge pays the best interest.\" - Benjamin Franklin",
    "\"Be a yardstick of quality. Some people aren't used to an environment where excellence is expected.\" - Steve Jobs",
    "\"Design is not just what it looks like and feels like. Design is how it works.\" - Steve Jobs",
    "\"Do what you can, with what you have, where you are.\" - Theodore Roosevelt",
    "\"Experience keeps a dear school, but fools will learn in no other.\" - Benjamin Franklin",
    "\"Focus is about saying no.\" - Steve Jobs",
    "\"No man ever steps in the same river twice, for it's not the same river and he's not the same man.\" - Heraclitus",
    "\"Nothing is good or bad, but thinking makes it so.\" - William Shakespeare",
    "\"Opportunity is missed by most people because it is dressed in overalls and looks like work.\" - Thomas A. Edison",
    "\"The hen is the wisest of all the animal creation, because she never cackles until the egg is laid.\" - Abraham Lincoln",
    "\"The recipe for great work is: very exacting taste, plus the ability to gratify it.\" - Paul Graham",
    "\"The used key is always bright.\" - Benjamin Franklin",
    "\"The short successes that can be gained in a brief time and without difficulty, are not worth much.\" - Henry Ford",
    "\"Be ready to revise any system, scrap any method, abandon any theory, if the success of the job requires it.\" - Henry Ford",
    "\"The purpose of abstracting is not to be vague, but to create a new semantic level in which one can be absolutely precise.\" - Edsger W. Dijkstra",
    "\"The computing scientist’s main challenge is not to get confused by the complexities of his own making.\" - Edsger W. Dijkstra",
  ]

  def self.random
    QUOTES.sample
  end
end
