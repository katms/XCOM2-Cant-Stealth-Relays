class CSRGameState_InteractiveObject_Attacked extends XComGameState_BaseObject;

var array<X2Condition> Conditions;

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
	local XComGameStateHistory History;
	local array<StateObjectReference> Viewers;
	local XComGameState_Unit Unit;
	local int i;

	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
	if(OwningObjectID == AbilityContext.InputContext.PrimaryTarget.ObjectID)
	{
		History = `XCOMHISTORY;
		`log("Relay attacked");
		`log(AbilityContext.InterruptionStatus);
		`log(AbilityContext.InputContext.AbilityTemplateName);
		`log("Current health:"@XComGameState_InteractiveObject(History.GetGameStateForObjectID(OwningObjectID)).Health);
		`TACTICALRULES.VisibilityMgr.GetAllViewersOfTarget(OwningObjectID, Viewers, class'XComGameState_Unit', -1, Conditions);
		for(i = 0; i < Viewers.length; ++i)
		{
			Unit = XComGameState_Unit(History.GetGameStateForObjectID(Viewers[i].ObjectID));
			if(!Unit.IsASoldier())
			{
				`log(Unit.GetMyTemplate().Dataname);
			}
		}
	}
	
	return ELR_NoInterrupt;
}

defaultproperties
{
	Begin Object Class=X2Condition_UnitProperty Name=DefaultCSRLivingEnemyProperty
		ExcludeDead=true
		ExcludeCivilian=true
		ExcludeHostileToSource=true // doesn't seem to actually exclude xcom from results, I guess relays don't consider them hostile
		ExcludeCosmetic=true
	End Object

	Conditions(0)=DefaultCSRLivingEnemyProperty
}