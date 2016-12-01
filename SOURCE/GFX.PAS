{ This unit contains Fast Graphic procedures -
  Made By Omer Enbar.
}

Unit Gfx;

InterFace

         Const ScrAd=$A000;
         Procedure PutPixel (x,y: Word; c: Byte);
         Procedure Mode(Mode:Byte);
         procedure Bar(X1, Y1, X2, Y2 : Integer; c : Byte);
         Procedure Rectangle( x1,y1,x2,y2: Word; c: Byte);
         procedure HLine(X, Len, Y : Word; c : Byte);
         Procedure Line(x1,y1,x2,y2:integer;c:byte);
         procedure ScanRay;

Implementation


procedure PutPixel(X, Y : Word; c : Byte); assembler;
  asm                                      {Calling assembler procedure}
     PUSH ES         {Save ES}
     MOV AX, 0A000H  { |                              }
     MOV ES, AX      { \-> Move $A000 to ES through AX}
     MOV BX, Y       {Move Y to BX}
     SHL BX, 6       {SHL BX by 6}
     MOV DX, BX      {Move BX to DX}
     SHL DX, 2       {SHL DX by 2 -->  DX = Y shl 6 shl 2 = Y shl 8 }
     ADD BX, DX      {Add DX to BX}
     ADD BX, X       {Add X to BX}
     mov dl,c
     MOV BYTE PTR ES:[BX], dl {Draw Pixel at ES:BX}
  end;

{----------=ð>  Gets into MCGA graphic mode  <ð=-------------}
Procedure Mode(Mode:Byte); Assembler; {initialises MCGA mode}
Asm
   Mov Al,Mode
   Xor AH,AH
   Int 10h
End;

{-----------=ð> A simple rectangle <ð=--------------}
Procedure Rectangle( x1,y1,x2,y2: Word; c: Byte);
Var I: Word;
Begin
     For i:=x1 to x2 do PutPixel(i,y1,c);
     For i:=x1 to x2 do PutPixel(i,y2,c);
     For i:=y1 to y2 do PutPixel(x1,i,c);
     For i:=y1 to y2 do PutPixel(x2,i,c);
End;

{-----------=ð> Draws an Horizonal line <ð=------------}
       procedure HLine(X, Len, Y : Word; c : Byte); assembler;
       asm                                      {Calling assembler procedure}
         PUSH ES         {Save ES}
         MOV AX, 0A000H  { |                              }
         MOV ES, AX      { \-> Move $A000 to ES through AX}
         MOV DI, Y       {Move Y to DI}
         SHL DI, 6       {SHL DI by 6}
         MOV DX, DI      {Move BX to DI}
         SHL DX, 2       {SHL DX by 2 -->  DX = Y shl 6 shl 2 = Y shl 8 }
         ADD DI, DX      {Add DX to DI}
         ADD DI, X       {Add X to DI}

         { ES:DI now contains the pointer to the first pixel on the line }

         MOV AH, c
         MOV AL, c
         MOV CX, Len
         SHR CX, 1
         JNC @@1
         STOSB  { If Len is odd, draw one pixel }
       @@1:
         REP STOSW
         POP ES
       end;

      procedure Line(X1, Y1, X2, Y2 : Integer; c : Byte);
      var
        Temp, XL, YL, I, X, Y, XSign, YSign, Decision : Integer;

      begin
        XL := Abs(X2-X1);
        YL := Abs(Y2-Y1);

        if (((XL > YL) and (X1 > X2)) or ((YL > XL) and (Y1 > Y2))) then
          begin
            Temp := X1;
            X1   := X2;
            X2   := Temp;
            Temp := Y1;
            Y1   := Y2;
            Y2   := Temp;
          end;

        if (Y2-Y1) < 0 then YSign := -1
          else YSign := 1;

        if (X2-X1) < 0 then XSign := -1
          else XSign := 1;

        if (XL > YL) then
          begin
            Decision := 0;
            Y := Y1;
            for X := X1 to X2 do
              begin
                if (Decision >= XL) then
                  begin
                    Dec(Decision, XL);
                    Inc(Y, YSign);
                  end;
                Inc(Decision, YL);
                PutPixel(X, Y, c);
              end;
          end
        else
          begin
            Decision := 0;
            X := X1;
            for Y := Y1 to Y2 do
              begin
                if (Decision >= YL) then
                  begin
                    Dec(Decision, YL);
                    Inc(X, XSign);
                  end;
                Inc(Decision, XL);
                PutPixel(X, Y, c);
              end;
          end;
      end;

        procedure Bar(X1, Y1, X2, Y2 : Integer; c : Byte);
        var
          Y, XLen : Integer;

        begin
          XLen := (X2-X1) + 1;
          for Y := Y1 to Y2 do
            HLine(X1, XLen, Y, c);
        end;


         procedure ScanRay;
         begin
           repeat until (Port[$3DA] and 8) =  0;
           repeat until (Port[$3DA] and 8) <> 0;
         end;

End.