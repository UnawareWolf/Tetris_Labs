with Display;       use Display;
with Display.Basic; use Display.Basic;
with Ada.Text_IO; use Ada.Text_IO;

procedure Main is

   Coord_Offset : constant Integer := 100;

   type X_Coord is range 0 .. 7;
   type Y_Coord is range 0 .. 15;

   Red_Box : Shape_Id;

   Box_Size : constant Float := Float (Coord_Offset * 2) / Float (Y_Coord'Last);

   X_Pos : X_Coord := 4;
   Y_Pos : Y_Coord := 0;

   type Cell_Type is (Empty, I, O, J, L, S, T, Z);

   type Row_Array is array (X_Coord) of Cell_Type;

   type Board_Array is array (Y_Coord) of Row_Array;

   The_Board : Board_Array;

   function Translate_X (X_Left : in X_Coord) return Float is
   begin
      return Box_Size * Float (X_Left) - Float (Coord_Offset);
   end Translate_X;

   function Translate_Y (Y_Bottom : in Y_Coord) return Float is
   begin
      return Float (Coord_Offset) - Box_Size * Float (Y_Bottom);
   end Translate_Y;

begin

   for Row of The_Board loop
      Row := (others => Empty);
   end loop;

   Red_Box := New_Box (X      => Translate_X (X_Pos),
                       Y      => Translate_Y (Y_Pos),
                       Width  => Box_Size,
                       Height => Box_Size,
                       Color  => Red);

   loop
      Set_Y (Shape => Red_Box,
             Value => Translate_Y (Y_Pos));
      delay 0.1;
      exit when Y_Pos = Y_Coord'Last;
      Y_Pos := Y_Pos + 1;
      Put_Line (Y_Pos'Image);
   end loop;

   New_Line;
   Put_Line ("   GAME OVER");

   The_Board (Y_Pos)(X_Pos) := Z;

   for Row of The_Board loop
      for Cell of Row loop
         if Cell = Empty then
            Put ("-");
         else
            Put (Cell'Image);
         end if;
         Put (" ");
      end loop;
      New_Line;
   end loop;
   New_Line;
   Put_Line ("Block has finished falling!");

end Main;
