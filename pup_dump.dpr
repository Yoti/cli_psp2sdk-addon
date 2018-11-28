program pup_dump;

{$APPTYPE CONSOLE}

uses
  Classes,
  SysUtils;

var
  b: Byte;
  i: Integer;
  j: Integer;
  k: Integer;
  ID8: UInt64;
  Size8: UInt64;
  Offset8: UInt64;
  Record8: UInt64;
  bOffset: UInt64;
  outName: String;
  outPath: String;
  FileCount8: UInt64;
  inMS: TMemoryStream;
  HeaderLength8: UInt64;
  Hash: Array[0..31] of Byte;
{
function Swap32(I: UInt32): UInt32;
asm
  BSWAP EAX
end;
}
function Swap64(I: UInt64): UInt64;
asm
  MOV   EDX,I.Int64Rec.Lo
  BSWAP EDX
  MOV   EAX,I.Int64Rec.Hi
  BSWAP EAX
end;

function IntToStrEx(i: Integer; j: Integer): String;
var
  s: String;
  k: Integer;
begin
  s:=IntToStr(i);
  if Length(s) < j then begin
    for k:=0 to j - Length(s) - 1
    do s:='0' + s;
  end;
  IntToStrEx:=s;
end;

procedure SaveFromMsViaFs(FromMs: TMemoryStream; Name: String; Offset, Size: Cardinal);
var
  TempOffset: Cardinal;
  OutputFile: TFileStream;
begin
  OutputFile:=TFileStream.Create(Name, fmCreate);
  TempOffset:=FromMs.Position;
  FromMs.Seek(Offset, soFromBeginning);
    OutputFile.CopyFrom(FromMs, Size);
  FromMs.Seek(TempOffset, soFromBeginning);
  OutputFile.Free;
end;

begin
  k:=0;
  outName:='';
  outPath:='';
  FillChar(Hash, SizeOf(Hash), $00);

  WriteLn('pup_dump by Yoti');
  if ParamCount < 1 then Exit;
  if FileExists(ParamStr(1)) = False then Exit;

  inMS:=TMemoryStream.Create;
  inMS.LoadFromFile(ParamStr(1));
  inMS.Read(Record8, SizeOf(Record8));
  if Record8 = Swap64($5343455546000001) then begin
    WriteLn('Magic signature: ' + IntToHex(Swap64(Record8), SizeOf(Record8)*2) + ' (valid)');
    inMS.Read(Record8, SizeOf(Record8));
    inMS.Read(Record8, SizeOf(Record8));
    inMS.Read(FileCount8, SizeOf(FileCount8));
    WriteLn('File count:      ' + IntToHex(FileCount8, SizeOf(FileCount8)*2));
    inMS.Read(HeaderLength8, SizeOf(HeaderLength8));
    inMS.Read(Record8, SizeOf(Record8));

    inMS.Seek($50, soCurrent);

    for i:=1 to FileCount8 do begin
      inMS.Read(ID8, SizeOf(ID8));
      Write(IntToHex(ID8, SizeOf(ID8)*2));
      Write(' ');
      inMS.Read(Offset8, SizeOf(Offset8));
      Write(IntToHex(Offset8, SizeOf(Offset8)*2));
      Write(' ');
      inMS.Read(Size8, SizeOf(Size8));
      Write(IntToHex(Size8, SizeOf(Size8)*2));
      inMS.Read(Record8, SizeOf(Record8)); // unknown

      case ID8 of
        $0100: outName:='version.txt';
        $0101: outName:='license.xml';
        $0200: outName:='guiupd.self';
        $0204: outName:='cuiupd.self';
        $0300..$03FF: begin
          Inc(k);
          outName:='dat' + IntToStrEx(k, 4) + '.pkg';
        end;
        $0400: outName:='pkgscewm.wm';
        $0401: outName:='pkgsceas.as';
        $2005: outName:='cpupold.bin';
        $2006: outName:='cpupnew.bin';
        else outName:='dat' + IntToHex(ID8, 4) + '.unk';
      end;
      Write(' ' + outName);
      if ID8 = $0100 then begin
        Write(' ');
        bOffset:=inMS.Position;
        inMS.Seek(Offset8, soFromBeginning);
        for j:=1 to Size8-1 do begin
          inMS.Read(b, 1);
          Write(Chr(b));
        end;
        inMS.Seek(bOffset, soFromBeginning);
      end;
      WriteLn;
      SaveFromMsViaFs(inMS, outName, Offset8, Size8);
    end;
  end;
  inMS.Free;
end.
