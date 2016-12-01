Program intro;

uses gfx,crt,tetpic,pale;
{$I Atlantis.PAS}

{Procedure Introduction;}
Type  palette=array[0..255,0..2] of Byte;
      ScreenPtr = ^Screen;
      Screen    = array[0..199, 0..319] of Byte;
      PalPtr    = ^Palette;

var
    pal1:palette;
    pal:palptr;
    pic:screenptr;

Procedure ClearScreen;
Begin
     Bar(0,0,320,200,0);
End;

Procedure SetRgb(Color,R,G,B:Byte);
Begin
     Port[$3c6]:=$FF;
     Port[$3c8]:=Color;
     Port[$3c9]:=r;
     Port[$3c9]:=g;
     Port[$3c9]:=b;
End;
Procedure GetRgb(Color:Byte; Var R,G,B:Byte);
Begin
     Port[$3c6]:=$FF;
     Port[$3c7]:=Color;
     R:=Port[$3c9];
     G:=Port[$3c9];
     B:=Port[$3c9];
end;
procedure GetPal(var Pal : Palette);
var
  Counter : Byte;
begin
  for Counter := 0 to 255 do
    GetRgb(Counter, Pal[Counter, 0], Pal[Counter, 1], Pal[Counter, 2]);
end;
procedure SetPal({var} Pal : Palette);
var
  Counter : Byte;
begin
  for Counter := 0 to 255 do
      SetRgb(Counter, Pal[Counter, 0], Pal[Counter, 1], Pal[Counter, 2]);
end;

procedure Fade(R, G, B, MinReg, MaxReg : Byte; Cycles : Byte);
var
  C, Counter : Word;
  Temp : Palette;
begin
  GetPal(Temp);
  for C := 1 to Cycles do
   begin
     ScanRay;
     for Counter := MinReg to MaxReg do
       begin
         SetRgb(Counter,
                   R - Round((Cycles - C) * ((R - Temp[Counter, 0]) / Cycles)),
                   G - Round((Cycles - C) * ((G - Temp[Counter, 1]) / Cycles)),
                   B - Round((Cycles - C) * ((B - Temp[Counter, 2]) / Cycles)));
       end;
   end;
end;

procedure FadeTo(P : Palette; MinReg, MaxReg : Byte; Cycles : Byte);
var
  C, Counter : Word;
  Temp : Palette;
  ch:char;
begin
  GetPal(Temp);
  for C := 1 to Cycles do
   begin
     ScanRay;
     for Counter := MinReg to MaxReg do
       SetRgb(Counter,
                 P[Counter, 0] - Round((Cycles - C) * ((P[Counter, 0] - Temp[Counter, 0]) / Cycles)),
                 P[Counter, 1] - Round((Cycles - C) * ((P[Counter, 1] - Temp[Counter, 1]) / Cycles)),
                 P[Counter, 2] - Round((Cycles - C) * ((P[Counter, 2] - Temp[Counter, 2]) / Cycles)));
   end;
end;




Procedure Draw_Char(var X:Word; y:word; ch: Char; indi:boolean);
Var F:FrameHdr;
    i,j:integer;
    Address:pointer;
    size:integer;
Begin
     F:=ImagesInfo[CharIndex(ch)];
     y:=y+f.ys;
     Address:=F.BitMap;
     size:=0;
     For j:=1 to f.Yl do
         For i:=1 to f.Xl do
         Begin
              Inc(size);
              if indi then putpixel(x+i-1,y+j-1,Mem[seg(address^):ofs(address^)+size-1])
                 else putpixel(x+i-1,y+j-1,Mem[seg(address^):ofs(address^)+size-1]-32);
         End;
     Inc(x,F.Xl+2);
End; (* Draw_Char *)


Procedure do_it(x,y:word; s:string; f:boolean);
Var i:Byte;
Begin
     For i:=1 to length(s) do
         if s[i]=#32 then inc(x,SpaceLength)
         Else
         Begin
              Draw_Char(x,y,s[i],f);
         End;
End;

Procedure Write_It(x,y:Word; S : String);
Begin
     Fade(0,0,0,32,63,2);
     Do_it(x,y,s,true);
     Fade(63, 63, 63, 33, 63, 15);
     FadeTo(Pal1, 33, 63,20);
     Do_it(x,y,s,False);
End;

Procedure Set_Pal;
Var i:Byte;
Begin
    setrgb(1,10,10,10); setrgb(2,20,20,20);
    For i:=32 to 34 do
    Begin
         pal1[i,0]:=(i-32)*10;
         pal1[i,1]:=(i-32)*10;
         pal1[i,2]:=(i-32)*10;
    End;
End;
Function touch:Boolean;
Begin
     if (port[$60]=1) or (port[$60]=129) then touch:=True else touch:=False;
End;
procedure show_intro;
label Endintro;
Begin
     Pal := Ptr(Seg(p256), Ofs(p256));
     Pic := Ptr(Seg(TetrisPicture), Ofs(TetrisPicture) + 800);

     mode($13);


     Set_Pal;
     Write_It(30,60,'Omer Enbar');
     Delay(300);
     Write_It(70,90,'Presents');
     Delay(1000);
     Fade(0,0,0,0,255,20);
     ClearScreen;
     If touch then Goto endintro;

     Set_Pal;
     Write_It(15,60,'A one man''s ');
     Delay(300);
     Write_It(40,90,'Production');
     Delay(1000);
     Fade(0,0,0,0,255,20);
     ClearScreen;
     If touch then Goto endintro;

     Move(Pic^, Mem[$A000:0], 64000);
     FadeTo(Pal^, 0, 255, 30);
     Delay(3000);
     Fade(0, 0, 0, 0, 255, 30);
     ClearScreen;

     EndIntro:
     Mode(3);
End;
Begin
     Show_Intro;
end.
