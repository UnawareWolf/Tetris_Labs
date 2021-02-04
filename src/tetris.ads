package Tetris is

   type Cell_Type is (Empty, I, O, J, L, S, T, Z);

   subtype Piece_Type is Cell_Type range I .. Z;

   procedure Place_Holder;

end Tetris;
