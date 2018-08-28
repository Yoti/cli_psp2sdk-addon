program psp2psarc_xml;

{$APPTYPE CONSOLE}

uses
  Classes,
  StrUtils,
  SysUtils;

var
  Str: String;
  Rec: Cardinal;
  Comp: Cardinal;
  Block: Cardinal;
  Xml: TStringList;
  inFS: TFileStream;

function Swap(a: Cardinal): Cardinal;
asm
  bswap eax
end;

function ExtractSubString(SrcStr, FromStr, ToStr: String): String;
var
  RetStr: String;
  StrPos: Integer;
  StrEnd: Integer;
begin
  RetStr:='';
  StrPos:=Pos(FromStr, SrcStr);
  if StrPos <> 0 then begin
    StrEnd:=PosEx(ToStr, SrcStr, StrPos);
    RetStr:=Copy(SrcStr, StrPos, StrEnd-StrPos+Length(ToStr));
  end;
  Result:=RetStr;
end;

procedure AddFilesFromList(PathToFile: String; ListToAdd: TStringList);
var
  i: Cardinal;
  Str: String;
  List: TStringList;
begin
  List:=TStringList.Create;
  List.Clear;
  List.LoadFromFile(PathToFile);
  for i:=1 to List.Count-1 do begin
    Str:='';
    Str:=Str + Chr($09) + Chr($09);
    Str:=Str + '<file path="' + ChangeFileExt(ParamStr(1), '') + '/';
    Str:=Str + StringReplace(List[i], ' ' + ExtractSubString(List[i], '(', ')'), '', [rfIgnoreCase, rfReplaceAll]);
    Str:=Str + '"';
    if (Pos('100%', List.Strings[i]) <> 0)
    then Str:=Str + ' compressed="false"';
    Str:=Str + ' />';
    ListToAdd.Append(Str);
  end;
  List.Free;
end;

function CheckCompression(PathToFile: String): Boolean;
var
  i: Cardinal;
  Ret: Boolean;
  List: TStringList;
begin
  Ret:=False;
  List:=TStringList.Create;
  List.Clear;
  List.LoadFromFile(PathToFile);
  for i:=1 to List.Count-1 do begin
    //WriteLn(List.Strings[i]);
    if (Pos('100%', List.Strings[i]) = 0)
    then Ret:=True;
  end;
  List.Free;
  Result:=Ret;
end;

begin // psp2psarc_xml by Yoti
  try
    if (ParamCount < 1) then begin
      WriteLn('Error: no input file (-1)');
      Halt(1);
    end;
    if (FileExists(ParamStr(1)) = False) then begin
      WriteLn('Error: input file not exists (-2)');
      Halt(2);
    end;
    if (FileExists(ChangeFileExt(ParamStr(1), '_list.txt')) = False) then begin
      WriteLn('Error: list file not exists (-3)');
      Halt(3);
    end;
//    if (FileSize(ParamStr(1) < $20) then begin
//      WriteLn('Error: input file too small (-?)');
//      Halt(?);
//    end;
    inFS:=TFileStream.Create(ParamStr(1), fmOpenRead or fmShareDenyNone);
      inFS.Read(Rec, SizeOf(Rec)); Rec:=Swap(Rec);
      if (Rec <> $50534152) then begin
        WriteLn('Error: input file not a PSAR (-4)');
        inFS.Free;
        Halt(4);
      end;
      Xml:=TStringList.Create;
      Xml.Clear;
        Xml.Append('<psarc>');
        Str:='';
        Str:=Chr($09) + '<create archive="' + ChangeFileExt(ParamStr(1), '_new') + ExtractFileExt(ParamStr(1)) + '"';
          inFS.Seek(SizeOf(Rec), soCurrent); // skip 'version'
          inFS.Read(Comp, SizeOf(Comp)); Comp:=Swap(Comp); // save 'compression_type'
          inFS.Seek(SizeOf(Rec), soCurrent); // skip 'toc_length'
          inFS.Seek(SizeOf(Rec), soCurrent); // skip 'toc_entry_size'
          inFS.Seek(SizeOf(Rec), soCurrent); // skip 'toc_entries'
          inFS.Read(Block, SizeOf(Block)); Block:=Swap(Block); // save 'block_size'
          inFS.Read(Rec, SizeOf(Rec)); Rec:=Swap(Rec); // read 'archive_flags'
          case Rec of
            $00000000:
              //Write('relative');
              Str:=Str + ' absolute="false" ignorecase="false"';
            $00000001:
              //Write('ignorecase');
              Str:=Str + ' absolute="false" ignorecase="true"';
            $00000002:
              //Write('absolute');
              Str:=Str + ' absolute="true" ignorecase="false"';
            $00000003:
              //Write('ignorecase+absolute');
              Str:=Str + ' absolute="true" ignorecase="true"';
          end;
        Str:=Str + ' blocksize="' + IntToStr(Block) + '">';
        Xml.Append(Str);
        case Comp of
          $7A6C6962:
            if (CheckCompression(ChangeFileExt(ParamStr(1), '_list.txt')) = False)
            then Xml.Append(Chr($09) + Chr($09) + '<compression type="zlib" enabled="false" />')
            else Xml.Append(Chr($09) + Chr($09) + '<compression type="zlib" enabled="true" />');
          $6C7A6D61:
            if (CheckCompression(ChangeFileExt(ParamStr(1), '_list.txt')) = False)
            then Xml.Append(Chr($09) + Chr($09) + '<compression type="lzma" enabled="false" />')
            else Xml.Append(Chr($09) + Chr($09) + '<compression type="lzma" enabled="true" />');
        end;
        Xml.Append(Chr($09) + Chr($09) + '<strip regex="' + ChangeFileExt(ParamStr(1), '') + '/" />');
        Xml.Append('');
        AddFilesFromList(ChangeFileExt(ParamStr(1), '_list.txt'), Xml);
        Xml.Append(Chr($09) + '</create>');
        Xml.Append('</psarc>');
      Xml.SaveToFile(ChangeFileExt(ParamStr(1), '_new.xml'));
      Xml.Free;
    inFS.Free;
    //ReadLn;
    Halt(0);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
