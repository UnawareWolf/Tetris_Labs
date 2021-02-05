with Display; use Display;
with Common; use Common;


package Picture
with SPARK_Mode => On
is

   type Code_Row is array (Y_Coord) of Piece_Type;
   type Picture_Codes is array (X_Coord) of Code_Row;

   function Get_Picture_Codes return Picture_Codes;

end Picture;
