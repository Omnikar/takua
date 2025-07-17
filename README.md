![Screenshot of the game](screenshot.png)

# Takua
Uiua implementation of the abstract strategy game Tak

See the following video for a tutorial on how to play Tak.  
https://youtu.be/iEXkpS-Q9dI

Press space to submit a move once it's been completed.

Use the arrow keys to rotate the camera view.

Press the `-` and `=` keys to view past moves.
Hold shift while pressing either of these keys to skip to the beginning or end of the game.

A log of the game in [Portable Tak Notation (PTN)](https://ustak.org/portable-tak-notation) will be printed automatically on quit. A PTN log can be exported manually at any point by pressing the `E` key.  
Past games can be reviewed and/or resumed from the middle by providing PTN input, either by passing a file path as a command line argument or passing `--stdin` and pasting the PTN into stdin.  
If resuming a game from the middle in online mode, the host loads the PTN.

Press tab or enter to open the chat. The tab key can be used to close the chat without sending.
