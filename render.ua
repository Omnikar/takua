# Experimental!
~ "git: github.com/Omnikar/uiua-math" ~ FFTConvolve

~ "game"
  ~ Board Move Process
  ~ Cap Flat Wall

T‼ ← &p $"_ took _" ^0 ⍜now^1

BoardBase    ← ÷255[181 139 62]
BoardBorders ← +0.01Black
BoardTrim    ← ÷255[84 38 18]
Player₁      ← ÷255[224 220 195]
Player₂      ← ÷255[43 43 41]
# Player₂ ← ÷255[79 56 27]

BoardPadding     ← 0.3
BoardThickness   ← 0.6
BoardBorderWidth ← 0.05
BoardTrimWidth   ← 0.02

FlatWidth     ← 0.7
FlatThickness ← 0.25

VoxelRes ← 25

ApplyLighting ← (
  ⊸♭°⍉↯⟜↯5⇌[0 0 0 1 2]⊣⊸°⍉
  ×¬×0.3FFTConvolve~Same÷/+
)

BoardModel ← T‼"\nBoardModel"memo(
  ⍜(×⊙-|⇡⁅)VoxelRes⊸⊃¯+BoardPadding
  ⊃(×⊓⌟><⊃¯+÷₂BoardBorderWidth :
  | <÷₂BoardBorderWidth⌵-⊸⁅)
  ×⊓˙⊞×˙⊞↥
  ˜⊏[BoardBase BoardBorders]
  ⊂BoardBase↯⁅×BoardThickness VoxelRes
  ÷VoxelRes↧⇌⊸≡(⇌|⇌)⇡⊸△₃
  ⊚≥2/+°⍉<BoardTrimWidth
  ⍜⊡≡⋅BoardTrim
  ⍜°⍉⊂⊙1
  # ApplyLighting
)

BoardIdxModel ← T‼"BoardIdxModel"memo(
  ⍜(×⊙-|⇡⁅)VoxelRes⊸⊃¯+BoardPadding
  -₁÷⊸±˜◿⊸∩+₁⌊
  ↧⊸↥0+₁˜⌝⊥˙⊞˜⊟
  ↯+₁⁅×BoardThickness VoxelRes
)

RawFlatModel ← T‼"RawFlatModel"(
  ⊸△˜⊏Player₂_Player₁↥₀
  ↯⊂⁅×VoxelRes[FlatThickness.FlatWidth]
  ⍜°⍉⊂⊙1
)

FlatModel ← T‼"FlatModel"memo(
  RawFlatModel
  # ApplyLighting
)

WallModel ← T‼"WallModel"memo(
  ⤸₁RawFlatModel
  # ApplyLighting
)

CapModel ← T‼"CapModel"memo(
  ⊟0⬚1↙₄˜⊏Player₂_Player₁↥₀
  ⌵˙⊞ℂ-⊸¬÷⟜⇡×2VoxelRes
  ⍜×(⇡⁅)×2VoxelRes0.5
  [0.1 0.2 0.4 0.5]
  ⊗1⍉⊸≤⌟
  ⨬(+0.1×10˙×|0.2|+0.16×4˙×-0.3|0.2)
  ⊏⇌⊞<
  # ApplyLighting
)

# ? Coord Model
PlaceModel ← ⌝↘⁅⍜°⊂⊓(
  ×VoxelRes+BoardThickness×FlatThickness
| +÷₂-↘₁◡⋅⋅△₃⟜×VoxelRes+BoardPadding)

# ? Coords Pieces Board
PlacePieces ← ∧(⬚0↥PlaceModel⊙⨬(FlatModel|WallModel|CapModel))⊙(-₁⊃⌵±)

┌─╴Scene
  ~ {
    # Hovering pieces position
    HoverPos
    # Hovering pieces
    Hover
    # The board state to draw
    State
  }

  # ? Move Board
  Call ← (
    New Move!⍣(
      0_0 [] ⊓°Uninit Board~State
    | # :¤⊓°Place Board~State
      0_0 [] ⍜⊙(°□⊡)⊂⊓°Place Board~State
    | Move!⟜↓(
      | -/+⊃(Amnts|Num|Orig)
        ⍜⊙⊙(°□⊡|Board~State)⊃↙↘
      | °⊸Num/+⊸Amnts
        𝄐⌟Process~ProcessMove
        :Board~State
      | +×⊃(⧻Amnts|Dir|Orig)
      )
    )
  )

  # Create a voxels model of the scene
  Build ← (
    # Draw normal pieces
    ⟜(State
      ⟜(BoardModel⧻)
      ⟜⊡⊚⊸≠₀°⍉⬚0≡₀◇⇌
      PlacePieces)

    # Draw hover pieces
    ⟜↓(
      °⊏⇌Hover
    | :HoverPos
    | ⊃HoverPos State
      ≡⌟⊂ +2+◇⧻⊡
      PlacePieces
    )
  )

  # IdxsVoxels BoardVoxels ? Scene
  IdxsAndBuild ← (
    ⊃State Build
    ⬚0↙◡⋅⧻BoardIdxModel⧻
  )
└─╴
