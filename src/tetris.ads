with Display; use Display;
with Display.Basic; use Display.Basic;
with Common; use Common;
with Picture; use Picture;

package Tetris
with SPARK_Mode => On
is

   type Piece_Colour_Type is array (Piece_Type) of Color_Type;

   Piece_Colour_Map : constant Piece_Colour_Type := (Magenta, Red, Yellow,
                                                     Green, Cyan, Blue,
                                                     Black, White);

   type Coord_2D is record
      X_Pos : X_Coord := X_Coord'First;
      Y_Pos : Y_Coord := Y_Coord'First;
   end record;

   Coord_Offset : constant Integer := 100;
   Box_Size : constant Float := Float (Coord_Offset * 2) / Float (Y_Coord'Last);

   type Falling_Piece is record
      Content_Type : Piece_Type := Piece_Type'First;
      Shape : Shape_Id := Null_Shape_Id;
      X_Pos : X_Coord := 3;
      Y_Pos : Y_Coord := 0;
   end record;

   type Cell_Content is record
      Content_Type : Cell_Type := Empty;
      Piece : Falling_Piece := (others => <>);
      Locked : Boolean := False;
   end record;

   type Row_Array is array (X_Coord) of Cell_Content;

   type Board_Array is array (Y_Coord) of Row_Array;

   function Translate_X (X_Left : in X_Coord) return Float
     with Global => (null),
     Depends => (Translate_X'Result => X_Left);

   function Translate_Y (Y_Bottom : in Y_Coord) return Float
     with Global => (null),
     Depends => (Translate_Y'Result => Y_Bottom);

   function Can_Move_Down (Board : in Board_Array;
                           Cell : in Cell_Content) return Boolean
     with Global => (null),
     Depends => (Can_Move_Down'Result => (Board, Cell));

   procedure Move_Piece_Down (Board : in out Board_Array;
                              Cell : in out Cell_Content)
     with Pre => (Can_Move_Down (Board, Cell)),
     Post => (Cell.Piece'Old.Y_Pos + 1 = Cell.Piece.Y_Pos),
     Global => (null),
     Depends => (Board =>+ Cell,
                 Cell =>+ null);

   procedure Include_Piece_In_Board (Board : in out Board_Array;
                                     Piece : in Falling_Piece)
     with Post => (Board (Piece.Y_Pos)(Piece.X_Pos).Piece = Piece);

   procedure Remove_Piece_From_Board (Board : in out Board_Array;
                                      Piece : in Falling_Piece)
     with Post => (Board (Piece.Y_Pos)(Piece.X_Pos).Content_Type = Empty);

   function First_Cell_Is_Open (Board : in Board_Array;
                                 X : in X_Coord) return Boolean
   is (not Board (Y_Coord'First)(X).Locked);

   function Locked_Cell_In_Column (Board : in Board_Array;
                                   X : in X_Coord) return Boolean
   is (for some Row of Board => (Row (X).Locked)) with Ghost;

   function None_Open_After_Locked_Cell (Board : in Board_Array;
                                         X : in X_Coord) return Boolean
   is (if Locked_Cell_In_Column (Board, X) then
         (for all J in Board'Range =>
            (if Board (J)(X).Locked then
                 (for all K in J .. Y_Coord'Last =>
                  (Board (K)(X).Locked))))) with Ghost;

   function Lower_Squares_Are_Locked (Board : in Board_Array;
                                      Coord : in Coord_2D) return Boolean
   is (if Coord.Y_Pos < Y_Coord'Last then
         (for all J in Coord.Y_Pos + 1 .. Y_Coord'Last =>
             Board (J)(Coord.X_Pos).Locked)) with Ghost;

   function Is_Coord_Locked(Board : in Board_Array;
                            Coord : in Coord_2D) return Boolean
   is (Board (Coord.Y_Pos)(Coord.X_Pos).Locked) with Ghost;

   function Get_Next_Coord (Board : Board_Array;
                            Next_X : X_Coord) return Coord_2D
     with Pre => (First_Cell_Is_Open (Board, Next_X))
     and (None_Open_After_Locked_Cell (Board, Next_X)),
     Post => (not Is_Coord_Locked (Board, Get_Next_Coord'Result))
     and (Lower_Squares_Are_Locked (Board, Get_Next_Coord'Result)),
     Global => (null),
     Depends => (Get_Next_Coord'Result => (Next_X, Board));

   procedure Lock_Coord (Board : in out Board_Array;
                         Coord : Coord_2D)
     with Pre => (not Board (Coord.Y_Pos)(Coord.X_Pos).Locked),
     Post => (Board (Coord.Y_Pos)(Coord.X_Pos).Locked);

   procedure Create_And_Add_Piece (Board : in out Board_Array;
                                   Picture_Map : in Picture_Codes;
                                   Next_X : in X_Coord)
     with Pre => (First_Cell_Is_Open (Board, Next_X))
     and (None_Open_After_Locked_Cell (Board, Next_X)),
     Global => (null),
     Depends => (Board =>+ (Next_X, Picture_Map));

   procedure Update_Board (Board : in out Board_Array);

   procedure Update_Graphics (Board : in out Board_Array);

   procedure Print_Board (Board : in Board_Array);

private

   function Translate_X (X_Left : in X_Coord) return Float
   is (Box_Size * Float (X_Left) - Float (Coord_Offset));

   function Translate_Y (Y_Bottom : in Y_Coord) return Float
   is (Float (Coord_Offset) - Box_Size * Float (Y_Bottom));

   function Can_Move_Down (Board : in Board_Array;
                           Cell : Cell_Content) return Boolean
   is (Cell.Content_Type /= Empty and then
       Cell.Piece.Y_Pos < Y_Coord'Last and then
       Board (Cell.Piece.Y_Pos + 1)(Cell.Piece.X_Pos).Content_Type = Empty);

end Tetris;
