def select_word
  # initialize array to hold words between 5 and 12 in length.
  wordList = []
  # Process file and add all words between 5 and 12 characters to the word array
  File.foreach('word_list.txt') { |word|
    word = word.strip
    if word.length > 4 && word.length < 13
      wordList.push(word)
    end
  }
  wordList.delete(wordList.sample).chomp.downcase.split("")
end

def check_user_input(userInput, previousInputs)
  if userInput.length != 1 || !userInput.match?(/[a-z]/)
    puts 'improper guess, please guess a single letter'
    false
  elsif (previousInputs.include? userInput) && userInput.match?(/[a-z]/)
    puts "#{userInput} has already been guessed"
    false
  else
    true
  end
end

def save_game(selectedWord, userInputs, incorrectGuesses, incorrectUserInputs)
  saved_game = File.open('saved_game', 'w')
  saved_game.puts selectedWord.join
  saved_game.puts userInputs.join
  saved_game.puts incorrectGuesses
  saved_game.puts incorrectUserInputs.join
end

# initialize variables
selectedWord = select_word
userInputs = Array.new(selectedWord.length, "_")
incorrectUserInputs = []
incorrectGuesses = 0
maxGuesses = 6

puts 'Would you like to load a saved game?(y or n): '
userResponse = ""
until userResponse == 'y' || userResponse == 'n'
  userResponse = gets.chomp.downcase
  if userResponse == 'y'
    loadedFile = File.open('saved_game', 'r')
    selectedWord = loadedFile.gets.split("")
    userInputs = loadedFile.gets.split("")
    incorrectGuesses = loadedFile.gets.to_i
    incorrectUserInputs = loadedFile.gets.split("")
  elsif userResponse != 'n'
    puts 'Improper input, please enter y or n: '
  end
end

game_over = false

until game_over
  # Check the user is over the guess limit
  if incorrectGuesses > maxGuesses
    game_over = true
    puts 'Sorry, you lost.'
  else
    # Provide information to user
    puts "You have #{maxGuesses - incorrectGuesses} incorrect guesses left"
    puts 'The following incorrect letters have already been chosen: '
    puts incorrectUserInputs.join(" ")

    # prompt user for a guess
    print('Enter a guess(Press enter to save the game): ')
    userInput = gets.chomp.downcase

    # Check the guess is a single letter
    if userInput == ""
      save_game(selectedWord, userInputs, incorrectGuesses, incorrectUserInputs)
      game_over = true
    elsif check_user_input(userInput, incorrectUserInputs)
      # Check the letter is contained within the word
      if selectedWord.include? userInput
        # Replace all empty spaces with the correct letter
        selectedWord.map.with_index { |letter, index|
          if letter == userInput
            userInputs[index] = userInput
          end
        }
      else
        puts "The word does not contain #{userInput}"
        incorrectGuesses += 1
        if userInput.match?(/[a-z]/)
          incorrectUserInputs.push(userInput)
        end
      end

      # Print current correctly guessed letters
      puts "#{userInputs.join(' ')}\n"
    end
  end

  # Check if the player has won
  unless userInputs.include? '_'
    puts 'You won!'
    game_over = true
  end
end
