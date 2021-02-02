with Display;       use Display;
with Display.Basic; use Display.Basic;
with Ada.Text_IO; use Ada.Text_IO;

procedure Main is

   Coord_Offset : constant Integer := 100;

   type X_Coord is range 0 .. 7;
   type Y_Coord is range 0 .. 15;

   Box_Size : constant Float := Float (Coord_Offset * 2) / Float (Y_Coord'Last);

   X_Pos : X_Coord := 4;
   Y_Pos : Y_Coord := 0;

   type Cell_Type is (Empty, I, O, J, L, S, T, Z);

   subtype Piece_Type is Cell_Type range I .. Z;

   --  Colour_Array is array () ;
   type Falling_Piece is record
      Content_Type : Piece_Type;
      Shape : Shape_Id;
      X_Pos : X_Coord := 3;
      Y_Pos : Y_Coord := 0;
   end record;

   type Cell_Content is record
      Content_Type : Cell_Type := Empty;
      Piece : Falling_Piece;
   end record;

   Piece_1 : Falling_Piece;

   type Row_Array is array (X_Coord) of Cell_Content;

   type Board_Array is array (Y_Coord) of Row_Array;

   The_Board : Board_Array;
   Board_Copy : Board_Array;

   function Translate_X (X_Left : in X_Coord) return Float is
   begin
      return Box_Size * Float (X_Left) - Float (Coord_Offset);
   end Translate_X;

   function Translate_Y (Y_Bottom : in Y_Coord) return Float is
   begin
      return Float (Coord_Offset) - Box_Size * Float (Y_Bottom);
   end Translate_Y;

begin

   Piece_1.Content_Type := Z;
   Piece_1.Shape := New_Box (X      => Translate_X (Piece_1.X_Pos),
                             Y      => Translate_Y (Piece_1.Y_Pos),
                             Width  => Box_Size,
                             Height => Box_Size,
                             Color  => Red);
   The_Board (Piece_1.Y_Pos)(Piece_1.X_Pos) := (Content_Type => Piece_1.Content_Type,
                                                Piece => Piece_1);

   while Piece_1.Y_Pos < Y_Coord'Last loop
      delay 0.1;
      Board_Copy := The_Board;

      for Row of Board_Copy loop
         for Cell of Row loop
            if Cell.Content_Type /= Empty and then Cell.Piece.Y_Pos < Y_Coord'Last then
               Cell.Piece.Y_Pos := Cell.Piece.Y_Pos + 1;
               Set_Y (Shape => Cell.Piece.Shape,
                      Value => Translate_Y (Cell.Piece.Y_Pos));
               The_Board (Cell.Piece.Y_Pos)(Cell.Piece.X_Pos) := (Piece => Cell.Piece,
                                                                  Content_Type => Cell.Piece.Content_Type);
            end if;
         end loop;
      end loop;
   end loop;

   New_Line;
   Put_Line ("   GAME OVER");

   for Row of The_Board loop
      for Cell of Row loop
         if Cell.Content_Type = Empty then
            Put ("-");
         else
            Put (Cell.Content_Type'Image);
         end if;
         Put (" ");
      end loop;
      New_Line;
   end loop;
   New_Line;
   Put_Line ("Block has finished falling!");

end Main;
