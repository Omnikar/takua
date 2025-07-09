# Experimental!
I ~ "git: github.com/Marcos-cat/iris"
~ "game"
  ~ Board Move Process
  ~ Cap Flat Wall
~ "render"
  ~ Player₁ Player₂
  ~ Scene

VoxelScale ← 2.5

T‼ ← &p $"_ took _" ^0 ⍜now^1

WinSize ← 700_700
# Render voxels and rescale to screen size
MkVoxels ← ▽₂⊢÷△₂⊸⊙WinSize voxels Scale: VoxelScale

Code ← ⌅(+@A⊥26|⌝⊥26-@A⌵)

┌─╴GameMode
  |Local
  |Online {
    MyColor
    OtherPort
    Tunnel
  }
└─╴

~GameState {ClickMap Texture Move Board GameMode}

RedrawScene ← (
  Scene⊸⊃GameState~Move GameState~Board

  ⍣(◡⋅GameState~GameMode
    ⍣(°GameMode~Local
      °1◿₂⧻Board~History◡⋅GameState~Board
    | °1GameMode~Online~MyColor)
    ⍜⊃Scene~Hover Scene~State∩¯
  | )

  ∩MkVoxels Scene~IdxsAndBuild
  GameState!°⊸⊃(ClickMap|I~Texture~Image Texture)
)

HandleBoardClick ← I~Mouse!Pressed‼Left(
  ⊙⊸GameState~ClickMap
  ⊸±⊡⌊×◡⋅△÷WinSize˜⊟°ℂ
  ⨬◌(
    ⊙⊸⊃(♭₂⇡△◡⋅Board~State ⊃GameState~Move GameState~Board)
    ⊏-₁
    Move~ClickSquare
  
    # Opponents place each other's flats on the first two moves
    ⍣(°1<2⧻◡⋅Board~History
      ⍣(°⊸Move~Place~Piece ¯1|⋅Move~Uninit⍜°Move~Move∘)
    | )
  
    °⊸⊃GameState~Move GameState~Board
    RedrawScene
  )
)

HandleMoveSubmission ← ⍣(
  ⊸⊃GameState~Move GameState~Board
  Process~Validate
  I~Draw~Text White 40 -50_60 WinSize ">"
  I~Key!Pressed‼(
    {Arrow@> Space @\n}
  | ⍣(◡⊙⋅(GameMode~Online~Tunnel GameState~GameMode)
      I~Net~Give ⍣⍜Move~Place~Piece¯∘
    | )
    Process
    ⍣(◡⋅GameState~GameMode
      °GameMode~Local
      ⍜Board~State¯
    | )
    Move
  )
  °⊸⊃GameState~Move GameState~Board
| )

DrawPieceCounters ← (
  ⊸⊃(
    GameState~GameMode
  | Board!⊃(◿₂⧻History|State|NFlats|NCaps)GameState~Board)
  ⍥¯×≍GameMode~Local
  ⟜¯
  ∩⌟₂(
    ↥₀
    /◇⊂♭
    ⊃(∊Flat_Wall|=Cap)
    ˜∩-∩/+
  )
  °⋕⊟₄
  [20_20 20_60 [-55⊢WinSize 20] [-55⊢WinSize 60]]
  ▽2Player₁_Player₂ 40
  I~Draw~Text
)

⍢◌(&pf "[l]ocal or [o]nline? "
   ¬⊃∊˜⊗"lo"⊢&sc)
⨬GameMode~Local(
  I~Net~Start LocalPort:+⚂₁₀₀ 8080
  ⊸I~Net~Port
  ⟜(&p $"Your code is _" Code)
  &pf "Enter opponent's code: "
  °Code &sc
  ⊃>⟜𝄐I~Net~Connect
  GameMode~Online
)

Board 5
Move

I~Open WinSize "Tak"
I~Window!°FPS 30

⊙I~Texture~LoadImage ∩MkVoxels Scene~IdxsAndBuild◡Scene

GameState

I~Loop!(
  ⊸GameState~GameMode
  ⍣(⍣°GameMode~Local(
      ◌°.◿₂⧻Board~History◡⋅GameState~Board GameMode~Online~MyColor
    )
    HandleBoardClick
    HandleMoveSubmission
  | ˜⊏Player₂_Player₁ GameMode~Online~MyColor
    I~Draw~Text ⊙(30 100_100 "Waiting for opponent...")
    GameMode~Online~Tunnel⊸GameState~GameMode
    I~Net~Get!(
      °⊸GameState~Move
      ⍜⊃(GameState~Move|GameState~Board)(Move Process)
      RedrawScene
    )
  )

  I~Draw~Background ↯4 0
  I~Draw~Background ⊸GameState~Texture

  DrawPieceCounters
)

⊃GameState~GameMode(⊂Board!⊃History State GameState~Board)
≡&s ⍥(⍥¯◿₂°⊏) ≍GameMode~Local
