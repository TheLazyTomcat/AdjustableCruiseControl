{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
unit ACC_PluginComm;

interface

{$INCLUDE ACC_Defs.inc}

const
  WMC_MessageName = 'ACC_WMC_157D1E5E-BD6A-4804-AF05-EAC936C83FE0';

  WMC_CODE_SetCCSpeed = $01;
  WMC_CODE_SpeedInc   = $02;
  WMC_CODE_SpeedHome  = $03;
  WMC_CODE_SpeedRoads = $04;
  WMC_CODE_SpeedUser0 = $05;
  WMC_CODE_SpeedUser9 = WMC_CODE_SpeedUser0 + 9;
  WMC_CODE_SetToLimit = $20;
  WMC_CODE_LimitStart = $21;
  WMC_CODE_LimitStop  = $22;
  WMC_CODE_SpeedLimit = $23;
  WMC_CODE_Features   = $FF;

  // Plugin features
  WMC_PF_Speed = $1;
  WMC_PF_Limit = $2;

implementation

end.
