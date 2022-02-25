// how much damage before death, 50% starts internal contamination
cbrn_maxDamage = 100;

// backpacks considered oxygen tanks
cbrn_backpacks = ["B_SCBA_01_F",
	"B_CombinationUnitRespirator_01_F"];

// backpacks considered air conditioners; help reduce fogging
cbrn_conditioning = ["B_CombinationUnitRespirator_01_F"];

// uniforms considered CBRN suits
cbrn_suits = ["U_C_CBRN_Suit_01_Blue_F",
    "U_B_CBRN_Suit_01_MTP_F",
    "U_B_CBRN_Suit_01_Tropic_F",
    "U_C_CBRN_Suit_01_White_F",
    "U_B_CBRN_Suit_01_Wdl_F",
    "U_I_CBRN_Suit_01_AAF_F",
    "U_I_E_CBRN_Suit_01_EAF_F"];

// goggles considered gas masks (filters included)
cbrn_masks = ["G_AirPurifyingRespirator_02_black_F",
    "G_AirPurifyingRespirator_02_olive_F",
    "G_AirPurifyingRespirator_02_sand_F",
    "G_AirPurifyingRespirator_01_F",
    "G_RegulatorMask_F",
    "GP21_GasmaskPS",
    "GP5Filter_RaspiratorPS",
    "GP7_RaspiratorPS",
    "SE_M17",
    "Hamster_PS",
    "SE_S10"];

// Item that is considered a threat meter
cbrn_threatMeteritem = "ACE_microDAGR";

cbrn_threatGeiger = "ACE_microDAGR";

// after how much time does the air run out in an oxygen tank (in seconds!)
cbrn_maxOxygenTime = 60 * 30;

// should auto damage occur after 50% damage threshold has been reached?
cbrn_allowPassiveDamage = true;

// time in seconds how much water a decon shower has, in seconds
cbrn_deconWaterTime = 60 * 2;

// healing rate for each second, does nothing if 0 or below, or player while player is experiencing passive contamination
cbrn_healingRate = 0;


// FOGGING SETTINGS
// enables or disables fogging entirely
cbrn_foggingEnabled = true;
// time after which the gas mask starts fogging up; default 5 mins
cbrn_fogStartTime = 60 * 5;
// maximum time after which the gas mask is fully fogged up; default 10 mins
cbrn_fogMaxTime = 60 * 10;
// fog accumulation coefficient; used when unit wears a backpack considered an air conditioner; lower means fogging accumulates slower, 0 stops it entirely; default 0.5
cbrn_fogAccumulationCoef = 0.5;
// fog fading coefficient; is used in multiplication with the frame-time delta in fogPFH when the gasmask is taken off; higher means accumulated fog will fade faster; default 5
cbrn_fogFadeCoef = 5;

// FATIGUE SETTINGS
// whether or not fogging takes Fatigue into account
cbrn_fogFatigueEnabled = true;
// Fatigue coefficient; is used in multiplication with the ACE fatigue value; higher means quicker fogging if unit has any fatigue
cbrn_fogFatigueCoef = 1;


// configure vehicles to be CBRN proof
// list of arrays, first entry vehicle class or 3den editor object name as string, second entry amount of proofing. The amount is the same measurement as zone threat levels
cbrn_vehicles = [
    ["vroomvroom", 5],
    ["B_Quadbike_01_F", 1]
];
