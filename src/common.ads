package Common is

   Image_Width : constant Natural := 50;

   type X_Coord is mod Image_Width;
   type Y_Coord is range 0 .. Image_Width - 1;

   type Cell_Type is (Empty, I, O, J, L, S, T, Z);

   subtype Piece_Type is Cell_Type range I .. Z;

end Common;
