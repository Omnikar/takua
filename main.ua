# Experimental!
I ~ "git: github.com/Marcos-cat/iris"
~ "game"
  ~ Board Move Process
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
MkVoxels ← ▽₂⊢÷△₂⊸⊙WinSize voxels (Scale:VoxelScale) ⊙(Camera:SphToRect)
Message₁ ← I~Draw~Text White 30 100_100
Message₂ ← I~Draw~Text White 30 100_140

┌─╴GameMode
  |Local
  |Online {
    MyColor
    Tunnel
  }
└─╴

~GameState {
  ClickMap
  Texture
  Move
  Board
  GameMode
  CamPos ← [5π/4 ∠√2 1]
  # Turn to view; ∞ means present
  PastView ← ∞
}

┌─╴NetMessage
  |JoinRequest {MyPort}
  |JoinAccept {BoardSize YourColor PTN}
  |MakeMove {Move}
└─╴

RedrawScene ← (
  # If PastView is ∞, create a scene out of the present
  # Otherwise, make one out of the corresponding past state
  ⊸GameState~PastView
  ⍣(⊸⊃GameState~Move GameState~Board °∞
  | Move°⊸Board~State⊏⊙(⊸Board~History⊸GameState~Board))

  Scene

  ∩⌟MkVoxels Scene~IdxsAndBuild ⊙⊸GameState~CamPos
  GameState!°⊸⊃(ClickMap|I~Texture~Image Texture)
)

HandleCamRotation ← (
  ⊸≠₀/+I~Key~ULDR 0
  ⨬◌(×I~Window~Dt⊟¯°ℂ
     ⍜⊙GameState~CamPos-
     RedrawScene)
)

HandlePastViewing ← (
  ⊸⌵-∩I~Key~Pressed @- @=
  ⨬◌(⊙(⊸⊃GameState~PastView(Board~Turn GameState~Board)
       ⍥⋅.⊸=∞)
     ⍥⋅∞⤚≤↥₀+
     °⊸GameState~PastView
     RedrawScene)
)

HandleBoardClick ← I~Mouse!Pressed‼Left(
  ⊙⊸GameState~ClickMap
  ⊸±⊡⌊×◡⋅△÷WinSize˜⊟°ℂ
  ⨬◌(
    ⊙⊸⊃(♭₂⇡△◡⋅Board~State ⊃GameState~Move GameState~Board)
    ⊏-₁
    Move~ClickSquare
  
    °⊸⊃GameState~Move GameState~Board
    °⊸GameState~PastView ∞
    RedrawScene
  )
)

HandleMoveSubmission ← ⍣(
  ⊸⊃GameState~Move GameState~Board
  Process~Validate
  I~Draw~Text White 40 -50_60 WinSize ">"
  I~Key!Pressed‼(
    {Space @\n}
  | ⍣(◡⊙⋅(GameMode~Online~Tunnel GameState~GameMode)
      I~Net~Give
    | )
    Process
    Move
  )
  °⊸⊃GameState~Move GameState~Board
| )

HandleWinState ← (
  ⊸GameState~Board
  ⍣(⟜(°1⊸/↥Board~CheckRoadWin)
    ⍣(◡⋅⋅GameState~GameMode◿₂Board~Turn
      =GameMode~Online~MyColor
    )⋅1
    # Bias for the active player in case of a double road
    ⍜⊏(+0.1)
  | °1⊸/↥ Board~CheckFlatWin)
  ⍣(Message₁ "Draw" °1_1
  | ⊢⍖
    ⍣(◡⋅⊃GameState~GameMode GameState~Board
      °GameMode~Local
      ≠◿₂Board~Turn
      {"White wins!" "Black wins!"}
    | {"You win!" "You lose!"})
    Message₁˜⊏)
)

HandleActivePlayer ← (
  ⊸GameState~GameMode
  ⍣°GameMode~Local(
    ◌°.◿₂Board~Turn◡⋅GameState~Board GameMode~Online~MyColor
  )
  HandleBoardClick
  HandleMoveSubmission
)

HandleMultiplayerWait ← (
  ⊸GameState~GameMode
  GameMode~Online~Tunnel
  Message₁ "Waiting for opponent..."
  I~Net~Get!(
    °⊸GameState~Move
    ⍜⊃(GameState~Move|GameState~Board)(Move Process)
    RedrawScene
  )
)

DrawPieceCounters ← (
  ⊸⊃GameState~Board GameState~PastView
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
  ⊸±-⊸↧⊸⊃GameState~PastView(Board~Turn GameState~Board)
  ⨬◌(⟜(⨬""@s>1)
     # TODO: Fix this overlapping with "Waiting for opponent..."
     Message₂ $"_ move_ ago")
)

ExportPTN ← (
  Board~PTNRecord⊸GameState~Board
  +₁°⊏≡°⊟⬚""↯∞_2
  ⬚""/◇⊂₃@\n⍚$"_. _ _"
)

QueryBoardSize ← (
  &pf "Enter board size (5): "
  ⍣(∩°1⊸⊃≥₄≤₈⋕)5 &sc
)

QueryMyColor ← (
  &pf "Player [1] or player [2] (random)? "
  ⍣(-₁°1⊸∊1_2⋕|⁅⚂) &sc
)

LoadPTN ← (memo⍣(
    °□⊏1&args
    ⍣(&rs ∞ 0 &p"Enter PTN:" °"--stdin")&fras
    Move~ParsePTN
  ){})

⍢◌(&pf "[l]ocal or [o]nline? "
   ¬⊃∊˜⊗"lo"⬚@.⊢&sc)
⨬(Board QueryBoardSize GameMode~Local
  ∧◇Process LoadPTN
| I~Net~Start LocalPort:+⚂₁₀₀ 8080
  ⍢◌(&pf "[h]ost or [j]oin? "
     ¬⊃∊˜⊗"hj"⬚@.⊢&sc)
  ⨬(⊙(:LoadPTN QueryMyColor QueryBoardSize)
    ⊸I~Net~Port
    &p $"Your code is _" Code
    &p "Waiting for opponent to join..."
    NetMessage~JoinAccept◡⋅(𝄐⌟:¬)
    :⊙↓(
      Board
    | | ∧◇Process
    | °NetMessage~JoinRequest⊸(I~Net~Get Block:1)
      &p "Connected"
      I~Net~Connect
    | ⊸I~Net~Give
      ˜GameMode~Online)
  | &pf "Enter host's code: "
    °Code &sc
    I~Net~Port⤙I~Net~Connect
    NetMessage~JoinRequest
    ⊸I~Net~Give
    ⟜(I~Net~Get Block:1)
    ⊙NetMessage~JoinAccept!⟜↓(
      Board BoardSize
    | ∧◇Process PTN
    | YourColor
    )
    :˜GameMode~Online
  )
)

Move

I~Open WinSize "Tak"
I~Window!°FPS 30

⊙I~Texture~LoadImage ∩⌟↯ ⟜⊂WinSize 4 0

GameState

RedrawScene

I~Loop!(
  HandleCamRotation

  HandlePastViewing

  I~Key~Pressed‼@e(&p ExportPTN)

  ⍣(HandleWinState
  | HandleActivePlayer
  | HandleMultiplayerWait)

  I~Draw~Background ↯4 0
  I~Draw~Background ⊸GameState~Texture

  DrawPieceCounters

  DrawPastMessage
)

◌&p ExportPTN
