# Experimental!

Flat ← 1
Wall ← 2
Cap  ← 3

┌─╴Board
  ~ {
    # All past board states
    History
    # The current board state
    State
    # Flat stones per player
    NFlats
    # Capstones per player
    NCaps
  }
  PieceCount ← ˜⊏[15_0 21_1 30_1 40_2 50_2]↥₀↧₄-₄
  # Create a new Board
  # Board ? Size
  Call ← New⊃(˜↯{}[0.]|↯˜⟜↯□[]|°⊟PieceCount)
  # The index of the current turn
  Turn ← ⧻History
└─╴
┌─╴Move ~ ClickSquare
  # New move that has not been built yet
  |Uninit
  # Place a new piece on the board
  |Place {
    # The piece type to place
    Piece
    # The position to place at
    Pos
  }
  # Move existing pieces
  |Move {
    # The number of pieces to move
    Num
    # The direction to move in
    Dir
    # The amounts of pieces dropped at each step
    Amnts
    # The position the pieces are picked up from
    Orig
  }
  New ← Uninit

  SwitchPlacement ↚ (
    # If already placing and clicking on the same square,
    # increment the piece type to be placed
    ⍜(-₁°Place
    | ⊙°.
      ◡⋅⋅Board!⊃(State|NFlats|NCaps)
      ˜∩>∩/+⊸¬=₃▽⊸±/◇⊂♭
      ⨬(-₁⋅Cap°1)⨬(◿₂+₁|◿₃+₁)
    ):
  )

  PickUpPieces ↚ Move!(
    # If moving and clicking on the origin square
    °.◡⋅Orig
    # And nowhere else has been clicked already
    °[]◡⋅Amnts
    # Min number of stones and carry limit
    𝄐⌞(↧◇∩⧻⊸⊡⊙⊸Board~State)
    # Increment the number of stones being
    # carried and limit accordingly
    ⍜Num(↧+₁)
  )

  MovePieces ↚ Move!(
    ◡⋅Dir

    TryMove ← (
      ⊡⊙◡⋅Board~State
      # Ensure that the piece being moved
      # onto is not a capstone
      °1⊸<Cap⌵◇⬚1⊢
      # If it is a wall, ensure the piece
      # being moved is a lone capstone
      >Flat
      ⍥(°1-/+⊸⊃Amnts Num
        °Cap◇⊢⊡◡⊓Orig Board~State)

      ⍜Amnts(⊂1)
    )

    ⍣(◡⋅Orig °0_0
      𝄐⌞°⊸Dir ⍩°1⊸∊A₂⊸-
      TryMove
    | ⊙(⊸-+×⧻◡⋅⊃(Amnts|Dir|Orig))
      ⍣(TryMove◌°.|⋅⍜(⊢Amnts)+₁⋅°0_0))

    °1≥/+⊸Move!⊃Amnts Num
  )

  ClickSquare ← |3.2 ⍣(
    # If a move hasn't been started yet
    °Uninit :
    # Check if the square is occupied
    ⊡◡⊙Board~State
    # If empty, start a place
    # Otherwise, check that the active player
    # controls this square and start a move
    ⍣(Move 1 0_0 [] ⍩°1±◇⊢|ClickSquare⤙Place⋅0)
  | SwitchPlacement
  | PickUpPieces
  | MovePieces
  | # If nothing else works, restart the move and try again
    ⨬(ClickSquare⊙⋅Uninit)◌ ≍Uninit⊸:
  )
└─╴

# Transform board state based on a move
┌─╴Process
  # Process a placement
  ProcessPlace ← Move!(
    Place!⊃Pos Piece
    ˜⌟⍜(°□⊡⊙Board~State)⊂
  )
  # Process a movement
  ProcessMove ← Move~Move!⟜↓(
    ⊃Num Orig
    ⍜⊙⊙(°□⊡|Board~State)⊃↙↘
  | ⊃(⇌Amnts|¤Dir|Orig)
    ∧(⊃↘↙¯⊙:⊙+
      ⊃⋅⋅∘⊙⍜⊙(°□⊡⊙Board~State)⊂)
    ⋅◌
    # Flatten walls
    ⍜Board~State⍚₀⍜(⌵↘₁)↧₁
  )
  # Assert that a move is completely formed
  Validate ← °1⊸⍣(=/+Move~Move!⊃Amnts Num)1
  Call ← (
    Validate
    ⊃⍣ProcessPlace ProcessMove⋅Board~State
    ⍜Board~History⊂
  )
└─╴

# Board 5

# ⍜(°□ ⊡1_2 Board~State|⋅[Cap Flat ¯Flat])
# ⍜(°□ ⊡3_2 Board~State|⋅[¯Wall])

# Move
# ClickSquare 1_1
# Process

# Move
# [
#   1_2
#   1_2
#   1_2
#   2_2
#   2_2
#   3_2
# ]
# ∧ClickSquare
# Process
