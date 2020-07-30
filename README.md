MILLIONAIRE 

INSTALLATION
-Clone the directory to your local device
-Open the directory using either your terminal or a code editing software
-Using the terminal, type the following commands followed by return(enter)

rake db:migrate
rake db:seed

RUNNING THE GAME 
-To start the game, type the folloiwng command followed by return(enter)

ruby bin/run.rb

-You should now be at the Main Menu, where you can either:
1. Start a new game 
2. See the High_Scores (there won't be any high scores if no games have been played)
3. Read the instructions
4. Quit the game

-If at any point during the game, you experience an error or want to exit, press command(control)+c


INTRODUCTION
Welcome to MILLIONAIRE! 

Millionaire is a quiz competition in which the goal is to correctly answer a series of 15 consecutive multiple-choice questions.
You must create a username and password or you have the option to login if you are a previous player. Your high score will be recorded.
Each question will have 4 answer choices, with only 1 correct answer.
The question difficulty will increase every 5 questions. (The questions are grouped by "easy", "medium" and "hard")
Each question is worth a specified amount of "Prize Money" and is not cumulative.
If at any time the contestant gives a wrong answer, the game is over.

You will have access to 2 different Lifelines.
However, you will only be able to use one Lifeline per question and each Lifeline can only be used once.
Once a question appears with the 4 answer choices, you can access the Lifelines by either scrolling down or hitting the right arrow key.
The Fifty-Fifty Lifeline can be used to get rid of two incorrect answer choices.
The Cut Question Lifeline can be used to swap questions and get a new one
 

CONTRIBUTORS GUIDE
Please contact either Colin Mosley or Arnie Serrano on GitHub if you would like to contribute to the future development of MILLIONAIRE!

