{------------=נ> Writes a BIG string on the screen <נ=-----------}
Procedure BigWrite(x, y : Word; s : String; Color: Byte);
Var a,b,c : Word;
Begin
     Bar(x,y,x+length(s)*16,y+16,0);
     a:=0;
     Repeat
           a:=a+1;
           For i:=0 to 7 Do
           Begin
               For j:=0 to 7 Do
                   If Fonts^[Ord(s[a]),i,j]>0 Then
                      BigPixel(((a-1)*16)+x+(i*2),(y+(j*2)),Color);

           End;
     until a=length(s);
end;

{ ---------===ננ> Gives back the bitmap that the shape uses <ננ==---------- }
Function ShapeMap(Current:Byte):Byte;
Var c:Byte;
    i,j:byte;
Begin
     For i:=1 to 4 do
         For j:=1 to 4 do
             If ShapeData^[Current].Data[i,j]>0 then
                c:=ShapeData^[Current].Data[i,j];
     ShapeMap:=c;
End;

{------------=נ> Writes a string on the screen <נ=-----------}
Procedure WriteText(x, y : Word; s : String; Color: Byte);
Var a,b,c : Word;
Begin
     Bar(x,y,x+length(s)*8,y+8,0);
     a:=0;
     Repeat
           a:=a+1;
           if ord(s[a])<127 then
           For i:=0 to 7 Do
           Begin
               For j:=0 to 7 Do
                   If Fonts^[Ord(s[a]),i,j]>0 Then
                      PutPixel(((a-1)*8)+x+i,y+j,Color);

           End;
     Until a=length(s);
End;

{ --===ננ> Chooses the next shape acoording to what you've selected <ננ===--}
Function ChooseNextShape:Byte;
Function Ratio(R:Byte):Byte;
Begin
     Ratio:=Random(R)+1;
End;
Begin
     Case Options[1] of
          0:ChooseNextShape:=Random(Normal);
          3:ChooseNextShape:=Normal+Random(Deluxe-Normal);
          8:ChooseNextShape:=Deluxe+Random(Crazy-Deluxe);
          1:
                 Case ratio(4) of
                      1..3:ChooseNextShape:=Random(Normal);
                      4:ChooseNextShape:=Normal+Random(Deluxe-Normal);
                 End;

          2:
                 Case ratio(10) of
                      1..6:ChooseNextShape:=Random(Normal);
                      7..9:ChooseNextShape:=Normal+Random(Deluxe-Normal);
                      10:ChooseNextShape:=Deluxe+Random(Crazy-Deluxe);
                 End;
          5:
                 Case ratio(7) of
                      1..6:ChooseNextShape:=Random(Normal);
                      7:ChooseNextShape:=Deluxe+Random(Crazy-Deluxe);
                 End;
          4:
                 Case ratio(4) of
                      1..3:ChooseNextShape:=Normal+Random(Deluxe-Normal);
                      4:ChooseNextShape:=Deluxe+Random(Crazy-Deluxe);
                 End;
          6:
                 Case ratio(3) of
                      1:ChooseNextShape:=Random(Normal);
                      2:ChooseNextShape:=Normal+Random(Deluxe-Normal);
                      3:ChooseNextShape:=Deluxe+Random(Crazy-Deluxe);
                 End;
          7:
                 Case ratio(6) of
                      1:ChooseNextShape:=Random(Normal);
                      2..3:ChooseNextShape:=Normal+Random(Deluxe-Normal);
                      4..6:ChooseNextShape:=Deluxe+Random(Crazy-Deluxe);
                 End;
          End;
End;

{-----------------=נ> Saves the bios fonts <נ=-------------------}
Procedure Init_Fonts;
Var ad,c,k:word;
    ch:byte;
Begin
     New(Fonts);
     For c:=0 to 126 do
     Begin
          ad := $fa6e + (c * 8);              { Calc address of character image in ROM }
          For i := 0 to 7 Do
          Begin
               ch := mem[$f000 : ad + i];       { Get a byte of the image }
               j:=1;
               k:=0;
               Repeat
                     If (j and ch=j) then Fonts^[c,7-k,i]:=round(i*4.5)+185
                     else Fonts^[c,7-k,i]:=0;
{                     j:=j shl 1;}
asm
   shl j,1
end;
                     k:=k+1;
               Until k=8;
          End;
     End;
End;

{ ----------------===ננ> Clears the keyboard buffer <ננ===----------------- }
Procedure ClearBuffer;
Begin
     MemW[$0000:$041C] := MemW[$0000:$041A];      { flush keyboard buffer }
End;

Procedure WriteLevel;
Var s:String;
Begin
     str(level,s);
     BigWrite(12,20,s,87);
End;
Procedure WriteScore;
Var s:String;
Begin
     str(score,s);
     WriteText(1,60,s,1);
End;
Procedure WriteGoal;
Var s:String;
Begin
     str(Goal,s);
     WriteText(15,90,s,1);
End;

{ ----------------===ננ> Puts a bitmap on the screen <ננ===---------------- }
Procedure PutBitMap(Num:byte; x,y:Word);
Var i,j : Byte;
Begin
     For i:=1 to Size do
         For j:=1 to Size do
             if num<>0 then PutPixel(x+j,y+i,BitMap^[2,i,j]) else
                PutPixel(x+j,y+i,BitMap^[0,i,j]);
End;

{ ------===ננ> Puts random dots on screen for more Pleasure <ננ===--------- }
Procedure Init_Dots;
Var i,j,d:Byte;
Begin
     For i:=MaxYPit-1 downto MaxYPit-Options[5] do
         For j:=1 to MaxXPit div 2 do
         Begin
              d:=random(MaxXPit-1)+1;
              Pit^[d,i]:={Random(MaxBitMaps)+1}1;
              PutBitMap(Pit^[d,i],StX+(d*Size)+size,Sty+(i*Size)-Size);
         End;
End;

{ ----------------===ננ> Draws the Shape On Screen <ננ===------------------ }
Procedure DrawShape(Current,x,y,mode:Byte);
Var a,b:Byte;
Begin
{     For i:=1 to 4 do
         For j:=1 to 4 do
             If ShapeData[Current].Data[i,j]>0 then
             Begin
                  Pit[x+i-1,y+j-1]:=Mode;
                  PutBitMap(Mode,StX+((x*Size)+(i*Size)),Sty+(y*Size)+(j*size)-(2*Size));
             End;}
     If mode>0 then
     Begin
          For i:=1 to 4 do
              For j:=1 to 4 do
                  If ShapeData^[Current].Data[i,j]>0 then
                  Begin
                       Pit^[x+i-1,y+j-1]:=Mode;
                       PutBitMap(Mode,StX+((x*Size)+(i*Size)),Sty+(y*Size)+(j*size)-(2*Size));
                  End;
     End
     Else
     Begin

          For i:=1 to 4 do
              For j:=1 to 4 do
                  If ShapeData^[Current].Data[i,j]>0 then
                       Pit^[x+i-1,y+j-1]:=Mode;

          For a:=1 to 4 do
              For b:=1 to 4 do
              If shapedata^[current].data[a,b]>0 then
          For i:=0 to Size-1 do
              For j:=1 to Size do
                  PutPixel((StX+((x*Size)+(a*Size))+i+1),(Sty+(y*Size)+(b*size)-(2*Size))+j,
                  bg^[((x*Size)+(a*Size))+i-14,((y*Size)+(b*size)-(2*Size))+j-1]);

     End;
End;


{ ------------===ננ> Writes the next shape on screen <ננ===---------------- }
Procedure WriteNextShape(Next:Byte);
Var i,j:Byte;
Begin
     If Options[2]=1 Then
     For i:=1 to 4 do
         For j:=1 to 4 do
         Begin
              PutBitMap(0,275+(i*Size),45+(j*Size));
              If ShapeData^[Next].Data[i,j]>0 then
                 PutBitMap(ShapeData^[Next].Data[i,j],275+(i*Size),45+(j*Size));
         End;
End;


Procedure CheckHighScores;
var highscoresfile:File of HighS;
    filescores:array[1..10] of HighS;
    TempString:String;
    i:byte;
    InTopTen:Byte;
    Ch:Char;
Begin
     Bar(0,0,319,199,0);
     InTopTen:=0;
     Assign(highscoresfile,'High.Scr');
     {$I-}
     Reset(highscoresfile);
     {$I+}
     If ioresult=0 then
     For i:=10 downto 1 do
     Begin
          read(highscoresfile,filescores[i]);
          If filescores[i].score<=PlayerScore.score then InTopTen:=i;
     End
     Else
     For i:=1 to 10 do
     Begin
          With filescores[i] do
          Begin
               Name:='Empty';
               Score:=0;
               StartLevel:=0; EndLevel:=0;
               ShapeForm:=0;
          End;
          InTopTen:=1;
     End;

     if (intopten<10) and (intopten>0) then
        For i:=10 downto intopten+1 do
            filescores[i]:=filescores[i-1];


     If InTopTen>0 then
     Begin
  setrgb(1,16,12,8);
  setrgb(2,32,24,16);
  setrgb(3,48,36,24);
  setrgb(4,63,48,32);

  setrgb(5,12,8,16);
  setrgb(6,24,16,32);
  setrgb(7,36,24,48);
  setrgb(8,48,32,63);

           Font15('You  are  in  the  top  ten',50,10,0,1,2,3,4,$A000);
           Font15('Enter  your  name',80,40,0,1,2,3,4,$A000);
          i:=1;
          playerscore.name:=' ';
          Repeat
                Ch:=readkey;
                If ch=#8 then if i>1 then
                begin
                     dec(i);
                     Font15(playerscore.name,100,80,1,0,0,0,0,$A000);
                     playerscore.name[i]:=' ';
                     playerscore.name[0]:=chr(i);
                     Font15(playerscore.name,100,80,1,5,6,7,8,$A000);
                end
                else else
                if (ch<>#13) and (i<11) then
                begin
                     playerscore.name[i]:=ch;
                     playerscore.name[0]:=chr(i);
                     Font15(PlayerScore.name,100,80,1,5,6,7,8,$A000);
                     inc(i);
                end;
          Until Ch=#13;
          filescores[InTopTen]:=PlayerScore;
     End;
     Bar(0,0,319,199,0);
     rewrite(highscoresfile);
     for i:=10 downto 1 do write(highscoresfile,filescores[i]);
     Close(highscoresfile);

     Font01('Name',10,10,100,$A000);
     Font01('Score',100,10,100,$A000);
     Font01('Start',165,0,100,$A000);
     Font01('Level',165,10,100,$A000);
     Font01('End',212,0,100,$A000);
     Font01('Level',212,10,100,$A000);
     Font01('Shape',262,0,100,$A000);
     Font01('Form',262,10,100,$A000);

     for i:=1 to 10 do
     begin
{           WriteText(10,i*16+10,filescores[i].name,1);
           str(filescores[i].score,tempstring);
           WriteText(100,i*16+10,tempstring,1);
           str(filescores[i].startlevel,tempstring);
           WriteText(180,i*16+10,tempstring,1);
           str(filescores[i].endlevel,tempstring);
           WriteText(220,i*16+10,tempstring,1);
           str(filescores[i].shapeform,tempstring);
           WriteText(270,i*16+10,tempstring,1);    }
           str(i,tempstring);
           Font01(tempstring,0,i*16+10,3,$A000);
           Font01(filescores[i].name,15,i*16+10,1,$A000);
           str(filescores[i].score,tempstring);
           Font01(tempstring,100,i*16+10,1,$A000);
           str(filescores[i].startlevel,tempstring);
           Font01(tempstring,180,i*16+10,1,$A000);
           str(filescores[i].endlevel,tempstring);
           Font01(tempstring,220,i*16+10,1,$A000);
           str(filescores[i].shapeform,tempstring);
           Font01(tempstring,270,i*16+10,1,$A000);
end;
     ch:=readkey;
End;

Function Menu:Byte;
var ch:char;
    Item:Byte;
    r,g,b:Byte;

Procedure Scale;
var r2,g2,b2:Byte;
    original:Array[0..2,0..2] of byte;
Begin
     Getrgb(item*3-2,r,g,b);
     original[0,0]:=r; original[0,1]:=g; original[0,2]:=b;
     Getrgb(item*3-1,r,g,b);
     original[1,0]:=r; original[1,1]:=g; original[1,2]:=b;
     GetRgb(item*3,r,g,b);
     original[2,0]:=r; original[2,1]:=g; original[2,2]:=b;
     ch:=' ';
     Repeat
           ScanRay;
           delay(50);
           GetRgb(item*3-1,r2,g2,b2);
           SetRgb(item*3-1,r,g,b);
           getRgb(item*3-2,r,g,b);
           ScanRay;
           delay(50);
           Setrgb(item*3-2,r2,g2,b2);
           setrgb(item*3,r,g,b);
           getrgb(item*3,r,g,b);
           ScanRay;
           delay(50);
           If keypressed then ch:=readkey;
     Until (Ch=#13) or (Ch=#72) or (Ch=#80);
     SetRgb(item*3-2,original[0,0],original[0,1],original[0,2]);
     SetRgb(item*3-1,original[1,0],original[1,1],original[1,2]);
     SetRgb(item*3,original[2,0],original[2,1],original[2,2]);
End;

Begin
     GetRgb(7,r,g,b);
     SetRgb(1,r,g,b);
     SetRgb(4,r,g,b);
     SetRgb(10,r,g,b);
     SetRgb(13,r,g,b);

     GetRgb(8,r,g,b);
     SetRgb(2,r,g,b);
     SetRgb(5,r,g,b);
     SetRgb(11,r,g,b);
     SetRgb(14,r,g,b);

     GetRgb(15,r,g,b);
     SetRgb(3,r,g,b);
     SetRgb(6,r,g,b);
     SetRgb(9,r,g,b);
     SetRgb(12,r,g,b);

     Item:=1;

     Font11('New Game',40,10,1,2,3,0,$A000);
     Font11('Options',45,45,4,5,6,0,$A000);
     Font11('Top Ten',52,80,7,8,9,0,$A000);
     Font11('Credits',45,115,10,11,12,0,$A000);
     Font11('Quit',90,150,13,14,15,0,$A000);

     Repeat
     Scale;
     Case ord(ch) of
          80: Begin Inc(Item); if item>5 then item:=1; End;
          72: Begin Dec(Item); If item<1 then item:=5; End;
     end;
     ClearBuffer;
     Until ch=#13;
     Menu:=Item;
End;
