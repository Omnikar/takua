# Experimental!
~ "git: github.com/Omnikar/uiua-math" ~ BoxMuller FFTConvolve

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

ShadowFactor ← 0.5
OffsetFactor ← 0.015

VoxelRes ← 25

ApplyLighting ← (
  ⊸♭°⍉↯⟜↯5⇌[0 0 0 1 2]⊣⊸°⍉
  ⍜⊙(↙₃°⍉)×⌞¬×ShadowFactor FFTConvolve~Same÷/+
)
HollowChannel ← ×<6⁅FFTConvolve~Same↯˙↯3⋯4281360⊸±
HollowModel   ← ⍜(⊣°⍉)HollowChannel

BoardModel ← memo(
  ⍜(×⊙-|⇡⁅)VoxelRes⊸⊸⊃¯+BoardPadding
  ⊃(×⊓⌟><⊃¯+÷₂BoardBorderWidth :
  | <÷₂BoardBorderWidth⌵-⊸⁅)
  ×⊓˙⊞×˙⊞↥
  ˜⊏[BoardBase BoardBorders]
  ⊂BoardBase↯⁅×BoardThickness VoxelRes
  ÷VoxelRes↧⇌⊸≡(⇌|⇌)⇡⊸△₃
  ⊚≥2/+°⍉<BoardTrimWidth
  ⍜⊡≡⋅BoardTrim
  ⍜°⍉⊂⊙1

  # Coordinate labels
  # TODO: Fix mirrored labels on the back of the board
  CoordLabel ← (
    ⟜layout⁅×VoxelRes BoardThickness
    √≡↻¯⌊÷₂˜-⟜(⧻₁⤙⬚0↙˜⊟) VoxelRes
  )
  ⇌°⋕∩⌟+1@a⇡:
  ≡⇌∩(⇌/≡⊂≡CoordLabel)
  ∩(≡⌝↘⁅×VoxelRes BoardPadding)
  ⊓˜⊟⊙(⬚1↙₄BoardBorders)
  ⊙◌∧(⤸0_2⊸⍜⊙⍜°⍉-⬚0×)

  ApplyLighting
  HollowModel
)

BoardIdxModel ← memo(
  ⍜(×⊙-|⇡⁅)VoxelRes⊸⊃¯+BoardPadding
  -₁÷⊸±˜◿⊸∩+₁⌊
  ↧⊸↥0+₁˜⌝⊥˙⊞˜⊟
  ↯+₁⁅×BoardThickness VoxelRes
  HollowChannel
)

RawFlatModel ← (
  ⊸△˜⊏Player₂_Player₁↥₀
  ↯⊂⁅×VoxelRes[FlatThickness.FlatWidth]
  ⍜°⍉⊂⊙1
)

FlatModel ← memo(
  RawFlatModel
  ApplyLighting
  HollowModel
)

WallModel ← memo(
  ⤸₁RawFlatModel
  ApplyLighting
  HollowModel
)

CapModel ← memo(
  ⊟0⬚1↙₄˜⊏Player₂_Player₁↥₀
  ⌵˙⊞ℂ-1/2÷⟜⇡ ⁅×0.9 VoxelRes
  ÷-1⟜⇡ ⁅×0.7 VoxelRes
  [0.4 0.9 1]
  ⊗1⍉⊸≤⌟
  ⨬(÷4√¬˙×-1×4|+0.12×2˙×-0.6|0.3)
  ⊏⇌⊞<
  ApplyLighting
  HollowModel
)

# ? Coord Model SceneModel
PlaceModel ← (
  ⁅⍜°⊂⊓(
    ×VoxelRes+BoardThickness×FlatThickness
  | +÷₂-↘₁◡⋅⋅△₃⟜×VoxelRes+BoardPadding)
  ⍜⊙(↙⊙↘)↥ ⊙⟜₂(⬚0⍜⊙△₃↥+) ⟜△₃:
)

# ? Coords Pieces Board
PlacePieces ← ∧(PlaceModel⊙⨬(FlatModel|WallModel|CapModel))⊙(-₁⊃⌵±)

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

    ⬚0⍜⊙⧻↥⁅×VoxelRes+×10FlatThickness BoardThickness
  )

  # IdxsVoxels BoardVoxels ? Scene
  IdxsAndBuild ← (
    ⊃State Build
    ⬚0↙◡⋅⧻BoardIdxModel⧻
  )
└─╴
