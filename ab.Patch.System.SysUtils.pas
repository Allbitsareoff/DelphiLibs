{* Copyright (C) 2016
    Ken Bourassa @ http://www.allbitsareoff.com - All Rights Reserved
 *}
unit ab.Patch.System.SysUtils;

interface

implementation

uses
  System.SysUtils,
  System.StrUtils,
  ab.MemUtils
  ;

var
  uStringReplaceRedirect : TRedirectHandle;

function abStringReplace(const S, OldPattern, NewPattern: string;
  Flags: TReplaceFlags): string;
const
  FirstIndex = Low(string);
var
  SearchStr, Patt, NewStr : string;
  Offset, I, L, idxStart: Integer;
begin
  if rfIgnoreCase in Flags then
  begin
    SearchStr := AnsiUpperCase(S);
    Patt := AnsiUpperCase(OldPattern);
  end else
  begin
    SearchStr := S;
    Patt := OldPattern;
  end;
  NewStr := S;
  Result := '';
  if SearchStr.Length <> S.Length then
  begin
    I := FirstIndex;
    L := OldPattern.Length;
    while I <= High(S) do
    begin
      if string.Compare(S, I - FirstIndex, OldPattern, 0, L, True) = 0 then
      begin
        Result := Result + NewPattern;
        Inc(I, L);
        if not (rfReplaceAll in Flags) then
        begin
          Result := Result + S.Substring(I - FirstIndex, MaxInt);
          Break;
        end;
      end
      else
      begin
        Result := Result + S[I];
        Inc(I);
      end;
    end;
  end
  else
  begin
    Offset := PosEx(Patt, SearchStr);
    if Offset = 0 then
      Result := S
    else
    begin
      if not (rfReplaceAll in Flags) then
        Result := Copy(S, 1, OffSet - 1) + NewPattern + Copy(S, Offset + Length(OldPattern), MaxInt)
      else
      begin
        idxStart := 1;
        repeat
          Result := Result + Copy(S, idxStart, OffSet - idxStart) + NewPattern;
          idxStart := Offset + Length(Patt);
          Offset := PosEx(Patt, SearchStr, idxStart);
        until Offset = 0;
        Result := Result + Copy(S, idxStart, MaxInt);
      end;
    end;
  end;
end;

initialization
  uStringReplaceRedirect := RedirectCall(@StringReplace, @abStringReplace)

finalization
  RestoreCall(uStringReplaceRedirect);

end.
