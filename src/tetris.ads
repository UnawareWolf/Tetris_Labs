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

   -- pikachu manual
   --  Piece_Colour_Map : constant Piece_Colour_Type := (Cyan, Yellow, Magenta, Black,
   --                                                    Red, Blue, White, Green);
   --  --  for fun
   --  Piece_Colour_Map : constant Piece_Colour_Type := (Yellow, Blue, Cyan, White,
   --                                                    Magenta, Black, Green);


      -- for dylan
   --  Piece_Colour_Map : constant Piece_Colour_Type := (Cyan, Magenta, White, Yellow,
   --                                                    Black, Blue, Green, Red);

   -- for brothers
   --  Piece_Colour_Map : constant Piece_Colour_Type := (Magenta, Red, Yellow, Cyan,
   --                                                    Black, White, Green);

   type Coord_2D is record
      X_Pos : X_Coord := X_Coord'First;
      Y_Pos : Y_Coord := Y_Coord'First;
   end record;

   Coord_Offset : constant Integer := 100;
   Box_Size : constant Float := Float (Coord_Offset * 2) / Float (Y_Coord'Last);

   type Falling_Piece is record
      Content_Type : Piece_Type := I;
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

   function Translate_X (X_Left : in X_Coord) return Float;

   function Translate_Y (Y_Bottom : in Y_Coord) return Float;

   function Can_Move_Down (Board : Board_Array; Cell : Cell_Content)
                           return Boolean;

   procedure Include_Piece_In_Board (Board : in out Board_Array;
                                     Piece : in Falling_Piece);

   procedure Remove_Piece_From_Board (Board : in out Board_Array;
                                      Piece : in Falling_Piece);

   function Get_Next_Coord (Board : Board_Array;
                            Next_X : X_Coord) return Coord_2D;

   procedure Lock_Coord (Board : in out Board_Array;
                         Coord : Coord_2D);

   procedure Create_And_Add_Piece (Board : in out Board_Array;
                                   Picture_Map : Picture_Codes;
                                   Next_X : X_Coord);

end Tetris;
