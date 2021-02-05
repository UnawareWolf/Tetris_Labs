with Display;       use Display;
with Display.Basic; use Display.Basic;
with Ada.Text_IO; use Ada.Text_IO;
with Picture; use Picture;
with Tetris; use Tetris;
with Ada.Numerics.Discrete_Random;
--  with Ada.Numerics.Float_Random;

procedure Main is

   X_Pos : X_Coord := 4;
   Y_Pos : Y_Coord := 0;

   type Piece_Colour_Type is array (Piece_Type) of Color_Type;

   Piece_Colour_Map : constant Piece_Colour_Type := (Yellow, Red, Cyan, White,
                                                     Blue, Black, Green);

   package Random_Piece is new Ada.Numerics.Discrete_Random (Piece_Type); use Random_Piece;
   package Random_X is new Ada.Numerics.Discrete_Random (X_Coord); use Random_X;

   Piece_Generator : Random_Piece.Generator;
   X_Generator : Random_X.Generator;
   --  Float_Generator : Ada.Numerics.Float_Random.Generator;

   The_Board : Board_Array;

   procedure Create_And_Add_Piece (Board : in out Board_Array;
                                   Picture_Map : Picture_Codes) is
      Next_Coord : Coord_2D;
      New_Piece : Falling_Piece;
      Content_Type : Piece_Type;
   begin
      Next_Coord := Get_Next_Coord (Board);
      Lock_Coord (Board, Next_Coord);
      Content_Type := Picture_Map (Integer (Next_Coord.X_Pos))
                                  (Integer (Next_Coord.Y_Pos));
      New_Piece := (Content_Type => Content_Type,
                    Shape => New_Box (X      => Translate_X (Next_Coord.X_Pos),
                                      Y      => Translate_Y (Next_Coord.Y_Pos),
                                      Width  => Box_Size,
                                      Height => Box_Size,
                                      Color  => Piece_Colour_Map (Content_Type)),
                    X_Pos => Next_Coord.X_Pos,
                    others => <>);
      Include_Piece_In_Board (Board, New_Piece);
   end Create_And_Add_Piece;

   procedure Update_Board (Board : in out Board_Array) is
      Board_Copy : Board_Array := Board;

   begin
      for Row of Board_Copy loop
         for Cell of Row loop
            if Can_Move_Down (Board_Copy, Cell) then
               Remove_Piece_From_Board (The_Board, Cell.Piece);
               Cell.Piece.Y_Pos := Cell.Piece.Y_Pos + 1;
               Include_Piece_In_Board (The_Board, Cell.Piece);
            end if;
         end loop;
      end loop;
   end Update_Board;

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

begin
   Picture_Map := Get_Picture_Codes;
   Create_And_Add_Piece (The_Board, Picture_Map);
   for I in 0 .. 4094 loop
      delay 0.006;
      Create_And_Add_Piece (The_Board, Picture_Map);
      Update_Board (The_Board);
      Update_Graphics (The_Board);
   end loop;

   New_Line;
   Put_Line ("   GAME OVER");
   Print_Board (The_Board);

end Main;
