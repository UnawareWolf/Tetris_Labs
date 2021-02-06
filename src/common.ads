package Common is

   Image_Width : constant Natural := 64;

   type X_Coord is mod Image_Width;
   type Y_Coord is range 0 .. Image_Width - 1;

   type Cell_Type is (Empty, I, O, J, L, S, T, Z, W);

   subtype Piece_Type is Cell_Type range I .. W;

end Common;
