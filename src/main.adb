with Display;       use Display;
with Display.Basic; use Display.Basic;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Numerics.Discrete_Random;
--  with Ada.Numerics.Float_Random;

procedure Main is

   Coord_Offset : constant Integer := 100;

   type X_Coord is range 0 .. 15;
   type Y_Coord is range 0 .. 15;

   Box_Size : constant Float := Float (Coord_Offset * 2) / Float (Y_Coord'Last);

   X_Pos : X_Coord := 4;
   Y_Pos : Y_Coord := 0;

   type Cell_Type is (Empty, I, O, J, L, S, T, Z);

   subtype Piece_Type is Cell_Type range I .. Z;

   type Piece_Colour_Type is array (Piece_Type) of Color_Type;
   Piece_Colour_Map : constant Piece_Colour_Type := (Blue, Green, Cyan, Red,
                                                     Magenta, Yellow, White);

   package Random_Piece is new Ada.Numerics.Discrete_Random (Piece_Type); use Random_Piece;
   package Random_X is new Ada.Numerics.Discrete_Random (X_Coord); use Random_X;

   Piece_Generator : Random_Piece.Generator;
   X_Generator : Random_X.Generator;
   --  Float_Generator : Ada.Numerics.Float_Random.Generator;

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

   type Row_Array is array (X_Coord) of Cell_Content;

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

   function New_Piece return Falling_Piece is
      Piece : Falling_Piece;
      Content_Type : Piece_Type := Random (Piece_Generator);
      X_Pos : X_Coord := Random (X_Generator);
      --  Rand_Float : Float := Ada.Numerics.Float_Random.Random (Float_Generator);
      Default_Y : Y_Coord := 0;
      --  Open_Cols : Positive := 0;
   begin

      Piece := (Content_Type => Content_Type,
                Shape => New_Box (X      => Translate_X (X_Pos),
                                  Y      => Translate_Y (Default_Y),
                                  Width  => Box_Size,
                                  Height => Box_Size,
                                  Color  => Piece_Colour_Map (Content_Type)),
                X_Pos => X_Pos,
                others => <>);
      return Piece;
   end New_Piece;

   procedure Include_Piece_In_Board (Board : in out Board_Array;
                                     Piece : in Falling_Piece)
   is
   begin
      Board (Piece.Y_Pos)(Piece.X_Pos) := (Content_Type => Piece.Content_Type,
                                           Piece => Piece);
   end Include_Piece_In_Board;

   procedure Remove_Piece_From_Board (Board : in out Board_Array;
                                      Piece : in Falling_Piece)
   is
   begin
      Board (Piece.Y_Pos)(Piece.X_Pos) := (Content_Type => Empty,
                                           Piece => <>);
   end Remove_Piece_From_Board;

   procedure Update_Board (Board : in out Board_Array) is
      Board_Copy : Board_Array := Board;

      function Can_Move_Down (Board_2 : in out Board_Array; Cell : Cell_Content)
                              return Boolean is
      begin
         return Cell.Content_Type /= Empty and then
              Cell.Piece.Y_Pos < Y_Coord'Last and then
              Board_2 (Cell.Piece.Y_Pos + 1)(Cell.Piece.X_Pos).Content_Type = Empty;
      end Can_Move_Down;

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

begin
   Include_Piece_In_Board (The_Board, New_Piece);

   for I in 0 .. 400 loop
      delay 0.005;
      Include_Piece_In_Board (The_Board, New_Piece);
      Update_Board (The_Board);
      Update_Graphics (The_Board);
   end loop;

   New_Line;
   Put_Line ("   GAME OVER");
   Print_Board (The_Board);

end Main;
