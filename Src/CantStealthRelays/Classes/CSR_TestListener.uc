class CSR_TestListener extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local Object this;

	this = self;


	`XEVENTMGR.RegisterForEvent(this, 'ObjectInteraction', OnInteraction, ELD_OnStateSubmitted);
	`XEVENTMGR.RegisterForEvent(this, 'AbilityActivated', OnAbilityActivated, ELD_OnStateSubmitted);
}

// if this works it'll probably be better
function EventListenerReturn OnInteraction(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local XComGameState_Unit Unit;
	local XComGameState_InteractiveObject Interactive;
	local string UnitName;

	Unit = XComGameState_Unit(EventData);
	Interactive = XComGameState_InteractiveObject(EventSource);

	UnitName = (Unit.IsASoldier()) ? Unit.GetFullName() : string(Unit.GetMyTemplateName());
	`log(UnitName@"interacted with"@Interactive);

	return ELR_NoInterrupt;
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