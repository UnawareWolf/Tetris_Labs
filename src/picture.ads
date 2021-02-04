with Display; use Display;
with Tetris; use Tetris;

package Picture is

   type Code_Row is array (0 .. 39) of Piece_Type;
   type Picture_Codes is array (0 .. 39) of Code_Row;

   function Get_Picture_Codes return Picture_Codes;

end Picture;
