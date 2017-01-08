/*
	Zupa's Capture Points
	Reward giver of ZCP
	Capture points and earn money over time.

	╔════╗─────────╔═══╗────────╔╗─────────────╔╗
	╚══╗═║─────────╚╗╔╗║────────║║────────────╔╝╚╗
	──╔╝╔╬╗╔╦══╦══╗─║║║╠══╦╗╔╦══╣║╔══╦╗╔╦══╦═╗╚╗╔╬══╗
	─╔╝╔╝║║║║╔╗║╔╗║─║║║║║═╣╚╝║║═╣║║╔╗║╚╝║║═╣╔╗╗║║║══╣
	╔╝═╚═╣╚╝║╚╝║╔╗║╔╝╚╝║║═╬╗╔╣║═╣╚╣╚╝║║║║║═╣║║║║╚╬══║
	╚════╩══╣╔═╩╝╚╝╚═══╩══╝╚╝╚══╩═╩══╩╩╩╩══╩╝╚╝╚═╩══╝
	────────║║
	────────╚╝
*/


private["_ZCP_GR_currentCapper","_ZCP_GR_reward","_ZCP_GR_rewardArray"];
_ZCP_GR_currentCapper = _this select 0;
_ZCP_GR_reward = _this select 3;
_ZCP_GR_rewardArray = _this select 5;

if(isPlayer _ZCP_GR_currentCapper)then
{
	if(ZCP_Add_MissionCompletion2DB) then
	{
		_newWeinerCaptures = _ZCP_GR_currentCapper getVariable ["ExileZCP", 0];
		_newWeinerCaptures = _newWeinerCaptures + 1;
		_ZCP_GR_currentCapper setVariable ["ExileZCP", _newWeinerCaptures];
		format["addAccountZCP:%1", getPlayerUID _ZCP_GR_currentCapper] call ExileServer_system_database_query_fireAndForget;
		ExileClientPlayerZCP = _newWeinerCaptures;
		(owner _ZCP_GR_currentCapper) publicVariableClient "ExileClientPlayerZCP";
		ExileClientPlayerZCP = nil;
	};
	if (DMS_Show_Party_Capture_Notification) then
	{
		private _group = group _ZCP_GR_currentCapper;
		private _members = units _group;
		_newWeinerCaptures = _ZCP_GR_currentCapper getVariable ["ExileZCP", 0];
		if ((count _members)>1) then
		{
			private _msg = format
			[
				"%1 just captured that mission! That's %2 ZCP captures so far",
				name _ZCP_GR_currentCapper,
				_newWeinerCaptures
			];
				{
				_msg remoteExecCall ["systemChat", _ZCP_GR_currentCapper];
			} forEach _members;
		};
	};
};


if (typeName _ZCP_GR_reward == "STRING") then {
    _ZCP_GR_reward = [_ZCP_GR_reward];
};

if (typeName _ZCP_GR_reward == "ARRAY") then {
    {
        switch (_x) do { // add extra cases here and in spawnCrate.sqf
            case "Reputation" : {
                _this call ZCP_fnc_rewardReputation;
            };
            case "Poptabs" : {
                _this call ZCP_fnc_rewardPoptabs;
            };
            case "BuildBox" : {
                [_this, _x, _ZCP_GR_rewardArray select _forEachIndex] call ZCP_fnc_rewardBox;
            };
            case "SurvivalBox" : {
                [_this, _x, _ZCP_GR_rewardArray select _forEachIndex] call ZCP_fnc_rewardBox;
            };
            case "WeaponBox" : {
                [_this, _x, _ZCP_GR_rewardArray select _forEachIndex] call ZCP_fnc_rewardBox;
            };
            case "BigWeaponBox" : {
                [_this, _x, _ZCP_GR_rewardArray select _forEachIndex] call ZCP_fnc_rewardBox;
            };
            case "SniperWeaponBox" : {
                [_this, _x, _ZCP_GR_rewardArray select _forEachIndex] call ZCP_fnc_rewardBox;
            };
            case "Vehicle" : {
                [_this, _ZCP_GR_rewardArray select _forEachIndex] call ZCP_fnc_rewardVehicle;
            };
            case "Random" : {
                private _ZCP_GR_rewardType = ZCP_RandomReward call BIS_fnc_selectRandom;
                private _ZCP_GR_newThis = +_this;
                _ZCP_GR_newThis set[3, [_ZCP_GR_rewardType]];
                _ZCP_GR_newThis call ZCP_fnc_giveReward;
            };
            default {
                private _ZCP_GR_newThis = +_this;
                _ZCP_GR_newThis set[3, ["Random"]];
                _ZCP_GR_newThis call ZCP_fnc_giveReward;
            };
        };
    }forEach _ZCP_GR_reward;
} else {
    diag_log text format["[ZCP]: Invalid reward for %1", _this];
};

