# csc411swku
Frat Defense

The following is a readme of the multiplayer portion of Frat Defense. This has 
been broken down into the following sections: 

	- Analysis of the directory structure
	- Examination of the networking procedures utilized 
	- Design decisions considered while constructing Frat Defense

################################################################################
####                          File Directory Analysis                       ####     
####                                                                        #### 
####                                                                        #### 
####                                                                        #### 
################################################################################

If you take a look at the files, at first you may be confused as to which files
are of importance. To lessen this confusion, below is a description of each 
file.

FratDefense Multi
	-> Assets				: all images, sounds, and animations are placed here
	-> build.settings       : acts as the manifest file, adds certain properties
							: to the build
	-> Client.lua           : Client library file, supplied by M.Y. Developers
	-> config.lua           : acts as another manifest file, this one is
							: platform dependent
	-> gameBoardScreen.lua  : 1st player game scene
	-> gameClass.lua        : manages a game of Frat Defense
	-> highScores.txt       : file used to store high scores
	-> highScoresScreen.lua : displays high scores
	-> *.png                : icons used by the OS
	-> *.ttf				: fonts used by Frat Defense
	-> loadingScreen.lua    : displays the loading screen of Frat Defense
	-> loseScreen.lua       : displays the losing screen 
	-> main.lua             : first file to be executed, all corona applications
							: have a main file
	-> mainMenuScreen.lua   : displays the main menu of Frat Defense
	-> Minion.lua           : creates a minion object managed by gameClass
	-> MultiGameScreen.lua  : multiplayer game scene
	-> multiPlayerSetup...  : menu screen for the multiplayer lobby
	-> Server.lua           : Server library file, supplied by M.Y. Developers
	-> settingsScreen.lua   : displays the settings of the game
	-> Tower.lua            : creates a tower object managed by gameClass
	-> volumeConfig.txt     : file used to manage audio preferences
	-> winScreen.lua        : displays the winning screen

The following are the multiplayer files that were created by us to enable 
multiplayer:
	- multiPlayerSetupScreen.lua
	- MultiGameScreen.lua

Most of the other files were either left alone or slightly modified. 

################################################################################
####                    Networking Procedures Examination                  ####     
####                                                                        #### 
####                                                                        #### 
####                                                                        #### 
################################################################################

To make multiplayer possible, we needed a Corona library that supports network 
communication. The Corona SDK provides a socket library that one could 
implement, however it requires a lot of work to utilize since it just 
provides the bare-bones. So, we looked for 3rd party networking libraries 
that are compatible with Corona, and sure enough we found AutoLan - created by
M.Y. Developers. Below is a list of features that AutoLan provides:
	- Using a client server model, allows multiplayer integration
	- Allows easy implementation
	- Allows for packet priority
	- Provides flow control

Now one of the requirements of this project was to use TCP. Unfortunately, this
library utilizes UDP with TCP integration such as flow control and reliability.
This was an important item we had to consider since one of the main objectives
of multiplayer is to make sure both players are in the same game state. That is,
if I send a minion to my opponent, he better receive it or else my game would 
continue to play thinking he received it. So to meet the requirements of TCP
integration, we implemented the protocol's attributes through the use of 
AutoLan's library.

Another thing we had to consider was P2P or Client/Server. Technically, our  
result was a mix of both. We're utilizing a P2P connection between two players
but one player acts as the server where the other player acts as the client. 
If Player A was the server, his/her task would be to defend his/her base. If 
Player B was the client, his/her task would be to attack Player's A base. 

So what's being communicated to each other? Let's use the above scenario of 
Player A being the server and Player B being the client:
	- Player A connects to Player B. 
	- Player B confirms this confirmation by sending an acknowledgement back to
	  the client. If Player B denies the confirmation, Player A gets 
	  disconnected.
    - Player B lays out some towers. Each tower placement sends a message to
      Player A with these details. (More on Message Protocol layer)
    - Player A sends some minions. Each minion creation sends a message to 
      Player B with these details.
    - Player B finishes the game. End game results are sent to Player A.
    - Once the game ends and both users acknowledge this, they are disconnected
      from each other and there client/server objects are deleted, 
      allowing them to start a new game. 

################################################################################
####                          Game Design Decisions                         ####     
####                                                                        #### 
####                                                                        #### 
####                                                                        #### 
################################################################################

In order to incorporate multiplayer, we needed a new menu screen that would
provide an interface for multiplayer. This required modifying the original
menu screen by adding a 2 Player button. On our multiplayer menu screen, a list
of other opponents on your network are listed. In order to add yourself to that 
list, click the Create button. This generates a server object that is 
designated to you. If another player clicks on your entry, he/she will become
the client and you will then start the game (That's if you accept his/her 
request).

So how to display the list of servers? We used a table-view that looks
for AutoLan servers on the network. If a server is found, its entry gets added
to the TableView. BUG: If you are on the menu screen and a server drops, its 
entry will still be visible until you refresh the screen (Close out and reopen).

This menu screen also is in charge of setting up the server and client objects.
Obviously, if one player is a server, it can't be a client too. In order to 
abide by this, we had to implement conditions that check for this. 

Once the connections are created and confirmed, each player will be moved to the
multiplayer game screen. Each screen will look a little different. A client's
screen only has minion options. A server's screen only has tower options. In the
single player version, only towers are available since the minions gets auto-
generated. 

Message Protocol:
	- To provide uniform game states between each player, a message protocol
	  was created using a list. Below is the protocol:
	  	-- (1,1) - Initialization Packet
	  	-- (2,[towerClientID]) - A Tower Packet, only clients can receive these
	  	-- (2, [minionClientID])  - A Minion Packet, only servers can receive 
	  	   these
  	    -- (5,[1,2],serverScore) - Server's final game state, client only 
  	       receives this

To allow for further iterations, we created a gap. (2 - 5) Because, 5 represents
the final game state, we see only iterations being added in front of them. 
NOTE: An acknowledgement portion gets added to each packet to ensure delivery.

The final design decision we had to make was how to limit the amount of minions
a client can send. To make things fair, a client is given a predefined amount of
points before a round starts. Each minion costs a certain amount of points. Once
all minions are killed off and the client's points reach zero, the current round
finishes and the next round starts. To keep the game balanced, the client will
receive more points as the game progresses allowing him/her to use the higher
priced minions. 