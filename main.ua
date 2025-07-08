# Experimental!
I ~ "git: github.com/Marcos-cat/iris"
~ "game"
  ~ Board Move Process
  ~ Cap Flat Wall
~ "render" ~ Scene

VoxelScale ← 2.5

T‼ ← &p $"_ took _" ^0 ⍜now^1

WinSize   ← 500_500
DrawBoard ← ⊸I~Draw~Background
# Render voxels and rescale to screen size
MkVoxels ← ▽₂⊢÷△₂⊸⊙WinSize voxels Scale: VoxelScale

Board 5
⍜(°□ ⊡1_2 Board~State|⋅[Cap Flat ¯Flat Flat])
⍜(°□ ⊡2_2 Board~State|⋅[¯Flat])
⍜(°□ ⊡3_2 Board~State|⋅[¯Wall])
⍜(°□ ⊡2_3 Board~State|⋅[¯Flat])
⍜(°□ ⊡2_4 Board~State|⋅[¯Flat Flat])
Move

I~Open WinSize "Tak"

⊙I~Texture~LoadImage ∩MkVoxels Scene~IdxsAndBuild◡Scene

I~Loop!(
  I~Mouse!Pressed‼Left(
    ⊸±⊸⊡⌊×◡⋅△÷WinSize˜⊟°ℂ
    ⨬◌(
      𝄐:
      ⊙⊙↓(
        ♭₂⇡△◡⋅Board~State
      | Move~ClickSquare⊏-₁
      )
      Scene~IdxsAndBuild◡⋅Scene
      ∩MkVoxels
      ⊙°⊸I~Texture~Image
    )
  )

  I~Draw~Background ↯4 0
  ⊙DrawBoard
)
