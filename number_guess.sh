#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"
SECRET_NUMBER=$(( 1+$RANDOM%1000 ))
echo "Enter your username:"
read NAME
SELECT_RESULT=$($PSQL "SELECT games_played, best_game FROM users WHERE name='$NAME'")
if [[ -z $SELECT_RESULT ]]
then
INSERT_NEW_USER=$($PSQL "INSERT INTO users(name, games_played) VALUES('$NAME', 0)")
echo "Welcome, $NAME! It looks like this is your first time here."
else
read GAMES_PLAYED BAR BEST_GAME <<< $SELECT_RESULT
echo "Welcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
echo -e "\nGuess the secret number between 1 and 1000:"
read NUMBER
GUESS=1
while true
do
  if [[ ! $NUMBER =~ ^[0-9]+$ ]]
  then
  echo "That is not an integer, guess again:"
  read NUMBER
  else
  break
  fi
done
while true
do
  if [[ $NUMBER == $SECRET_NUMBER ]]
  then
    break
  fi
  if [[ $NUMBER -gt $SECRET_NUMBER ]]; then
  echo "It's lower than that, guess again:"
  else
  echo "It's higher than that, guess again:"
  fi
  read NUMBER
  while true
  do
    if [[ ! $NUMBER =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    read NUMBER
    else
    break
    fi
done
GUESS=$(($GUESS + 1))
done
UPDATE_GAMES_DATA=$($PSQL "UPDATE users SET games_played=games_played+1 WHERE name='$NAME'")
UPDATE_GAMES_BEST=$($PSQL "UPDATE users SET best_game=$GUESS WHERE name='$NAME' AND (best_game IS NULL OR best_game > $GUESS)")
echo "You guessed it in $GUESS tries. The secret number was $SECRET_NUMBER. Nice job!"
