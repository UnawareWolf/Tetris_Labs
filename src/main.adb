with Display;       use Display;
with Display.Basic; use Display.Basic;
with Ada.Text_IO; use Ada.Text_IO;

procedure Main is

   Coord_Offset : constant Integer := 100;

   type X_Coord is range 0 .. 360;
   type Y_Coord is range 0 .. 360;

   Red_Box : Shape_Id;

   Box_Size : constant Natural := 10;

   Y_Pos : Y_Coord := 0;

   type Cell_Type is (Empty, I, O, J, L, S, T, Z);

   type Row_Dims is range 0 .. 7;

   type Row_Array is array (Row_Dims) of Cell_Type;

   type Board_Array is array (Row_Dims) of Row_Array;

   The_Board : Board_Array;

   function Translate_X (X_Left : in X_Coord) return Float is
   begin
      return Float (X_Left) - Float (Coord_Offset);
   end Translate_X;

   function Translate_Y (Y_Bottom : in Y_Coord) return Float is
   begin
      return Float (Coord_Offset) - Float (Y_Bottom);
   end Translate_Y;

begin

   for Row of The_Board loop
      Row := (others => Empty);
   end loop;

   Red_Box := New_Box (X      => Translate_X (0),
                       Y      => Translate_Y (Y_Pos),
                       Width  => Float (Box_Size),
                       Height => Float (Box_Size),
                       Color  => Red);

   while Y_Pos <= 200 loop
      Set_Y (Shape => Red_Box,
             Value => Translate_Y (Y_Pos));
      delay 0.1;
      Y_Pos := Y_Pos + Y_Coord (Box_Size);
   end loop;

   New_Line;
   Put_Line ("   GAME OVER");

   The_Board (7)(0) := Z;

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
