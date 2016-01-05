# Hangman asks to start a new game or to load a previously saved one
# The computer chooses a random word from a source file
# The player guesses one letter at a time
# 6 incorrect guesses will end the game in a loss
# The player will be prompted to save the game after each guess
class Hangman
  require "csv"
  
  private
  
  def check_yes_no(answer)
    until ['y','n'].include?(answer.downcase) do
      puts "Sorry, I didn't catch that.\n[y]es, or [n]o?"
      answer = gets.chomp
    end
  end
  
  def load_old_name
    puts "What is the name of the previous game (example: old_game_name.csv)?"
    previous_game_name = gets.chomp
    until File.exist? previous_game_name do
      puts "Sorry, that game does not exist\nTry a different name? [y/n]"
      answer = gets.chomp
      check_yes_no(answer)
      if answer == 'n'
        puts "Ok, let's start a new game then"
        newgame
        break
      elsif answer == 'y'
        puts "What is the name of the previous game (example: old_game.csv)?"
        previous_game_name = gets.chomp
      end
    end
    return previous_game_name
  end
    
  def newgame
    words = []
    File.open('words.txt').each do |line|
      if line.length > 5  && line.length < 10
        words << line[0..line.length-2]
      end
    end
    @word = words[rand(words.length)].upcase
    puts "#{@word}"
    @guesses = 6
    @key = ''
    @word.length.times do @key << '_' end
    @guessed = []
  end
  
  def oldgame
    previous_game_name = load_old_name
    previous = CSV.open previous_game_name, headers: true, header_converters: :symbol
    previous.each do |row|
      @word = row[:word]
      @guesses = row[:guesses].to_i
      @key = row[:key]
      @guessed = []
      @guess0 = row[:guessed]
    end
    0.upto(@guess0.length) do |n|
      if (@guess0[n] =~ /[a-zA-Z]/) == 0
        @guessed << @guess0[n]
      end
    end
    puts "Ok, let's continue. Here is your key: #{@key} from #{@guessed}"
  end
  
  def end_game
    if @word == @key
      puts "#{@key}\nThat's it! You win!"
      return true
    elsif @guesses == 0
      puts"Out of guesses, you lose!\nThe answer was #{@word}"
      return true
    else
      return false
    end
  end
  
  def make_guess
    guess = ''
    puts "Here is your key: #{@key} from #{@guessed}"
    until (guess =~ /[a-zA-Z]/) == 0 do
      puts "Guess a letter"
      guess = gets.chomp.upcase
      if @word.include?(guess[0])
        puts "Good Guess!"
        @guessed.push(guess)
        0.upto(@word.length-1) do |num|
          if @word[num] == guess
            @key[num] = guess
          end
        end
      else
        puts "Nope, try again!"
        @guessed.push(guess)
        @guesses -= 1
      end
    end
  end
  
  def save_game
    puts "What name would you like to save this file as? Example: name.csv"
    answer = gets.chomp
    until answer[-4..-1] == '.csv' do
      puts "Re-enter the name with the '.csv' file extension"
      answer = gets.chomp
      until (answer[0..-5] =~ /\A\p{Alnum}+\z/) == 0
        puts "Re-enter the name using only alphanumeric characters ending in .csv"
        answer = gets.chomp
      end
    end
    CSV.open(answer,'wb') do |csv|
      csv << ['word','guesses','key','guessed']
      csv << [@word,@guesses,@key,@guessed]
    end
    puts "Your game has been save under the file: #{answer}"
  end
  
  public
  
  def initialize
  # A new game is started, script loads dictionary and selects random word (5-12 char)
  # Option to load saved game
    puts "Welcome to Hangman!\nDo you wish to load a previous game? [y/n]"
    answer = gets.chomp
    check_yes_no(answer)
  
  # Start a new game or continue an old
    if answer == 'n'
      puts "Ok, let's get started!"
      newgame
    else
      puts "Welcome back!"
      oldgame
    end
  
  # Allow a guess if the end game condition is not met, or the player wishes to continue
    status = end_game
    until status do
      puts "You have #{@guesses.to_s} guesses remaining"
      make_guess
      status = end_game
      if status
        break
      end
      puts "Would you like to guess again at this time? [y/n]"
      answer = gets.chomp
      check_yes_no(answer)
      if answer == 'n'
        save_game
        status = true
      end
    end
  end
end