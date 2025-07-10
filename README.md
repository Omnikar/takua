![Screenshot of the game](screenshot.png)

# Takua
Uiua implementation of the abstract strategy game Tak (WIP)

Press space or enter to submit a move once it's been completed.

Use the arrow keys to rotate the camera view.

Press the `-` and `=` keys to view past moves.

A log of the game in Portable Tak Notation (PTN) will be printed automatically on quit.  
Past games can be reviewed and/or resumed from the middle by providing PTN input, either by passing a `.ptn` file path as a command line argument or passing `--stdin` and pasting the PTN into stdin.  
If resuming a game from the middle in online mode, both players must load the same PTN.
