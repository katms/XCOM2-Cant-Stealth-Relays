class CSRGameState_InteractiveObject_Attacked extends XComGameState_BaseObject;

function InitComponent()
{
	local Object this;
	this = self;

	`log("InitCOmponent");

	// listen for attacks
	`XEVENTMGR.RegisterForEvent(this, 'AbilityActivated', OnAbilityActivated, ELD_OnStateSubmitted);
}

function EventListenerReturn OnAbilityActivated(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local XComGameStateContext_Ability AbilityContext;
	

	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
	`log("Ability activated");
	if(OwningObjectID == AbilityContext.InputContext.PrimaryTarget.ObjectID)
	{
		`log("Relay attacked");
	}
	
	return ELR_NoInterrupt;
}