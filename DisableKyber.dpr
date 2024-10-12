{-----------------------------------------------------------------------------

                     프로젝트: Kyber Encryption Disable Tool

히스토리:
  0.9.0.0
  [+] 프로젝트 시작

-----------------------------------------------------------------------------}

program DisableKyber;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  madExcept,
  madLinkDisAsm,
  madListProcesses,
  madListModules,
  System.SysUtils, System.IOUtils, System.JSON, System.Generics.Collections, System.StrUtils;

function IsKyber(const FileName: string): Integer;
var
  Text: string;
begin
  Result := 0;

  try
    Text := TFile.ReadAllText(FileName, TEncoding.UTF8);
    if Pos('enable-tls13-kyber@1', Text) > 0 then Result := 1
    else if Pos('enable-tls13-kyber@2', Text) > 0 then Result := 2;
  except
    on E: Exception do ;
  end;
end;

function SetKyber(const FileName: string; Enable: Boolean): Integer;
var
  JSON, Dict: TJSONObject;
  Labs: TJSONArray;
  I: Integer;
begin
  Result := 0;

  try
    JSON := TJSONObject.ParseJSONValue(TFile.ReadAllText(FileName, TEncoding.UTF8)) as TJSONObject;

    if Assigned(JSON) then
    begin
      Dict := JSON.GetValue('browser') as TJSONObject;
      if Assigned(Dict) then
      begin
        Labs := Dict.GetValue('enabled_labs_experiments') as TJSONArray;
        if Assigned(Labs) then
        begin
          for I := 0 to Labs.Count-1 do
          begin
            if Labs.Items[I].Value = 'enable-tls13-kyber@1' then
            begin
              if Enable then
                Result := 1
              else
                Labs.Remove(I);
              Break;
            end
            else if Labs.Items[I].Value = 'enable-tls13-kyber@2' then
            begin
              if Enable then
                Labs.Remove(I)
              else
                Result := 2;
              Break;
            end;
          end;
          if (Result = 0) and (not Enable) then
          begin
            Labs.Add('enable-tls13-kyber@2');
            Result := 2;
          end;
        end
        else
        begin
          if not Enable then
          begin
            Labs := TJSONArray.Create;
            Labs.Add('enable-tls13-kyber@2');
            Dict.AddPair('enabled_labs_experiments', Labs);
            Result := 0;
          end;
        end;
        TFile.WriteAllText(FileName, JSON.ToString);
      end;
    end;
  except
    on E: Exception do ;
  end;
end;

const
  Options: array[0..1] of string = ('/enable', '/disable');
var
  FileList: TList<string>;
  ProcList: TList<string>;
  FileName, ProcName, State, Input: string;
  Auto: Boolean;
  I: Integer;
begin
  Auto := False;
  if ParamCount = 1 then
  begin
    for I := 0 to 1 do
      if ParamStr(1) = Options[I] then
      begin
        Auto := True;
        Input := IntToStr(I+2);
      end;
  end;

  FileList := TList<string>.Create;
  ProcList := TList<string>.Create;

  // Chrome
  FileList.Add(IncludeTrailingPathDelimiter(GetEnvironmentVariable('LOCALAPPDATA')) + 'Google\Chrome\User Data\Local State');
  ProcList.Add('chrome.exe');

  // Edge
  FileList.Add(IncludeTrailingPathDelimiter(GetEnvironmentVariable('LOCALAPPDATA')) + 'Microsoft\Edge\User Data\Local State');
  ProcList.Add('edge.exe');

  // Whale
  FileList.Add(IncludeTrailingPathDelimiter(GetEnvironmentVariable('LOCALAPPDATA')) + 'Naver\Naver Whale\User Data\Local State');
  ProcList.Add('whale.exe');

  repeat
    WriteLn;
    Writeln('======================================================');
    Writeln('           Kyber Encryption Disable Tool v 0.9.0      ');
    Writeln('======================================================');

    if not Auto then
    begin
      Writeln(' This tool disables Kyber encryption for supported');
      Writeln;
      Writeln(' You can also run this tool with parameters:');
      Writeln(' /disable - Disable Kyber encryption automatically.');
      Writeln(' /enable  - Enable Kyber encryption automatically.');
      Writeln;
      Writeln(' [1] Check Kyber Status');
      Writeln(' [2] Enabled Kyber');
      Writeln(' [3] Disable Kyber');
      Writeln(' [4] Exit');
      Writeln('==================================================');
      Write(' Please enter your choice (1, 2, 3, 4): ');
      Readln(Input);
    end;

    WriteLn;

    case StrToIntDef(Input, -1) of
      1: // 체크
        begin
          for I := 0 to FileList.Count-1 do
          begin
            FileName := FileList[I];
            ProcName := ProcList[I];

            if not FileExists(FileName) then Continue;

            case IsKyber(FileName) of
              0: State := 'Default';
              1: State := 'Enabled';
              2: State := 'Disabled';
            end;

            WriteLn('[' + ProcName +'] TLS 1.3 hybridized Kyber support: ' + State);
          end;
        end;
      2: // 활성
        begin
          for I := 0 to FileList.Count-1 do
          begin
            FileName := FileList[I];
            SetKyber(FileName, True);
          end;

          Writeln('Kyber encryption has been enabled.');
        end;
      3: // 비활성
        begin
          for I := 0 to FileList.Count-1 do
          begin
            FileName := FileList[I];
            SetKyber(FileName, False);
          end;

          Writeln('Kyber encryption has been disabled.');
        end;
    end;
  until (Input = '4') or Auto;
end.
