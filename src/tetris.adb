package body Tetris
with SPARK_Mode => On
is

   procedure Include_Piece_In_Board (Board : in out Board_Array;
                                     Piece : in Falling_Piece)
   is
   begin
      Board (Piece.Y_Pos)(Piece.X_Pos) := (Content_Type => Piece.Content_Type,
                                           Piece => Piece,
                                           Locked => True);
   end Include_Piece_In_Board;

   procedure Remove_Piece_From_Board (Board : in out Board_Array;
                                      Piece : in Falling_Piece)
   is
   begin
      Board (Piece.Y_Pos)(Piece.X_Pos) := (Content_Type => Empty,
                                           Piece => <>,
                                           Locked => False);
   end Remove_Piece_From_Board;

   function Get_Next_Coord (Board : in Board_Array;
                            Next_X : in X_Coord) return Coord_2D is
      Next_Coord : Coord_2D;
      Y_Pos : Y_Coord;
   begin
      for J in Board'Range loop
         pragma Loop_Invariant (for all K in Y_Coord'First .. J =>
                                  (not Board (K)(Next_X).Locked));
         Y_Pos := J;
         exit when J = Y_Coord'Last or else Board (J + 1)(Next_X).Locked;
      end loop;
      pragma Assert (None_Open_After_Locked_Cell (Board, Next_X));
      pragma Assert (if Y_Pos < Y_Coord'Last then
                       (Board (Y_Pos + 1)(Next_X).Locked));
      Next_Coord := (X_Pos => Next_X, Y_Pos => Y_Pos);
      pragma Assert (Lower_Squares_Are_Locked (Board, Next_Coord));
      return Next_Coord;
   end Get_Next_Coord;

   procedure Lock_Coord (Board : in out Board_Array;
                         Coord : Coord_2D) is
   begin
      Board (Coord.Y_Pos)(Coord.X_Pos).Locked := True;
   end Lock_Coord;

   function Make_Default_Box (Coord : in Coord_2D;
                              Content_Type : in Piece_Type) return Shape_Id is
   begin
      return New_Box (X      => Translate_X (Coord.X_Pos),
                      Y      => Translate_Y (Coord.Y_Pos),
                      Width  => Box_Size,
                      Height => Box_Size,
                      Color  => Piece_Colour_Map(Content_Type));
   end Make_Default_Box;

   procedure Create_And_Add_Piece (Board : in out Board_Array;
                                   Picture_Map : in  Picture_Codes;
                                   Next_X : in X_Coord) is
      Next_Coord : Coord_2D;
      New_Piece : Falling_Piece;
      Content_Type : Piece_Type;
   begin
      Next_Coord := Get_Next_Coord (Board, Next_X);
      Lock_Coord (Board, Next_Coord);
      Content_Type := Picture_Map (Next_Coord.X_Pos)(Next_Coord.Y_Pos);
      New_Piece := (Content_Type => Content_Type,
                    Shape => Make_Default_Box (Next_Coord, Content_Type),
                    X_Pos => Next_Coord.X_Pos,
                    others => <>);
      Include_Piece_In_Board (Board, New_Piece);
   end Create_And_Add_Piece;

   procedure Move_Piece_Down (Board : in out Board_Array;
                              Cell : in out Cell_Content) is
   begin
      Remove_Piece_From_Board (Board, Cell.Piece);
      Cell.Piece.Y_Pos := Cell.Piece.Y_Pos + 1;
      Include_Piece_In_Board (Board, Cell.Piece);
   end Move_Piece_Down;

   procedure Update_Board (Board : in out Board_Array) is
      Board_Copy : Board_Array := Board;
   begin
      for Row of Board_Copy loop
         for Cell of Row loop
            if Can_Move_Down (Board, Cell) then
               Move_Piece_Down (Board, Cell);
            end if;
         end loop;
      end loop;
   end Update_Board;

end Tetris;
