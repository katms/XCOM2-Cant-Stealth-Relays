class CSR_TacticalListener extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local XComGameStateHistory History;
	local XComGameState_BattleData BattleData;
	
	History = `XCOMHISTORY;
	BattleData = XComGameState_BattleData(History.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));

	// check mission objectives to see if the mod should do anything
	if("DestroyObject" != BattleData.MapData.ActiveMission.MissionFamily)
	{
		`log("objective not found");
		return;
	}
	AttachComponent();
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

function AttachComponent()
{
	local XComGameState NewGameState;
	local XComGameState_InteractiveObject Relay, UpdatedRelay;
	local CSRGameState_InteractiveObject_Attacked Component;

	Relay = GetRelay();

	if(none == Relay)
	{
		`log("Relay not found");
		return;
	}

	
	if(none != Relay.FindComponentObject(class'CSRGameState_InteractiveObject_Attacked'))
	{
		`log("Component found");
		return;
	}

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Adding listener object for relay");

	UpdatedRelay = XComGameState_InteractiveObject(NewGameState.CreateStateObject(class'XComGameState_InteractiveObject', Relay.ObjectID));
	Component = CSRGameState_InteractiveObject_Attacked(NewGameState.CreateStateObject(class'CSRGameState_InteractiveObject_Attacked'));

	UpdatedRelay.AddComponentObject(Component);

	Component.InitComponent();

	NewGameState.AddStateObject(Component);
	NewGameState.AddStateObject(UpdatedRelay);

	`XCOMHISTORY.AddGameStateToHistory(NewGameState);
	`log("Added component to relay");
}

defaultproperties
{
	ScreenClass = UITacticalHUD;
}