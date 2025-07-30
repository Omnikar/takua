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
    # Portable Tak Notation log of the move history
    PTNRecord ← {}
  }
  PieceCount ← ˜⊏[10_0 15_0 21_1 30_1 40_2 50_2]↥₀↧5-3
  # Create a new Board
  # Board ? Size
  Call ← New⊃(˜↯{}[0.]|↯˜⟜↯□[]|°⊟PieceCount)
  # The index of the current turn
  Turn         ← ⧻History
  ActivePlayer ← ◿₂Turn
  # Check for a winning state by completed road for both players
  CheckRoadWin ← ⊟∩(
    𝄐⌟:⊸⍉↯⊸⧻+×2⊸⇌=₀°⊏
    /∨=₃⊂⊜∩(/+◴)∊Flat_Cap≡₀◇⬚0⊢
  )⟜¯ State
  # Check for a flat win/draw when the board is filled or one player runs out of pieces
  CheckFlatWin ← (
    ♭⊃(State|NFlats|NCaps)
    ⍣(⤚⍣(
        °0↧∩⌟₂(↥˜∩-∩/+⊃(∊Flat_Wall|=Cap)/◇⊂↥₀)⟜¯
      | °1/×±≡◇⧻)
      ⊟⊃≤≥∩/+∩⌞=Flat⟜¯≡◇⬚0⊢
    )0_0
  )
└─╴

┌─╴Action
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

  ClickSquareImpl ↚ |3.2 (
    ⍣( # If a move hasn't been started yet
      °Uninit :
      # Check if the square is occupied
      ⊡◡⊙Board~State
      # If empty, start a place
      # Otherwise, check that the active player
      # controls this square and start a move
      ⍣(Move 1 0_0 [] ⍩°1±◇⊢|ClickSquareImpl⤙Place⋅0)
    | SwitchPlacement
    | PickUpPieces
    | MovePieces
    | # If nothing else works, restart the move and try again
      ⨬(ClickSquareImpl ⊙⋅Uninit)◌ ≍Uninit⊸:
    )

    # Opponents place each other's flats on the first two turns
    <2◡⋅Board~Turn
    ⍥⍣(°⊸Place~Piece¯1|⋅Uninit)
  )

  ClickSquare ← (
    # Change between positive representing player 1 and representing the active player
    FlipPlayer₂ ← (⌅(^0|^0))!(
      ◡⋅Board~ActivePlayer
      ⍥⊓⍣⍜Place~Piece¯∘⍜Board~State¯
    )

    ⍜⊙FlipPlayer₂ ClickSquareImpl
  )

  # Format a move in Portable Tak Notation
  Fmt ← (
    FmtPos ← ⌅($"__"˜∩+@a1°⊟|⍜°⊟⊓(-@a|-₁⋕))
    ⌅(⍣(""°Uninit
      | ⌵°Place
        ⊂⊓⍣(
          ""°Flat
        | "S"°Wall
        | "C"°Cap
        )FmtPos
      | ⊙𝄐⌟:°Move
        /◇⊂{⊓(⍣(""°1)°⋕|FmtPos|˜⊏"+>-<"˜⊗A₂|⍣(""°1⧻|°⋕°⊥₁₀))})
    | ⍣(↘₁⊢regex"([1-9]*)([a-h][1-8])([+>\\-<])([1-9]*).*?"
        ⬚1⋕°□₄
        ⊃⊙⊓°FmtPos(˜⊡A₂⊗⊙"+>-<")𝄐𝄐(⊥₁₀⬚∘⋕)
        Move⊙⤚⋅⊙∘
      | ↘₁⊢regex"([SC]?)([a-h][1-8]).*?"
        Place ⊓(+₁⊗⊙"FSC"⬚@F⊢)°FmtPos °□₂)
    )
  )

  # Actions ? PTNString
  ParsePTN ← (
    # Strip metadata
    ⍢∘⍣(1◌°$"[_]\n_")0

    ⊜□¬⊸∊" \n"
    ∩⌟▽⟜¬±◿₃°⊏
    :⍚°Fmt
    ≠⟜(↙⧻)◿₂⇡◡⋅⧻▽2=□"1."
    ⍚⍥⍣⍜Place~Piece¯∘
  )
└─╴

# Transform board state based on a move
┌─╴Process
  # Process a placement
  ProcessPlace ← (
    Action~Place!⊃Pos Piece
    ˜⌟⍜(°□⊡⊙Board~State)⊂
  )
  # Process a movement
  ProcessMove ← Action~Move!⟜↓(
    ⊃Num Orig
    ⍜⊙⊙(°□⊡|Board~State)⊃↙↘
  | ⊃(⇌Amnts|¤Dir|Orig)
    ∧(⊃↘↙¯⊙:⊙+
      ⊃⋅⋅∘⊙⍜⊙(°□⊡⊙Board~State)⊂)
    ⋅◌
    # Flatten walls
    ⍜Board~State⍚₀⍜(⌵↘₁|↧Flat)
  )
  # Assert that a move is completely formed
  Validate ← °1⊸Action!⍣(0°Uninit|=/+Move!⊃Amnts Num|1)
  Call ← (
    Validate
  
    # PTN OldState Board ? Action Board
    ⊃⊓Action~Fmt Board~State⍣ProcessPlace ProcessMove
  
    # Check if a wall was flattened, appending an asterisk to the PTN if so
    ◡⋅⊙Board~State
    /∨♭×˜∩=Wall Cap∩(⌵≡₀◇⬚0⊢)
    ⤙⊙⊙◌ □⍥(˜⊂@*)
  
    ⍜Board~PTNRecord⊂
    ⍜Board~History⊂
  )
└─╴
