# Experimental!

~ "game.ua"
  ~ Board Move Process
  ~ Cap Flat Wall

BoardBase    ← ÷255[181 139 62]
BoardBorders ← +0.01Black
BoardTrim    ← ÷255[84 38 18]
Player₁      ← ÷255[224 220 195]
Player₂      ← ÷255[43 43 41]

BoardPadding     ← 0.3
BoardThickness   ← 0.6
BoardBorderWidth ← 0.05
BoardTrimWidth   ← 0.02

FlatWidth     ← 0.7
FlatThickness ← 0.25

VoxelRes ← 25

BoardModel ← memo(
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
)

FlatModel ← memo(
  ⊸△˜⊏Player₂_Player₁↥₀
  ↯⊂⁅×VoxelRes[FlatThickness.FlatWidth]
  ⍜°⍉⊂⊙1
)

WallModel ← memo(⤸₁FlatModel)

CapModel ← memo(
  ⊟0⬚1↙₄˜⊏Player₂_Player₁↥₀
  ⌵˙⊞ℂ-⊸¬÷⟜⇡×2VoxelRes
  ⍜×(⇡⁅)×2VoxelRes0.5
  [0.1 0.2 0.4 0.5]
  ⊗1⍉⊸≤⌟
  ⨬(+0.1×10˙×|0.2|+0.16×4˙×-0.3|0.2)
  ⊏⇌⊞<
  # ⍜(↙₃°⍉⊢)≡₀⋅0
)

# ? Coord Model
PlaceModel ← ⌝↘⁅⍜°⊂⊓(
  ×VoxelRes+BoardThickness×FlatThickness
| +÷₂-↘₁◡⋅⋅△₃⟜×VoxelRes+BoardPadding)

┌─╴Scene
  ~ {
    # The board state to draw
    Board
    # Hovering pieces
    Hover ← []
    # Hovering pieces position
    HoverPos ← 0_0
  }
└─╴

Board 5

⍜(°□ ⊡1_2 Board~State|⋅[¯Cap Flat .¯Flat])
⍜(°□ ⊡3_2 Board~State|⋅[¯Wall Flat])
⍜(°□ ⊡3_1 Board~State|⋅[Flat])
⍜(°□ ⊡2_1 Board~State|⋅[Wall ¯Flat Flat])
⍜(°□ ⊡3_3 Board~State|⋅[Cap])
⍜(°□ ⊡2_2 Board~State|⋅[Wall])
⍜(°□ ⊡1_3 Board~State|⋅[Wall])

Scene Board~State
Scene~Board
⟜(BoardModel⧻)
⟜(-₁⊃⌵±⊡)⊚⊸≠₀°⍉⬚0≡₀◇⇌
∧(⬚0↥PlaceModel⊙⨬(FlatModel|WallModel|CapModel))

voxels Scale:2.5
&ims
