{* Copyright (C) 2016
    Ken Bourassa @ http://www.allbitsareoff.com - All Rights Reserved
 *}
 unit ab.MemUtils;

interface

type
  TRedirectHandle = NativeInt;

function RedirectCall(OriginalCode, NewCode: Pointer) : TRedirectHandle;
procedure RestoreCall(AHandle: TRedirectHandle);

implementation

uses
  System.SysUtils,
  WinApi.Windows

  ;

type
  TJumpData = packed record
    Jump: Byte;
    Offset: Integer;
  end;

  TRedirHandleData = packed record
    OriginalCodeAddr : Pointer;
    OriginalInstr: TJumpData;
  end;


function RedirectCall(OriginalCode, NewCode: Pointer) : TRedirectHandle;
var
  cbBuffer: NativeUint;
  hRedir: ^TRedirHandleData absolute Result;
  vJumpData : TJumpData;
begin
  Assert(OriginalCode <> nil);
  Assert(NewCode <> nil);
  //It would probably be better to prevent redirection for pointers that are in different modules.
  //Otherwise, this can lead to some really messy results when dynamically loading/unloading DLLs
  New(hRedir); //New(Result)
  try
    if ReadProcessMemory(GetCurrentProcess, OriginalCode, @hRedir.OriginalInstr, SizeOf(hRedir.OriginalInstr), cbBuffer) then
    begin
      hRedir.OriginalCodeAddr := OriginalCode;
      vJumpData.Jump := $E9;
      vJumpData.Offset := NativeInt(NewCode) - NativeInt(OriginalCode) - SizeOf(hRedir.OriginalInstr);
      if not WriteProcessMemory(GetCurrentProcess, OriginalCode, @vJumpData, SizeOf(vJumpData), cbBuffer) then
      begin
        Dispose(hRedir);
        hRedir := nil;
      end;
    end else
      hRedir := nil; //Result := nil;
  except
    Dispose(hRedir);
    raise;
  end;
end;

procedure RestoreCall(AHandle: TRedirectHandle);
var
  cbBuffer: NativeUint;
  hRedir: ^TRedirHandleData absolute AHandle;
begin
  if hRedir = nil then EXIT;

  try
    if (hRedir.OriginalCodeAddr <> nil) then
    begin
      //If the write fails, I'm not sure how we can recover.
      WriteProcessMemory(GetCurrentProcess, hRedir.OriginalCodeAddr, @hRedir.OriginalInstr, SizeOf(hRedir.OriginalInstr), cbBuffer);
    end;
  finally
    Dispose(hRedir);
  end;
end;

end.
