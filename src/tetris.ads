with Display.Basic; use Display.Basic;
with Ada.Numerics.Discrete_Random;

package Tetris
with SPARK_Mode => On
is

   type X_Coord is range 0 .. 39;
   type Y_Coord is range 0 .. 39;

   type Coord_2D is record
      X_Pos : X_Coord := X_Coord'First;
      Y_Pos : Y_Coord := Y_Coord'First;
   end record;

   Coord_Offset : constant Integer := 100;
   Box_Size : constant Float := Float (Coord_Offset * 2) / Float (Y_Coord'Last);

   package Random_X is new Ada.Numerics.Discrete_Random (X_Coord); use Random_X;
   X_Generator : Random_X.Generator;

   type Cell_Type is (Empty, I, O, J, L, S, T, Z);

   subtype Piece_Type is Cell_Type range I .. Z;

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

   function Get_Next_Coord (Board : Board_Array) return Coord_2D;

   procedure Lock_Coord (Board : in out Board_Array;
                         Coord : Coord_2D);
end Tetris;
