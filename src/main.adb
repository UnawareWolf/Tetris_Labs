with Display;       use Display;
with Display.Basic; use Display.Basic;
with Ada.Text_IO; use Ada.Text_IO;
with Picture; use Picture;
with Tetris; use Tetris;
with Common; use Common;

procedure Main is

   The_Board : Board_Array;

   procedure Update_Graphics (Board : in out Board_Array) is
   begin
      for Row of Board loop
         for Cell of Row loop
            if Cell.Content_Type /= Empty then
               Set_Y (Shape => Cell.Piece.Shape,
                      Value => Translate_Y (Cell.Piece.Y_Pos));
            end if;
         end loop;
      end loop;
   end Update_Graphics;

   procedure Print_Board (Board : in Board_Array) is
   begin
      for Row of Board loop
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
   end Print_Board;

   Picture_Map : Picture_Codes;
   Next_X : X_Coord := X_Coord'Last;
   Next_Piece : Falling_Piece;
begin
   Picture_Map := Get_Picture_Codes;
   for I in 0 .. 4094 loop
      delay 0.001;
      Next_X := Next_X + 1;
      if First_Cell_Is_Open (The_Board, Next_X) then
         Create_And_Add_Piece (The_Board, Picture_Map, Next_X);
      end if;
      Update_Board (The_Board);
      Update_Graphics (The_Board);
   end loop;

   New_Line;
   Put_Line ("   GAME OVER");
   --  Print_Board (The_Board);

end Main;
