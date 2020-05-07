require "yaml"
class Game
    @@dictionary = File.readlines("lib/5desk.txt").keep_if { |word| word.chomp.length.between?(5,12) }
    @@guessed_letters = []


    def game_start
        puts "--------------------------"
        puts "   Welcome to Hangman!"
        puts "--------------------------"
        puts "\n"
        puts "[1] = New Game"
        puts "[2] = Load Saved Game"
        response = gets.chomp
        if response == "1"
            word_select
        elsif response == "2"
            load_saved_game
        else
            game_start
        end
    end

    def word_select
        @secret_word = @@dictionary.sample.chomp.upcase
        set_board
    end

    def set_board
        game_board = Array.new(@secret_word.length, "_")
        @game_board = game_board.join("")
        p @game_board
        puts "\n"
        puts "You have #{@secret_word.length} chances to guess the word!"
        guess_word
    end

    def set_saved_board
        p @game_board
        puts "\n"
        puts "You have #{@secret_word.length} chances to guess the word!"
        guess_word
    end

    def guess_word
        @guess_count = @secret_word.length
        while @guess_count > 0
            print "Choose Letter: " 
            guess = gets.chomp.upcase
            puts "\n"
            if guess == "SAVE"
                save_game
            elsif guess == "EXIT"
                quit_game 
            elsif @secret_word.include?(guess)
                secret_word = @secret_word.split("")
                secret_word.each_with_index {|letter, idx| @game_board[idx] = guess if letter == guess }
                @@guessed_letters.push(guess)
                announce_winner unless @game_board.include?("_")
            else
                @@guessed_letters.push(guess)
                @guess_count -= 1
            end
            p @game_board
            puts "Guesses remaining: #{@guess_count}"
            print "Guessed Letters: #{@@guessed_letters.join(" ")}\n"
            puts "save = Save Game"
            puts "exit = Exit Game"
        end 
        puts "\n"
        puts "You Lose!"
        puts "The word was #{@secret_word}"         
    end

    def announce_winner
            puts "#{@secret_word}\n"
            puts "You win!"
            exit!
    end

    def save_game
        print "Name Your Game: "
        id = gets.chomp
        print "Saving ... " 
        Dir.mkdir("saved_games") unless Dir.exists? "saved_games"
        filename = "saved_games/#{id}.yaml"
        File.open("#{filename}", "w") {|file| file.write save_to_yaml}
        sleep(0.6)
        print "Saved!\n"
        sleep(0.6)
        reset_game
        game_start
    end

    def save_to_yaml
        game_data = {
            secret_word: @secret_word,
            game_board: @game_board,
            guessed_letters: @@guessed_letters,
            guess_count: @guess_count
    }
    YAML.dump(game_data)
    end

    def load_saved_game
        puts "\n"
        files = Dir.entries("saved_games")
        puts files[2..-1]
        puts "\n"
        print "Select the game you would like to load (without the 'yaml'): "
        filename = gets.chomp
        #read data from file
        file = YAML.load_file("saved_games/#{filename}.yaml")
        #load data to current game
        @secret_word = file[:secret_word]
        @game_board = file[:game_board]
        @@guessed_letters = file[:guessed_letters]
        @guess_count = file[:guess_count]

        set_saved_board
    end

    def reset_game
        @secret_word = nil
        @game_board = nil
        @@guessed_letters = nil
        @guess_count = nil
    end

    def quit_game
        reset_game
        game_start
    end

end

game = Game.new
game.game_start

