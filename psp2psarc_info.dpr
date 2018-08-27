program psp2psarc_info;

{$APPTYPE CONSOLE}

uses
  Classes,
  SysUtils;

var
  Rec: Cardinal;
  inFS: TFileStream;

function Swap(a: Cardinal): Cardinal;
asm
  bswap eax
end;

begin // psp2psarc_info v1.1 by Yoti
  try
    if (ParamCount < 1) then begin
      WriteLn('Error: no input file (-1)');
      Halt(1);
    end;
    if (FileExists(ParamStr(1)) = False) then begin
      WriteLn('Error: input file not exists (-2)');
      Halt(2);
    end;
//    if (FileSize(ParamStr(1) < $20) then begin
//      WriteLn('Error: input file too small (-?)');
//      Halt(?);
//    end;
    inFS:=TFileStream.Create(ParamStr(1), fmOpenRead or fmShareDenyNone);
      inFS.Read(Rec, SizeOf(Rec)); Rec:=Swap(Rec);
      if (Rec <> $50534152) then begin
        WriteLn('Error: input file not a PSAR (-3)');
        inFS.Free;
        Halt(3);
      end;
      WriteLn('magic: 0x' + IntToHex(Rec, 8));
      inFS.Read(Rec, SizeOf(Rec)); Rec:=Swap(Rec);
      WriteLn('version: 0x' + IntToHex(Rec, 8)
      + ' (v' + IntToHex(Word(Rec shr 16), 1) + '.' + IntToHex(Word(Rec shr 0), 1) + ')');
      inFS.Read(Rec, SizeOf(Rec)); Rec:=Swap(Rec);
      Write('compression_type: ');
      case Rec of
        $7A6C6962:
          WriteLn('zlib');
        $6C7A6D61:
          WriteLn('lzma');
        else // error
          WriteLn('0x' + IntToHex(Rec, 8));
      end;
      inFS.Read(Rec, SizeOf(Rec)); Rec:=Swap(Rec);
      WriteLn('toc_length: 0x' + IntToHex(Rec, 8) + ' (' + IntToStr(Rec)+ ')');
      inFS.Read(Rec, SizeOf(Rec)); Rec:=Swap(Rec);
      WriteLn('toc_entry_size: 0x' + IntToHex(Rec, 8) + ' (' + IntToStr(Rec)+ ')');
      inFS.Read(Rec, SizeOf(Rec)); Rec:=Swap(Rec);
      WriteLn('toc_entries: 0x' + IntToHex(Rec, 8) + ' (1+' + IntToStr(Rec-1)+ ')');
      inFS.Read(Rec, SizeOf(Rec)); Rec:=Swap(Rec);
      WriteLn('block_size: 0x' + IntToHex(Rec, 8) + ' (' + IntToStr(Rec)+ ')');
      inFS.Read(Rec, SizeOf(Rec)); Rec:=Swap(Rec);
      Write('archive_flags: 0x' + IntToHex(Rec, 8) + ' (');
      case Rec of
        $00000000:
          Write('relative');
        $00000001:
          Write('ignorecase');
        $00000002:
          Write('absolute');
        $00000003:
          Write('ignorecase+absolute');
        else // error
          Write('0x' + IntToHex(Rec, 8));
      end;
      WriteLn(')');
    inFS.Free;
    Halt(0);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
