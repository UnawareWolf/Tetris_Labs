with Ada.Text_IO; use Ada.Text_IO;
with Display; use Display;
with Interfaces.C; use Interfaces.C;

package body Picture
--  with SPARK_Mode => On
is

   procedure Py_Scan_Image is
      procedure run_shell (a : String)
        with
          Import => True,
          Convention => C;
   begin
      run_shell ("python scan_image.py " & Image_Width'Image);
   end Py_Scan_Image;

   function Get_Picture_Codes return Picture_Codes is
      F : File_Type;
      Output_Codes : Picture_Codes;
      Code_Line : String (1 .. Image_Width);
      X : X_Coord := 0;
      Y : Y_Coord := 0;
      Single_String : String (1 .. 1);
      Single_String_2 : String (1 .. 1);
   begin
      Py_Scan_Image;
      Open (F, In_File, "picture_codes.txt");
      while not End_Of_File (F) loop
         Code_Line := Get_Line (F);
         X := 0;
         for Letter of Code_Line loop
            for Code in Piece_Type'First .. Piece_Type'Last loop
               Single_String := "" & Letter;
               Single_String_2 := "" & Code'Image;
               if Single_String = Single_String_2 then
                  Output_Codes (X)(Y) := Code;
               end if;
            end loop;
            if X < X_Coord'Last then
               X := X + 1;
            end if;
         end loop;
         if Y < Y_Coord'Last then
            Y := Y + 1;
         end if;
      end loop;
      return Output_Codes;
   end Get_Picture_Codes;

end Picture;
