{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
program SplashPreprocessor;

{$APPTYPE CONSOLE}

uses
  Windows, SysUtils, Graphics, PNGImage;

type
  TRGBTripleArray = Array[0..High(Word) - 1] of TRGBTriple;
  PRGBTripleArray = ^TRGBTripleArray;
  TRGBQuadArray   = Array[0..High(Word) - 1] of TRGBQuad;
  PRGBQuadArray   = ^TRGBQuadArray;

//------------------------------------------------------------------------------

  procedure AssignPNGtoBMP(PNG: TPNGObject; BMP: TBitmap);
  var
    PNGColor: PRGBTripleArray;
    PNGAlpha: PByteArray;
    BMPColor: PRGBQuadArray;
    x,y:      Integer;
  begin
    BMP.Width := PNG.Width;
    BMP.Height := PNG.Height;
    For y := 0 to Pred(BMP.Height) do
      begin
        PNGColor := PNG.Scanline[y];
        PNGAlpha := PNG.AlphaScanLine[y];
        BMPColor := BMP.ScanLine[y];
        For x := 0 to Pred(BMP.Width) do
          begin
            BMPColor[x].rgbRed := PNGColor[x].rgbtRed;
            BMPColor[x].rgbGreen := PNGColor[x].rgbtGreen;
            BMPColor[x].rgbBlue := PNGColor[x].rgbtBlue;
            BMPColor[x].rgbReserved := PNGAlpha[x];
          end;
      end;
  end;

//------------------------------------------------------------------------------

  procedure BitmapColorPremultiply(BMP: TBitmap);
  var
    BlendValues:  Array[Byte,Byte] of Byte;
    BMPColor:     PRGBQuadArray;
    x,y:          Integer;
  begin
    For y := 0 to 255 do
      For x := 0 to 255 do
        BlendValues[x,y] := (x * y) div 255;
    For y := 0 to Pred(BMP.Height) do
      begin
        BMPColor := BMP.ScanLine[y];
        For x := 0 to Pred(BMP.Width) do
          begin
            BMPColor[x].rgbBlue := BlendValues[BMPColor[x].rgbBlue,BMPColor[x].rgbReserved];
            BMPColor[x].rgbGreen := BlendValues[BMPColor[x].rgbGreen,BMPColor[x].rgbReserved];
            BMPColor[x].rgbRed := BlendValues[BMPColor[x].rgbRed,BMPColor[x].rgbReserved];
          end;
      end;
  end;

//------------------------------------------------------------------------------

  procedure Preprocess(const FileName: String);
  var
    PNG:  TPNGObject;
    BMP:  TBitmap;
  begin
    BMP := TBitmap.Create;
    try
      BMP.PixelFormat := pf32bit;
      PNG := TPNGObject.Create;
      try
        PNG.LoadFromFile(FileName);
        AssignPNGtoBMP(PNG,BMP);
      finally
        PNG.Free;
      end;
      BitmapColorPremultiply(BMP);
      BMP.SaveToFile(ChangeFileExt(FileName,'.bmp'));
    finally
      BMP.Free;
    end;
  end;

//------------------------------------------------------------------------------

begin
try
  If ParamCount > 0 then
    Preprocess(ParamStr(1));
except
  WriteLn('Unhadled exception.');
end;
end.
