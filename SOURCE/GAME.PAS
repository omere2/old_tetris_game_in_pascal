Procedure Drop_Down(Var Current, x, y, Next : Byte);
Var i,j : Byte;
    Exit : Boolean;

Procedure SetNewShape;

Procedure CheckLine;
Var Counter:Byte;
    i,j:Byte;
    Check:Boolean;
    a,Num:Byte;
    aa,bb:word;
    TempPit:^ThePit;

Begin
     new(TempPit);
     Counter:=0;
     For i:=1 to 4 do
     Begin
          Check:=False;
          For j:=1 to 4 do
              If ShapeData^[Current].Data[j,i]>0 then Check:=true;
          If Check then inc(Counter);
     End;
     temppit^:=pit^;
     Check:=False;
     Num:=y+Counter-1;
     For i:=y to Num do
     Begin
          Counter:=0;
          For j:=1 to MaxXPit-1 do
              If Pit^[j,i]>0 then Inc(Counter);
          If Counter=MaxXPit-1 then
          Begin
               For j:=1 to MaxXPit-1 do Pit^[j,i]:=0;
               Check:=true;
               Goal:=Goal-1;
               Bar(15,90,40,110,0);
               WriteGoal;
               RScore:=RScore+40;
               If Goal<1 then
               Begin
                    RScore:=RScore+(Level*200);
                    Level:=Level+1;
                    If Level>9 then Level:=9;
                    WriteLevel;
                    If Level<9 then Goal:=10+Level*5 Else Goal:=255;
                    Speed:=9-Level;
               End;
          End;
     End;
     If Check then
     Begin
          For a:=1 to 4 do
          Begin
          For i:=Num DownTo 2 do
          Begin
               Counter:=0;
               For j:=1 to MaxXPit-1 do If Pit^[j,i]=0 then inc(Counter);
               If Counter=MaxXPit-1 then
               Begin
                  For j:=1 to MaxXPit-1 do
                  Begin
                       Pit^[j,i]:=Pit^[j,i-1];
                       Pit^[j,i-1]:=0;
                       If pit^[j,i]>0 then
                       PutBitMap(Pit^[j,i],StX+(j*Size)+Size,StY+(i*Size)-Size);
                  End;

              End;
          End;
          End;

          For i:=Num downto 1 do
          For j:=1 to MaxXPit-1 do
          If (temppit^[j,i]>0) and (pit^[j,i]=0) then
          For aa:=1 to size do
          For bb:=0 to size-1 do
          putpixel(StX+(j*Size)+Size+aa,StY+(i*Size)-Size+bb+1,
          Bg^[(j*Size)+Size+aa-2*size-1,(i*Size)-Size+bb]);
     End;
     Dispose(TempPit);

End;
Procedure CheckIfDead;
Var i,j:Byte;
Begin
     For i:=1 to 4 do
         For j:=1 to 4 do
             If (ShapeData^[Current].Data[i,j]>0) and (Pit^[x+i,y+j]>0) then
                Dead:=True;
End;

Begin
     CheckLine;
     Score:=Score+RScore;
     NotDownYet:=True;
     WriteScore;
     Rscore:=(Options[1]+1)+Level;
     x:=(MaxXPit-1) Div 2; y:=1;
     tl:=0;
     Current:=Next;
     Next:=ChooseNextShape;
     Exit:=True;
     CheckIfDead;
     WriteNextShape(Next);
     DrawShape(Current,x,1,ShapeMap(Current));
End;

Begin
     j:=4; i:=4;
     Exit:=False;

     Repeat
           Repeat

                 If (ShapeData^[Current].Data[i,j]>0)
                                And
                 (
                 ((j+1<5) and (ShapeData^[Current].Data[i,j+1]<>ShapeMap(Current)) and (Pit^[x+i-1,y+j]>0))
                              Or
                        ((j+1>4) and ((Pit^[x+i-1,y+j]>0)))
                 )
                        Then SetNewShape;


                 Dec(j);
           Until (j=0) or (Exit);
           j:=4; Dec(i);
     Until (i=0) or (Exit);
     If i=0 then
     Begin
          DrawShape(Current,x,y,0);
          Inc(y);
          DrawShape(Current,x,y,ShapeMap(Current));
     End;
End;

Procedure MoveMent(Var Current,x,y,next:Byte);
Var i,j:Byte;
    Exit:Boolean;
    ch:char;

Procedure MoveRight;
Var i,j:Byte;
Begin
     j:=4; i:=4;
     Repeat
           Repeat
                 If (ShapeData^[Current].Data[i,j]>0) then
                    If i<4 then
                       If (ShapeData^[Current].Data[i+1,j]<>ShapeMap(Current))
                          And (Pit^[x+i,y+j-1]>0) then
                              Exit:=True
                          Else
                       Else
                           If  (Pit^[x+i,y+j-1]>0) then Exit:=True;

                 Dec(j);
           Until (j=0) or (Exit);
           j:=4; If Not(Exit) then Dec(i);
     Until (i=0) or (Exit);
     If i=0 then
     Begin
          DrawShape(Current,x,y,0);
          Inc(x);
          DrawShape(Current,x,y,ShapeMap(Current));
     End;
End;
Procedure MoveLeft;
Var i,j:Byte;
Begin
     j:=4; i:=1;
     Repeat
           Repeat
                 If (ShapeData^[Current].Data[i,j]>0) Then
                    If i>1 then
                       If (ShapeData^[Current].Data[i-1,j]<>shapemap(current))
                          And (Pit^[x+i-2,y+j-1]>0) then
                              Exit:=True
                              Else
                       Else
                           If (Pit^[x+i-2,y+j-1]>0) then Exit:=True;

                 Dec(j);
           Until (j=0) or (Exit);
           j:=4; If Not(Exit) then Inc(i);
     Until (i=5) or (Exit);
     If i=5 then
     Begin
          DrawShape(Current,x,y,0);
          Dec(x);
          DrawShape(Current,x,y,ShapeMap(Current));
     End;
End;
Procedure Flip;
Var Counter:Byte;
    i,j:byte;
Begin
     Counter:=0;
     For i:=1 to 4 do
         For j:=1 to 4 do
         Begin
             If (ShapeData^[ShapeData^[Current].Next].Data[i,j]>0)
            And (x+i-1<=maxxpit) and(y>0)
            And ((Pit^[x+i-1,y+j-1]=0) or (ShapeData^[Current].Data[i,j]>0))
                    Then Inc(Counter);
             If (ShapeData^[ShapeData^[Current].Next].Data[i,j]=0) then Inc(Counter);
         End;

     If Counter=16 then
     Begin
          DrawShape(Current,x,y,0);
          Current:=ShapeData^[Current].Next;
          DrawShape(Current,x,y,ShapeMap(Current));
     End;
End;

Procedure Down;
Begin
     If NotDownYet then
     Begin
          Rscore:=Rscore+((maxypit-y) div 5);
          NotDownYet:=False;
     End;

     (* If 0 then Immidiate Down, If 1 then Not immidiate down *)
     If Options[4]=0 then
     Begin
          Repeat
                Drop_Down(Current, x, y, Next);
          Until y=2;
          DrawShape(current,x,y,0);
          y:=1;
          DrawShape(current,x,y,ShapeMap(Current));
     End
     Else
     Begin
          Drop_Down(Current,x,y,Next);
          Drop_Down(Current,x,y,Next);
     End;
End;

Begin
{     key:=port[$60];
     if keypressed then ClearBuffer;}
     ch:=readkey;
     key:=ord(ch);
     Exit:=False;
     Case Key of
          77:MoveRight;
          75:MoveLeft;
          13:Flip;    { ENTER }
          80:Down;
     End;
     ClearBuffer;
End;
