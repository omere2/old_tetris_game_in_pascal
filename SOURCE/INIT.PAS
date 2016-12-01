{ Initializes the keyboard }
Procedure Init_Kbd;Assembler;
asm
   mov ax,$0305
   mov bh,0
   mov bl,0
   int 16h
end;

{ Set a new clock for the computer }
Procedure MyClock; Interrupt;
Begin
     inc(tl);
     Asm
        Pushf
        Call LocOfInt8
     End;
End;

{ Closes the game }
Procedure Close_Game;
Begin
     Mode(3);
     SetIntVec(8,LocOfInt8);
     Asm
        Mov ax,4c00h
        int 21h
     end;
End;

{ Loads the shapes from a file }
Procedure tetrisshapes; external;
{$L shapes.obj}

{ Sets starting options }
Procedure Init_Options;
Var i:Byte;
    f:file of byte;
Begin
     Assign(f,'Defualts.set');
     {$I-}
     Reset(f);
     {$I+}
     If ioresult=0 then
     Begin
          For i:=1 to 5 do Read(f,Options[i]);
          Close(f);
     End
     Else
     Begin
          ReWrite(f);
          Options[1]:=0; (* Just Regular Shapes *)
          Options[2]:=1; (* Next Shape Is Actived *)
          Options[3]:=0; (* Holds the Starting level *)
          Options[4]:=1; (* Not Immidiate Down *)
          Options[5]:=0; (* Four lines to be randomed *)
          for i:=1 to 5 do write(f,options[i]);
          Close(f);
     End;
End;

{ Sets starting variables }
Procedure Init_Variables;
Var
   i, j : Byte;
Begin
     Dead:=False;   (* Not Dead! *)


{     For i:=1 to MaxYPit-1 do
         For j:=0 to MaxXPit-1 do
             Pit[i,j]:=0;        }

     fillchar(pit^,sizeof(pit^),0);
     For i:=1 to MaxYPit do
     begin
          pit^[0,i]:=1;
          pit^[MaxXPit,i]:=1;
     end;
     for i:=1 to MaxXPit-1 do pit^[i,MaxYPit]:=1;
End;

Procedure Init_Bitmap;external;
{$L bitmap.obj}

{ Init screen }
Procedure Init_Screen;
Begin
     Line(StX+14,StY,StX+18*7+1,StY,0);
     Line(StX+14,193,StX+18*7+1,193,0);
     Line(StX+14,StY,StX+14,192,0);
     Line(StX+18*7+1,StY,StX+18*7+1,192,0);
End;

{ Sets the clock }
Procedure Set_Clock;
Begin
     GetIntVec(8,LocOfInt8);
     SetIntVec(8,@MyClock);
End;
