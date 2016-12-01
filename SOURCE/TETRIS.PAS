{$A+,B-,D+,E+,F-,G+,I+,L+,N+,O-,P-,Q+,R+,S+,T-,V+,X+}
{$M 65520,0,655360}

{ By Omer Enbar }
Program Tetris;
Uses Gfx, Crt, Dos, Smfntx15, Smfntx11, Smfntx01;

Const
     MaxBitMaps = 15; (* Number of bitmaps the program uses *)

     Normal = 19; (* Number of regular shapes Including turns *)
     Deluxe = 45; (* Same for Deluxe shapes *)
     Crazy = 55; (* Same for Crazy shapes *)

     MaxShapes = 54; (* Number of total shapes *)

     Size = 7;       (* Size of shapes *)
     Stx=100; Sty=10; (* Starting x and y coordinates for rhe Pit *)
     MaxYPit=27; MaxXPit=17; (* Depth and Width of Pit *)
     MaxOpt=5; (* Number of options *)
Type

    HighS=Record
                Name:String[10];
                Score:Longint;
                StartLevel,EndLevel:Byte;
                ShapeForm:Byte;
    End;

    SaveBack=Array[0..111,0..181] of byte; (* This array saves the Background
                                              picture behind the pit in order
                                              to restore the picture after
                                              the shape has gone through it *)
    VirtualScreen=array[0..199,0..319] of byte;
    FontSet=array[0..126,0..7,0..7] of Byte; (* to save the BIOS fonts *)
    ThePit = Array[0..MaxXPit,1..MaxYPit] of Byte; (* Contains the shape
                                                      location in the pit *)
    RawBitMap = Array[1..Size,1..Size] of Byte; (* Contains information about
                                                   the bitmap picture *)
    (* Shape data *)
    ShapeFormat = Record
                         Data : Array[1..4,1..4] of Byte;
                         Next : Byte;
                   End;

    Data = Array[0..MaxShapes] of ShapeFormat;
    OptionData=Array[1..MaxOpt] Of Byte;
    BitMapArray=Array[0..MaxBitMaps] of RawBitMap;

    { 1 = 0 - Just Regular Shapes.
          1 - Deluxe with Regular. Ratio 3:1
          2 - Crazy with Deluxe with Regular. Ration 6:3:1
          3 - Just Deluxe.
          4 - Crazy with Regular. Ratio 1:6
          5 - Crazy with Deluxe. Ratio 1:3
          6 - Everything and Challanging. Ration 1:1:1
          7 - EveryThing and Hard. Ratio 1:2:3
          8 - Just Crazy.

      2 = 0 - Next Shape is Not Actived.
          1 - Next Shape is Actived.

      3 = 0..9 - Holds the starting levels

      4 = 0 - Immidiate Down.
          1 - Not Immidiate Down.

      5 = Holds the number of random lines in beggining.
    }

Var
   PlayerScore:HighS;     (* Player score *)
   vir:^VirtualScreen;    (* A virual screen for loading the picture *)
   BG:^SaveBack;           (* Background - refer to type.saveback *)
   Pit : ^ThePit;          (* Pit information - refer to type.ThePit *)
   BitMap : ^BitMapArray; (* Contains all the data about the bitmaps *)
   ShapeData : ^Data;     (* Contains the shape data *)
   i, j : Byte;           (* Variables for 'for' commands *)
   Key, Speed : Byte;     (* Key - which key was pressed; Speed - speed of
                             the game *)
   tl : Byte;             (* Is increased by one everytime the internal timer
                             is being called. That means 18.2 time a second.
                             It is used for speed calculations *)
   LocOfInt8 : Pointer;   (* Location of the timer *)
   Options : OptionData;  (* Holds the options *)
   Dead : Boolean;        (* Set to true if you are dead *)
   Fonts : ^FontSet;       (* Holds the bios fonts data *)
   Goal, Level : Byte;    (* Goal - how many lines you should clear before
                                    going to an upper level;
                             Level - Holds current level number *)
   Score : LongInt;       (* Holds player score *)
   RScore : Word;         (* Holds the points you should get when the shape
                             will be placed in it's place. It is effected by
                             some things like the hight of the drop *)
   NotDownYet : Boolean;  (* For some score checking *)

{$I Graph.Pas}               (* Procedures for some graphic routines *)
{$I Function.pas}            (* Procedures for some "less important" routines
                                for the game *)
{$I Game.Pas}                (* Main Procedure for the game *)
{$I Init.Pas}                (* Procedures for initializing the game *)

Procedure Init_Game;
Begin
     Randomize; (* Operates The Randomize Timer *)
     Mode($13); (* Inits Graph *)
     GetMem(ShapeData,sizeof(Data));
     ShapeData:=ptr(seg(tetrisshapes),ofs(tetrisshapes));
     Bitmap:=ptr(seg(init_bitmap),ofs(init_bitmap));
     For i:=1 to size do
         for j:=1 to size do
             Bitmap^[0,i,j]:=0;
     Init_Fonts; (* Load Bios Fonts *)
     Init_Kbd; (* Set The KeyBoard *)
     Set_Clock; (* Sets Computer Clock To Act as My Clock *)
     {InitSound;}
End;

Procedure Load_Pic(x,y:Word;s:string);
Var i,j:word;
    f:file;
Begin
     getmem(vir,sizeof(vir));
     new(vir);
     For i:=0 to 199 do
         For j:=0 to 319 do
             Vir^[i,j]:=0;
     load_pcx(0,0,s);
     setrgb(0,0,0,0);


     Move(Vir^,Mem[$A000:0],64000);
     dispose(vir);
     new(BG);
          For i:=Stx+15 to Stx+126 do
              For j:=Sty+1 to 192 do
                  BG^[i-Stx-15,j-Sty-1]:=getpixel(i,j);

End;


{ -----------------------===ננ> Play The Game <ננ===------------------------ }
Procedure Play_Game;
Var Next, Current: Byte;
    X, Y :Byte;
    i,j:byte;

Procedure Init_Start;
Begin
     New(Pit);
     With PlayerScore do
     Begin
          Name:='';
          Score:=0;
          StartLevel:=0; EndLevel:=0;
          ShapeForm:=0;
     End;

     Init_Variables; (* Resets Variables *)
     Init_Screen; (* Draws Screen *)

     Init_Options; (* Loads Game's Options *)
     WriteScore; (* Writes The Score *)
     NotDownYet:=True;
     x:=(MaxXPit-1) Div 2; y:=1;
     Next:=ChooseNextShape;
     Current:=ChooseNextShape;
     DrawShape(Current,x,y,ShapeMap(Current));
     Level:=Options[3]; (* Holds the start level *)
     Speed:=9-Level; tl:=0; RScore:=Options[1]+1+Level;
     Init_Dots;
     WriteNextShape(Next);
     WriteLevel;
     if Level<9 then Goal:=10+Level*5 Else Goal:=255;
     WriteGoal;
     Score:=0;
End;


Begin
     Load_Pic(0,0,'tetris.dat');
     Init_Start;

     (* Player Start level and the shapes he is playing with are entered
        to the record *)
     PlayerScore.StartLevel:=Options[3];
     PlayerScore.ShapeForm:=Options[1];

     (* The actual game *)
     Repeat
           If tl>Speed Then
           Begin
                Drop_Down(Current, x, y, Next);
                tl:=0;
           End;
           if (keypressed) then MoveMent(Current,x,y,next);
     Until (key=27) or (Dead);
     (* Player is dead or pressed escape *)

     (* Player Score and Finish level are entered to the record *)
     PlayerScore.Score:=Score;
     PlayerScore.EndLevel:=Level;
End;

{ ------------------------===ננ>Main Program<ננ===-------------------------- }
Begin
     Init_Game;
     Case Menu Of
          1: Begin Play_Game; CheckHighScores; Dispose(Bg); Dispose(Pit); End;
          3: CheckHighScores;
          5: Begin Dispose(Fonts);  Close_Game; End;
    End;
End.