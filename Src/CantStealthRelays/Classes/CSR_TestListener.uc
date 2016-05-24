class CSR_TestListener extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local Object this;
	local XComGameStateHistory History;
	local XComGameState_BattleData BattleData;
	
	History = `XCOMHISTORY;
	BattleData = XComGameState_BattleData(History.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));

	// check mission objectives to see if the mod should do anything
	if(INDEX_NONE == BattleData.MapData.ActiveMission.MapNames.find("Obj_DestroyObject"))
	{
		return;
	}
	
	this = self;
	
	`XEVENTMGR.RegisterForEvent(this, 'AbilityActivated', OnAbilityActivated, ELD_OnStateSubmitted);
}

function XComGameState_InteractiveObject GetRelay()
{
	local XComInteractiveLevelActor InteractiveActor;
	local XComGameState_InteractiveObject Relay;
	foreach `BATTLE.AllActors(class'XComInteractiveLevelActor', InteractiveActor)
	{
		Relay = InteractiveActor.GetInteractiveState();
		if(none != Relay && INDEX_NONE != InStr(Relay.ArchetypePath, "AlienRelay"))
		{
			return Relay;
		}
	}
	return none;
}

// this will definitely work
function EventListenerReturn OnAbilityActivated(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	//Data - Ability State (XComGameState_Ability)
	//Source - Unit
	//AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
	//Target - AbilityContext.InputContext.PrimaryTarget.ObjectID

	//AbilityContext.InputContext.AbilityTemplateName == 'StandardShot'
	local XComGameState_Ability AbilityState;
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Unit SourceUnit;
	local XComGameStateHistory History;
	local string UnitName;

	AbilityState = XComGameState_Ability(EventData);
	SourceUnit = XComGameState_Unit(EventSource);
	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());

	if(none == AbilityState || none == SourceUnit || none == AbilityContext)
	{
		`log("Someting failed here");
		return ELR_NoInterrupt;
	}

	UnitName = (SourceUnit.IsASoldier()) ? SourceUnit.GetFullName() : string(SourceUnit.GetMyTemplateName());
	`log(UnitName@"activated"@AbilityState.GetMyTemplateName());

	History = `XCOMHISTORY;
	`log("Target:"@History.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));

	return ELR_NoInterrupt;
}

defaultproperties
{
	ScreenClass = UITacticalHUD;
}