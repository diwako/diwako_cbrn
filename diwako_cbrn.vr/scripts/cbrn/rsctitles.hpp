class cbrn_gasmask {
    idd = -1;
    movingEnable = false;
    duration = 999999;
    onLoad = "";
    controlsBackground[] = {overlay};
    objects[] = {};
    controls[] = {};

    class overlay {
        idc = 1337;
        type = 0;
        style = 48;
        colorBackground[] = { };
        colorText[] = { };
        font = "PuristaMedium";
        sizeEx = 1.0;
        moving = false;
        x = safeZoneXAbs;
        y = SafeZoneY - safeZoneH / 4;
        w = safeZoneWAbs;
        h = safeZoneH * 1.5;
        text = "scripts\cbrn\images\gas.paa";
    };
};

class cbrn_fog {
    idd = 1000;
    movingEnable = false;
    duration = 999999;
    onLoad = "cbrn_fogDisplay = _this"
    controlsBackground[] = {overlay};
    objects[] = {};

    class overlay {
        idc = 1336;
        type = 0;
        style = 48;
        colorBackground[] = { };
        colorText[] = { 1,1,1,0 };
        font = "PuristaMedium";
        sizeEx = 1.0;
        moving = false;
        x = safeZoneXAbs;
        y = SafeZoneY - safeZoneH / 4;
        w = safeZoneWAbs;
        h = safeZoneH * 1.5;
        text = "scripts\cbrn\images\fog_overlay.paa";
    };
};
