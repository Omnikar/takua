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

┌─╴GameMode
  |Local
  # TODO: Online mode
└─╴

~GameState {GameMode ClickMap Texture Move Board}

HandleBoardClick ← I~Mouse!Pressed‼Left(
  ⊙⊸GameState~ClickMap
  ⊸±⊡⌊×◡⋅△÷WinSize˜⊟°ℂ
  ⨬◌(
    ⊙⊸⊃(♭₂⇡△◡⋅Board~State ⊃GameState~Move GameState~Board)
    ⊏-₁
    Move~ClickSquare
  
    # Opponents place each other's flats on the first two moves
    ⍣(°1<2⧻◡⋅Board~History
      °⊸Move~Place~Piece ¯1
    | ⋅Move~Uninit⍜°Move~Move∘
    | )
  
    ⟜₂°⊸⊃GameState~Move GameState~Board
    Scene
    ⍣(◡⋅GameState~GameMode
      °GameMode~Local
      °1◿₂⧻Board~History◡⋅GameState~Board
      ⍜⊃Scene~Hover Scene~State∩¯
    | )
    ∩MkVoxels Scene~IdxsAndBuild
    GameState!°⊸⊃(ClickMap|I~Texture~Image Texture)
  )
)

HandleMoveSubmission ← ⍣(
  ⊸⊃GameState~Move GameState~Board
  Process~Validate
  I~Draw~Text White 40 -50_60 WinSize ">"
  I~Key!Pressed‼(
    Arrow@>
  | Process
    ⍣(◡⋅GameState~GameMode
      °GameMode~Local
      ⍜Board~State¯
    | )
    Move
  )
  °⊸⊃GameState~Move GameState~Board
| )

Board 5
Move

I~Open WinSize "Tak"

⊙I~Texture~LoadImage ∩MkVoxels Scene~IdxsAndBuild◡Scene

GameState GameMode~Local

I~Loop!(
  HandleMoveSubmission

  HandleBoardClick

  I~Draw~Background ↯4 0
  I~Draw~Background ⊸GameState~Texture

  ⊸⊃(
    GameState~GameMode
  | Board!⊃(◿₂⧻History|State|NFlats|NCaps)GameState~Board)
  ⍥¯×=GameMode~Local
  ⟜¯
  ∩⌟₂(
    ↥₀
    /◇⊂♭
    ⊃(∊Flat_Wall|=Cap)
    ˜∩-∩(/+)
  )
  °⋕⊟₄
  [20_20 20_60 [-55⊢WinSize 20] [-55⊢WinSize 60]]
  ▽2Player₁_Player₂ 40
  I~Draw~Text
)

⊃GameState~GameMode(⊂Board!⊃History State GameState~Board)
≡&s ⍥(⍥¯◿₂°⊏) =GameMode~Local
