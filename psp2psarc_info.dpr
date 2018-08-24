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

begin // psp2psarc_info by Yoti
  try
    if (ParamCount < 1) then begin
      WriteLn('Error: no input file (-1)');
      Halt(1);
    end;
    if (FileExists(ParamStr(1)) = False) then begin
      WriteLn('Error: input file not exists (-2)');
      Halt(2);
    end;
    inFS:=TFileStream.Create(ParamStr(1), fmOpenRead or fmShareDenyNone);
      inFS.Read(Rec, SizeOf(Rec));
      if (Rec <> $52415350) then begin
        WriteLn('Error: input file not a PSAR (-3)');
        inFS.Free;
        Halt(3);
      end;
      WriteLn('magic: 0x' + IntToHex(Swap(Rec), 8));
      inFS.Read(Rec, SizeOf(Rec));
      WriteLn('version: 0x' + IntToHex(Swap(Rec), 8)
      + ' (v' + IntToHex(Word(Swap(Rec) shr 16), 1) + '.' + IntToHex(Word(Swap(Rec) shr 0), 1) + ')');
      inFS.Read(Rec, SizeOf(Rec));
      Write('compression_type: ');
      case Swap(Rec) of
        $7A6C6962:
          WriteLn('zlib');
        $6C7A6D61:
          WriteLn('lzma');
        else
          WriteLn('0x' + IntToHex(Swap(Rec), 8)); // error
      end;
      inFS.Read(Rec, SizeOf(Rec));
      WriteLn('toc_length: 0x' + IntToHex(Swap(Rec), 8) + ' (' + IntToStr(Swap(Rec))+ ')');
      inFS.Read(Rec, SizeOf(Rec));
      WriteLn('toc_entry_size: 0x' + IntToHex(Swap(Rec), 8) + ' (' + IntToStr(Swap(Rec))+ ')');
      inFS.Read(Rec, SizeOf(Rec));
      WriteLn('toc_entries: 0x' + IntToHex(Swap(Rec), 8) + ' (1+' + IntToStr(Swap(Rec)-1)+ ')');
      inFS.Read(Rec, SizeOf(Rec));
      WriteLn('block_size: 0x' + IntToHex(Swap(Rec), 8) + ' (' + IntToStr(Swap(Rec))+ ')');
      inFS.Read(Rec, SizeOf(Rec));
      Write('archive_flags: 0x' + IntToHex(Swap(Rec), 8) + ' (');
      case Swap(Rec) of
        0:
          Write('relative');
        1:
          Write('ignorecase');
        2:
          Write('absolute');
        3:
          Write('ignorecase+absolute');
        else // error
          Write('0x' + IntToHex(Swap(Rec), 8));
      end;
      WriteLn(')');
    inFS.Free;
    Halt(0);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
