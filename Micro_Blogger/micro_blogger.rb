# Twitter automated blogger tutorial
# http://tutorials.jumpstartlab.com/projects/microblogger.html
# MerkHermer twitter handle established for testing
require 'jumpstart_auth'
require 'bitly'

Bitly.use_api_version_3

class MicroBlogger
  attr_reader :client
  
  # Initialization with jumpstart generates a twitter blog
  def initialize
    @bitly = Bitly.new('mchellmer','R_3b27d13cbd824b369f2cfcf4ad0f3eda')
    puts "Initializing MicroBlogger"
    @client = JumpstartAuth.twitter  # Sets up OAuth through gem, twitter will supply a pin for login
  end
  
  # Sets up a method that tweets to an account
  def tweet(message)
    if message.length < 140
      @client.update(message)
    else
      puts "This tweet is too long."
    end
  end
  
  # Messages a twitter account
  def dm(target, message)
    puts "Trying to send #{target} this direct message:\n#{message}"
    screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name}
    puts "#{screen_names}"
    if screen_names.include?("#{target}")
      message = "d @#{target} #{message}"
      tweet(message)
    else
      puts "@#{target} is not following you! Cannot submit dm to @#{target}"
    end
  end
  
  # Method that spams all friends
  def followers_list
    screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name}
    return screen_names
  end
  
  def spam_my_followers(message)
    followers_list.each {|follower| dm(follower,message)}
  end
  
  # Pulls all recent tweets from followers
  def everyones_last_tweet
    friends = @client.friends
    friends.each do |friend|
      message = friend.status.text
      timestamp = friend.status.created_at.strftime("%A, %b %d")
      puts "@#{friend} said this on #{timestamp}\n#{message}"
    end
  end
  
  # Takes a url and shortens it
  def shorten(original_url)
    puts "Shortening this URL: #{original_url}"
    bitly = Bitly.new('mchellmer','R_3b27d13cbd824b369f2cfcf4ad0f3eda')
    return bitly.shorten(original_url).short_url
  end
  
  ## Sets up user interface to interact with twitter account
  def run
    puts "Welcome to the JSL Twitter Client"
    command = ""
    while command != "q"
      printf "enter command: "
      input = gets.chomp
      parts = input.split(" ")
      command = parts[0]
      case command
        when 'q' then puts "Goodbye!"
        when 't' then tweet(parts[1..-1].join(" "))
        when 'dm' then dm(parts[1], parts[2..-1].join(" "))
        when 'spam' then spam_my_followers(parts[1..-1].join(" "))
        when 'elt' then self.everyones_last_tweet
        when 's' then shorten(parts[1])
        when 'turl' then tweet(parts[1..-2].join(" ").to_s + " " + shorten(parts[-1]).to_s)
        else
          puts "Sorry, I don't know how to #{command}"
      end
    end
  end
  
end

blogger = MicroBlogger.new
blogger.run