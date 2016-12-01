Function GetPixel(x,y:Word):Byte;
Begin
     GetPixel:=Mem[$A000:(y*320)+x];
End;

{----------=נ>  Loads PCX picture into memory  <נ=-----------}
Procedure Load_Pcx(dx, dy : Word; name : String);
Var q                          : File;
    b                          : Array[0..2047] Of Byte;
    anz, pos, c, w, h, e, pack : Word;
    x, y                       : Word;
    bla:text;

Label ende_background;

Begin
  x := dx; y := dy;
  Assign(q, Name); {$I-} Reset(q, 1); {$I+}
  If IOResult <> 0 Then
    GOTO ende_background;

  BlockRead(q, b, 128, anz);
  If (b[0] <> 10) OR (b[3] <> 8) Then
  Begin
    Close(q);
    GOTO ende_background;
  End;
  w := Succ((b[9] - b[5]) Shl 8 + b[8] - b[4]);
  h := Succ((b[11] - b[7]) Shl 8 + b[10] - b[6]);
  pack := 0; c := 0; e := y + h;

  Repeat
    BlockRead(q, b, 2048, anz);
    pos := 0;
    While (pos < anz) And (y < e) DO
    Begin
      If pack <> 0 Then
      Begin
        For c := c to c + pack Do
            if x+c<320 then vir^[y,x+c]:=b[pos];
        pack := 0;
      End
      Else
        If (b[pos] and $C0) = $C0 Then
          pack := b[pos] and $3F
        Else
        Begin
          vir^[y,x+c]:=b[pos];
          Inc(c);
        End;
      Inc(pos);
      If c = w Then
      Begin
        c := 0;
        Inc(y);
      End;
    End;
  Until (anz = 0) or (y = e);
  Seek(q, FileSize(q) - 3 Shl 8 - 1);
  BlockRead(q, b, 3 Shl 8 + 1);
  If b[0] = 12 Then
    For x := 1 TO 3 Shl 8 + 1 Do
      b[x] := b[x] Shr 2;

  Port[$3C8] := 0;

  For x := 0 to 255 Do
  Begin
    Port[$3C9] := b[(x)*3+1];
    Port[$3C9] := b[(x)*3+2];
    Port[$3C9] := b[(x)*3+3];
  End;

  Close(q);
ende_background:
End;
{ ------------===ננ> Puts a "four pixel" pixel on screen <ננ===------------ }
Procedure BigPixel(x,y:Word; c:Byte);
Begin
     Mem[$A000:(y*320)+x]:=c;
     Mem[$A000:(y*320)+x+1]:=c;
     Mem[$A000:((y+1)*320)+x]:=c;
     Mem[$A000:((y+1)*320)+x+1]:=c;
End;
{ --------------------===ננ> Sets Rgb color <ננ===------------------------- }
Procedure SetRGB(color,r,g,b:byte);
Begin
     port[$3c8]:=color;
     port[$3c9]:=r;
     port[$3c9]:=g;
     port[$3c9]:=b;
End;
{ --------------------===ננ> Sets Rgb color <ננ===------------------------- }
Procedure GetRGB(color:byte; var r,g,b:byte);
Begin
     port[$3c7]:=color;
     r:=port[$3c9];
     g:=port[$3c9];
     b:=port[$3c9];
End;

{ -------------------===ננ> Rgb palette gradient <ננ===-------------------- }
Procedure Gradient(p1,p2,r1,g1,b1,r2,g2,b2 : Byte); {Makes a smooth color
transition in the palette between one color and another}
Var rr,gr,br : Real;
    Grad : Byte;
Begin
     rr:=(r2-r1)/(p2-p1); {Calculates the red value change in each color}
     gr:=(g2-g1)/(p2-p1); {Calculates the green value change in each color}
     br:=(b2-b1)/(p2-p1); {Calculates the blue value change in each color}
     For Grad:=0 to (p2-p1) Do
         Setrgb(grad+p1,r1+round(rr*grad),g1+round(gr*grad),b1+round(br*grad));
End;

