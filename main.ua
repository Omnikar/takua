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

Code ← ⌅(+@A⊥26|⌝⊥26-@A⌵)
# Normalized spherical to rectangular coordinates
SphToRect ← ˜⊂×⍜°⊟∩°∠

# Render voxels and rescale to screen size
# ? Voxels CamPos
MkVoxels ← ▽₂⊢÷△₂⊸⊙WinSize voxels!°⊸⊃Scale Camera VoxelScale SphToRect ˜∘
Message₁ ← I~Draw~Text White 30 100_100
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

DefaultCamPos ← [5π/4 ∠√2 1]

~GameState {
  IdxVoxels
  BoardVoxels
  ClickMap
  Texture
  Action
  Board
  GameMode
  CamPos ← DefaultCamPos
  # Turn to view; ∞ means present
  PastView ← ∞
}

┌─╴NetMessage
  |JoinRequest {MyPort}
  |JoinAccept {BoardSize YourColor PTN}
  |JoinReject
  |DoAction {Action}
  |ChatMessage {Message}
└─╴

RebuildScene ← (
  # If PastView is ∞, create a scene out of the present
  # Otherwise, make one out of the corresponding past state
  ⊸GameState~PastView
  ⍣(GameState!⊸⊃Action Board °∞
  | Action°⊸Board~State⊏⊙(⊸Board~History⊸GameState~Board))

  Scene≈IdxsAndBuild
  GameState!°⊸⊃IdxVoxels BoardVoxels
)

RedrawScene ← (
  ∩⌟MkVoxels GameState!⊸⊃(IdxVoxels|BoardVoxels|CamPos)
  GameState!°⊸⊃(ClickMap|I~Texture~Image Texture)
)

HandleCamRotation ← (
  ⊸≠₀/+I~Key~ULDR 0
  ⨬◌(×I~Window~Dt⊟¯°ℂ
     ⍜⊙GameState~CamPos(⍜°⊟⊓(◿τ|↥0.08↧-0.08 π)-)
     RedrawScene)

  I~Key~Pressed‼@r(
    °⊸GameState~CamPos DefaultCamPos
    RedrawScene
  )
)

HandlePastViewing ← (
  ⊸⌵-∩I~Key~Pressed @- @=
  ⨬◌(
    ⊙(⊸⊃GameState~PastView GameState~Board≈Turn
      ⍥⋅⟜∘⊸=∞)
    I~Key!(∨∩Down LeftShift RightShift)
    ⨬+(∪⨬0 ∞↥₀)
    ⍥⋅∞⤚≤↥₀
    °⊸GameState~PastView
    RedrawScene RebuildScene
  )
)

HandleBoardClick ← I~Mouse!Pressed‼Left(
  ⊙⊸GameState~ClickMap
  ⊸±⊡⌊×◡⋅△÷WinSize˜⊟°ℂ
  ⨬◌(
    ⊙⊸⊃(♭₂⇡△◡⋅Board~State GameState!⊃Action Board)
    ⊏-₁
    Action~ClickSquare
  
    GameState!°⊸⊃Action Board
    °⊸GameState~PastView ∞
    RedrawScene RebuildScene
  )
)

HandleActionSubmission ← ⍣(
  GameState!⊸⊃Action Board
  Process~Validate
  I~Draw~Text White 40 -50_60 WinSize ">"
  I~Key!Pressed‼Space(
    ⍣(◡⊙⋅GameState~GameMode≈Online~Tunnel
      NetMessage~DoAction
      I~Net~Give
    | )
    Process
    Action
  )
  GameState!°⊸⊃Action Board
| )

HandleWinState ← (
  ⊸GameState~Board
  Board!⍣(
    ⟜(°1⊸/↥CheckRoadWin)
    # Bias for the player that was just active in case of a double road
    ⍜⊏(+0.1) ¬ActivePlayer
  | °1⊸/↥CheckFlatWin)
  # Don't draw the game end message if viewing a past move
  ⍣(°1≠∞⋅⊸GameState~PastView
  | Message₁ "Draw" °1_1
  | ⊢⍖
    ⍣(=◡⋅GameState~GameMode≈Online~MyColor
      {"You lose!" "You win!"}
    | {"White wins!" "Black wins!"})
    Message₁ ˜⊏
  )
)

CheckActivePlayer ← (
  ⊸GameState~GameMode
  ⍣°GameMode~Local(
    ◌°⟜∘◡⋅GameState~Board≈ActivePlayer GameMode~Online~MyColor
  )
)

HandleActivePlayer ← (
  CheckActivePlayer
  HandleBoardClick
  HandleActionSubmission
)

HandleMultiplayerWait ← (
  ⊸GameState~GameMode≈Online~Tunnel
  I~Net~Get!⍣(
    °NetMessage~DoAction
    °⊸GameState~Action
    ⍜GameState!⊃Action Board(Action Process)
    RedrawScene RebuildScene
  | °NetMessage~ChatMessage
    ⍜Chat~Message~Sender¬
    ⍜⊙GameState~GameMode≈Online~Chat≈History⊂
  | °NetMessage~JoinRequest
    I~Net~Connect⊙(I~Net~Start!°⊸LocalPort +⚂₁₀₀ 8080)
    ⊸I~Net~Give NetMessage~JoinReject
    I~Net~End
  )
)

HandleChatInteraction ← (
  I~Mouse!Pressed‼Left⋅⍣(°⊸GameState~GameMode≈Online~Chat≈Focused0|)

  ⍣(⊸GameState~GameMode≈Online~Chat
    °1 ⊸Chat~Focused
    I~Key~Pressed @\n
    ⨬(⍜Chat~Draft (▽⊸≠ @\t I~Key~Input)
    | ⊸Chat~Draft
      ±⊸⧻
      ⨬◌(
        Chat~Message 0 now
        ⟜⍜⊙Chat~History⊂
        NetMessage~ChatMessage
        ⊙◡⋅GameState~GameMode≈Online~Tunnel
        I~Net~Give
        °⊸Chat~Draft ""
      )
      °⊸Chat~Focused 0
    )
    °⊸GameState~GameMode≈Online~Chat
  | I~Key~Pressed‼@\n(°⊸GameState~GameMode≈Online~Chat≈Focused 1)
  | )

  ⍣(I~Key~Pressed‼@\t⍜GameState~GameMode≈Online~Chat≈Focused¬
    ⊸GameState~GameMode≈Online~Chat≈Draw
  | )
)

DrawPieceCounters ← (
  GameState!⊸⊃Board PastView
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

DrawPastMessage ← (
  ⊸±-⊸↧⊸⊃GameState~PastView GameState~Board≈Turn
  ⨬◌(⟜(⨬""@s>1)
     Message₂ $"_ move_ ago")
)

DrawBeginningMessage ← (
  <2 ⊸GameState~Board≈Turn
  ⍥(Message₁ "Place your opponent's piece")
)

ExportPTN ← (
  ⊸GameState~Board≈PTNRecord
  +₁°⊏≡°⊟⬚""↯∞_2
  ⬚""/◇⊂₃@\n⍚$"_. _ _"
)

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
    ⟜(I~Net~TryGet!°⊸Block1)
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

# TODO: Turn this into GameState~Call if it becomes possible
NewGameState ← (
  ⊙I~Texture~LoadImage ∩⌟↯ ⟜⊂WinSize 4 0
  ⟜∘ °△0_0_0
  GameState
  RedrawScene RebuildScene
)

Action

I~Open WinSize "Tak"
I~Window!°FPS 30

NewGameState

I~Loop!(
  I~Draw~Background ↯4 0
  I~Draw~Background ⊸GameState~Texture

  HandleCamRotation

  HandlePastViewing

  I~Key~Pressed‼@e(&p ExportPTN)

  HandleChatInteraction

  ⍣(HandleWinState
  | ⍣(CheckActivePlayer
      DrawBeginningMessage
    | Message₁ "Waiting for opponent...")
    °0 ⍣⊸GameState~GameMode≈Online~Chat≈Focused0
    HandleActivePlayer
  | )

  ⍣(HandleMultiplayerWait|)

  DrawPieceCounters

  DrawPastMessage
)

&p ExportPTN

⟜↓(
  I~Texture~Unload GameState~Texture
| ⍣(I~Net~End GameState~GameMode≈Online~Tunnel|))
