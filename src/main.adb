with Display;       use Display;
with Display.Basic; use Display.Basic;
with Ada.Text_IO; use Ada.Text_IO;
with Picture; use Picture;
with Tetris; use Tetris;
with Common; use Common;

procedure Main is

   The_Board : Board_Array;

   procedure Run_Tetris (Picture_Map : in Picture_Codes;
                         Board : out Board_Array) is
      Next_X : X_Coord := X_Coord'Last;
      Next_Piece : Falling_Piece;
   begin
      Board := (others => <>);
      for I in 0 .. 4094 loop
         delay 0.001;
         Next_X := Next_X + 1;
         if First_Cell_Is_Open (Board, Next_X) then
            Create_And_Add_Piece (Board, Picture_Map, Next_X);
         end if;
         Update_Board (Board);
         Update_Graphics (Board);
      end loop;
   end Run_Tetris;

   Picture_Map : Picture_Codes;
   Next_X : X_Coord := X_Coord'Last;
   Next_Piece : Falling_Piece;
begin
   Picture_Map := Get_Picture_Codes;
   Run_Tetris (Picture_Map => Picture_Map,
               Board       => The_Board);

   New_Line;
   Put_Line ("   GAME OVER");
   --  Print_Board (The_Board);

end Main;
