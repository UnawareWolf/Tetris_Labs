package body Tetris
with SPARK_Mode => On
is

   function Translate_X (X_Left : in X_Coord) return Float is
   begin
      return Box_Size * Float (X_Left) - Float (Coord_Offset);
   end Translate_X;

   function Translate_Y (Y_Bottom : in Y_Coord) return Float is
   begin
      return Float (Coord_Offset) - Box_Size * Float (Y_Bottom);
   end Translate_Y;

   function Can_Move_Down (Board : in Board_Array; Cell : Cell_Content)
                           return Boolean is
   begin
      return Cell.Content_Type /= Empty and then
        Cell.Piece.Y_Pos < Y_Coord'Last and then
        Board (Cell.Piece.Y_Pos + 1)(Cell.Piece.X_Pos).Content_Type = Empty;
   end Can_Move_Down;

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

   function Get_Next_Coord (Board : Board_Array;
                            Next_X : X_Coord) return Coord_2D is
      Next_Coord : Coord_2D;
      Y_Pos : Y_Coord := Y_Coord'Last;
   begin

      for Row of reverse Board loop
         exit when not Row (Next_X).Locked;
         if Y_Pos > Y_Coord'First then
            Y_Pos := Y_Pos - 1;
         end if;
      end loop;
      Next_Coord := (X_Pos => Next_X, Y_Pos => Y_Pos);
      return Next_Coord;
   end Get_Next_Coord;

   procedure Lock_Coord (Board : in out Board_Array;
                         Coord : Coord_2D) is
   begin
      Board (Coord.Y_Pos)(Coord.X_Pos).Locked := True;
   end Lock_Coord;

   procedure Create_And_Add_Piece (Board : in out Board_Array;
                                   Picture_Map : Picture_Codes;
                                   Next_X : X_Coord) is
      Next_Coord : Coord_2D;
      New_Piece : Falling_Piece;
      Content_Type : Piece_Type;
   begin
      Next_Coord := Get_Next_Coord (Board, Next_X);
      Lock_Coord (Board, Next_Coord);
      Content_Type := Picture_Map (Next_Coord.X_Pos)(Next_Coord.Y_Pos);
      New_Piece := (Content_Type => Content_Type,
                    Shape => New_Box (X      => Translate_X (Next_Coord.X_Pos),
                                      Y      => Translate_Y (Next_Coord.Y_Pos),
                                      Width  => Box_Size,
                                      Height => Box_Size,
                                      Color  =>
                                        Piece_Colour_Map(Content_Type)),
                    X_Pos => Next_Coord.X_Pos,
                    others => <>);
      Include_Piece_In_Board (Board, New_Piece);
   end Create_And_Add_Piece;

end Tetris;
