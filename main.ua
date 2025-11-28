# Experimental!
I ~ "git: github.com/Marcos-cat/iris"
~ "game"
  ~ Action Board Process
  ~ Cap Flat Wall
~ "render"
  ~ Player₁ Player₂
  ~ Scene

T‼ ← &p $"_ took _" ^0 ⍜now^1

VoxelScale ← 2.5
WinSize    ← 700_700

DefaultCamPos ← [5π/4 ∠√2 1]
DragSpeed     ← [0.005 0.005]

# Create an online join code from a number
Code ← ⌅(+@A⊥26|⌝⊥26-@A⌵)
# Normalized spherical to rectangular coordinates
SphToRect ← ˜⊂×⍜°⊟∩°∠

# Apply bounds to camera rotation
LimitCam ← ⍜°⊟⊓(◿τ|↥0.2↧-0.2 π)

# Render voxels and rescale to screen size
# ? CamPos Voxels
MkVoxels ← ▽₂⊢÷△₂⊸⊙WinSize voxels!°⊸⊃Scale Camera VoxelScale SphToRect

# Draw an on-screen message
Message₁ ← I~Draw~Text White 30 100_100
# Draw an on-screen message at a different position than Message₁
Message₂ ← I~Draw~Text White 30 100_140

┌─╴Chat
  ┌─╴Message
    ~ {Sender Time Content}
    Fmt ← ⊂ ⨬⋅""⨬"You: " "Them: " ±⊃(Time|Sender|Content)
  └─╴

  ~ {
    History ← °△⊟0⧻Message~Fields
    Draft ← ""
    Focused ← 0
  }
  Size ← 20
  # Draw the chat
  Draw ← ⟜↓(
    History
  | ⊂Message 0 0 ˜⊂@_Draft
    ≡⊟30 ˜-⊣WinSize +40 ×Size°⊏
  | ¬Focused
    ⨬1(˜-now◡⋅≡Message~Time
       ¬↥0÷4-8 ∩₃⌞▽⊸<12)
    ⊙⊙⍚Message~Fmt
    I~Draw~Text ≡⌞⊂White ⊙Size
  )
└─╴

┌─╴GameMode
  |Local
  |Online {
    MyColor
    Tunnel
    Chat ← Chat
  }
└─╴

┌─╴NetMessage
  |JoinRequest {MyPort}
  |JoinAccept {BoardSize YourColor PTN}
  |JoinReject
  |DoAction {Action}
  |ChatMessage {Message}
└─╴

┌─╴Game
  ~ {
    ClickMap
    Texture
    Action
    Board
    GameMode
    # [Yaw Pitch]
    CamPos ← DefaultCamPos
    # Turn to view; ∞ means present
    PastView ← ∞
    IdxVoxels ← °△0_0_0
    BoardVoxels ← °△0_0_0
    # Whether or not the last click involved a drag
    Dragged ← 0
  }

  # Rebuild voxel arrays from the board state
  # Game ? Game
  RebuildScene ← (
    # If PastView is ∞, create a scene out of the present
    # Otherwise, make one out of the corresponding past state
    ⊸PastView
    ⍣(⊸⊃Action Board °∞
    | Action~New°⊸Board~State⊏⊙(⊸Board~History⊸Board))
  
    Scene≈IdxsAndBuild
    °⊸⊃IdxVoxels BoardVoxels
  )

  # Redraw textures from the voxel arrays
  # Game ? Game
  RedrawScene ← (
    ∩⌞MkVoxels ⊸⊃(CamPos|IdxVoxels|BoardVoxels)
    °⊸⊃(ClickMap|I~Texture~Image Texture)
  )

  # Rotate the camera based on keyboard input
  # Game ? Game
  HandleKeyCamRotation ← (
    ⊸≠₀/+I~Key~ULDR 0
    ⨬◌(×I~Window~Dt⊟¯°ℂ
       ⍜⊙CamPos(LimitCam-)
       RedrawScene)
  
    I~Key~Pressed‼@r(
      °⊸CamPos DefaultCamPos
      RedrawScene
    )
  )

  # Rotate the camera based on mouse input
  # Game ? Game
  HandleMouseCamRotation ← ⍣I~Mouse!Drag‼Left(
    ⍥⊸(°1>10⌵)¬◡⋅Dragged
    ×DragSpeed⊟°ℂ
    ⍜⊣¯
    ⍜⊙CamPos(LimitCam+)
    RedrawScene
    °⊸Dragged1
  )()

  # Switch the currently viewed past move based on keyboard input
  # Game ? Game
  HandlePastViewing ← ⍣(
    °1⊸⌵-∩I~Key~Pressed @- @=
    ⊙(⊸⊃PastView Board≈Turn
      ⍥⋅⟜∘⊸=∞)
    I~Key!(∨∩Down LeftShift RightShift)
    ⨬+(∪⨬0 ∞↥₀)
    ⍥⋅∞⤚≤↥₀
    °⊸PastView
    RedrawScene RebuildScene
  | )

  # Modify the currently active move based on mouse input
  # Game ? Game
  HandleBoardClick ← ⍣I~Mouse!Released‼Left(
    °0◡⋅Dragged
    ⊙⊸ClickMap
    ⊸±⊡⌊×◡⋅△÷WinSize˜⊟°ℂ
    ⨬◌(
      ⊙⊸⊃(♭₂⇡△◡⋅Board~State ⊃Action Board)
      ⊏-₁
      Action~ClickSquare
    
      °⊸⊃Action Board
      °⊸PastView ∞
      RedrawScene RebuildScene
    )
  )(°⊸Dragged0)

  # Submit the currently active move based on player input,
  # sending a corresponding net message if in online mode
  # Game ? Game
  HandleActionSubmission ← ⍣(
    ⊸⊃Action Board
    Process~Validate
    I~Draw~Text White 40 -50_60 WinSize ">"
    I~Key!Pressed‼Space(
      ⍣(◡⊙⋅GameMode≈Online~Tunnel
        NetMessage~DoAction
        I~Net~Give
      | )
      Process
      Action~New
    )
    °⊸⊃Action Board
  | )

  # Error if not in a game end state, and display a game end message if not viewing a past move
  # ? Game
  HandleWinState ← (
    ⊸Board
    Board!⍣(
      ⟜(°1⊸/↥CheckRoadWin)
      # Bias for the player that was just active in case of a double road
      ⍜⊏(+0.1) ¬ActivePlayer
    | °1⊸/↥CheckFlatWin)
    # Don't draw the game end message if viewing a past move
    ⍣(°1≠∞⋅Game~PastView
    | Message₁ ⋅"Draw" °1_1
    | ⊢⍖
      ⍣(=⊙GameMode≈Online~MyColor
        {"You lose!" "You win!"}
      | {"White wins!" "Black wins!"})
      Message₁ ˜⊏
    )
  )

  # Error if in online mode and it is not this player's turn
  # ? Game
  CheckActivePlayer ← (
    ⟜GameMode
    ⍣⋅°GameMode~Local(
      ◌°⟜∘⊓Board≈ActivePlayer GameMode~Online~MyColor
    )
  )

  # Handle board clicks and move submission by the active player
  # Game ? Game
  HandleActivePlayer ← (
    ⊸CheckActivePlayer
    HandleBoardClick
    HandleActionSubmission
  )

  # Receive and process net messages in online mode
  # Game ? Game
  HandleMultiplayerWait ← (
    ⊸GameMode≈Online~Tunnel
    I~Net~Get!⍣(
      °NetMessage~DoAction
      °⊸Action
      ⍜⊃Action Board(Action~New Process)
      RedrawScene RebuildScene
    | °NetMessage~ChatMessage
      ⍜Chat~Message~Sender¬
      ⍜⊙GameMode≈Online~Chat≈History⊂
    | °NetMessage~JoinRequest
      I~Net~Connect⊙(I~Net~Start!°⊸LocalPort +⚂₁₀₀ 8080)
      ⊸I~Net~Give NetMessage~JoinReject
      I~Net~End
    )
  )

  # Error if in online mode and the chat is focused
  # Used to prevent keybinds from triggering upon chat typing
  # ? Game
  CheckChatUnfocused ← °0⍣GameMode≈Online~Chat≈Focused 0

  # Handle client-side interaction with the in-game chat
  # Game ? Game
  HandleChatInteraction ← (
    I~Mouse!Pressed‼Left⋅⍣(°⊸GameMode≈Online~Chat≈Focused0|)
  
    ⍣(⊸GameMode≈Online~Chat
      °1 ⊸Chat~Focused
      I~Key~Pressed @\n
      ⨬(⍜Chat~Draft (▽⊸≠ @\t I~Key~Input)
      | ⊸Chat~Draft
        ±⊸⧻
        ⨬◌(
          Chat~Message 0 now
          ⟜⍜⊙Chat~History⊂
          NetMessage~ChatMessage
          ⊙◡⋅GameMode≈Online~Tunnel
          I~Net~Give
          °⊸Chat~Draft ""
        )
        °⊸Chat~Focused 0
      )
      °⊸GameMode≈Online~Chat
    | I~Key~Pressed‼@\n(°⊸GameMode≈Online~Chat≈Focused 1)
    | )
  
    ⍣(I~Key~Pressed‼@\t⍜GameMode≈Online~Chat≈Focused¬
      ⊸GameMode≈Online~Chat≈Draw
    | )
  )

  # Draw numbers in the corners of the screen indicating how many
  # pieces of each type remain for each player
  # ? Game
  DrawPieceCounters ← (
    ⊃Board PastView
    Board!⊃(⍣(˜⊏History|State)|NFlats|NCaps)
    ⟜¯
    ∩⌟₂(
      /◇⊂♭ ↥₀
      ⊃(∊Flat_Wall|=Cap)
      ˜∩-∩/+
    )
    °⋕⊟₄
    [20_20 20_60 [-55⊢WinSize 20] [-55⊢WinSize 60]]
    ▽2Player₁_Player₂ 40
    I~Draw~Text
  )

  # If viewing a past state, display how many moves ago it was
  # ? Game
  DrawPastMessage ← (
    ⊸±-⊸↧⊃PastView Board≈Turn
    ⨬◌(⟜(⨬""@s>1)
       Message₂ $"_ move_ ago")
  )

  # Display a clarification message that during the first two moves
  # of the game, opponents place each other's pieces
  # ? Game
  DrawBeginningMessage ← (
    <2 Board≈Turn
    ⍥(Message₁ "Place your opponent's piece")
  )

  # Serialize the game history as a Portable Tak Notation string
  # PTN ? Game
  ExportPTN ← (
    Board≈PTNRecord
    +₁°⊏≡°⊟⬚""↯∞_2
    ⬚""/◇⊂₃@\n⍚$"_. _ _"
  )

  # Game ? Board GameMode
  Call ← (
    Action~New
    ⊙I~Texture~LoadImage ∩⌟↯ ⟜⊂WinSize 4 0
    RedrawScene RebuildScene New
  )
└─╴

QueryBoardSize ← (
  &pf "Enter board size (5): "
  ⍣(∩°1⊸⊃≥₃≤₈⋕)5 &sc
)

QueryMyColor ← (
  &pf "Player [1] or player [2] (random)? "
  ⍣(-₁°1⊸∊1_2⋕|⁅⚂) &sc
)

LoadPTN ← (memo⍣(
    °□⊏1&args
    ⍣(&rs ∞ 0 &p"Enter PTN:" °"--stdin")&fras
    Action~ParsePTN
  ){})

⍢◌(&pf "[l]ocal or [o]nline? "
   ¬⊃∊⨂"lo"⬚@.⊢&sc)
⨬(Board QueryBoardSize GameMode~Local
  ∧◇Process LoadPTN
| I~Net~Start!°⊸LocalPort +⚂₁₀₀ 8080
  ⍢◌(&pf "[h]ost or [j]oin? "
     ¬⊃∊⨂"hj"⬚@.⊢&sc)
  ⨬(⊙(˜∘ LoadPTN QueryMyColor QueryBoardSize)
    ⊸I~Net~Port
    &p $"Your code is _" Code
    &p "Waiting for opponent to join..."
    NetMessage~JoinAccept◡⋅(⤙⊙⊙◌¬)
    ˜∘⊙↓(
      Board
    | | ∧◇Process
    | °NetMessage~JoinRequest⊸(I~Net~TryGet!°⊸Block1)
      &p "Connected"
      I~Net~Connect
    | ⊸I~Net~Give
      ˜GameMode~Online)
  | &pf "Enter host's code: "
    °Code &sc
    I~Net~Port⤙I~Net~Connect
    NetMessage~JoinRequest
    ⊸I~Net~Give
    &p "Connecting..."
    ⟜I~Net~TryGet!(°⊸Block1)
    ⍣(⊙⊸°NetMessage~JoinReject
      &p "That game has already been joined!"
      ⊸I~Net~End
      &exit 1
    | )
    ⊙NetMessage~JoinAccept!⟜↓(
      Board BoardSize
    | ∧◇Process PTN
    | YourColor
    )
    ˜∘˜GameMode~Online
    &p "Connected"
  )
)

I~Open WinSize "Tak"
I~Window!°FPS 30

Game

I~Loop!Game!(
  I~Draw~Background ↯4 0
  I~Draw~Background ⊸Texture

  HandleKeyCamRotation
  HandleMouseCamRotation

  HandlePastViewing

  HandleChatInteraction

  I~Key~Pressed‼@e⍣(
    ⊸CheckChatUnfocused
    &p⊸ExportPTN
  | )

  ⍣(⊸HandleWinState
  | ⍣(⊸CheckActivePlayer
      ⊸DrawBeginningMessage
    | Message₁ "Waiting for opponent...")
    ⊸CheckChatUnfocused
    HandleActivePlayer
  | )

  ⍣(HandleMultiplayerWait|)

  ⊸DrawPieceCounters

  ⊸DrawPastMessage
)

&p⊸Game~ExportPTN

⟜↓(
  I~Texture~Unload Game~Texture
| ⍣(I~Net~End Game~GameMode≈Online~Tunnel|))
