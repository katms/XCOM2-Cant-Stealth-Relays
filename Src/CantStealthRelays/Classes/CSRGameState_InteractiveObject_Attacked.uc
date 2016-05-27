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
	local StateObjectReference Ref;
	local XComGameState_AIGroup AIGroup;

	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());

	// if the owning relay was attacked and this isn't an interrupt
	if(OwningObjectID == AbilityContext.InputContext.PrimaryTarget.ObjectID)
	{
		// causes a compiler error if I try to put the constant on the left or in the same if statement as above
		if(AbilityContext.InterruptionStatus == eInterruptionStatus_Interrupt)
		{
			return ELR_NoInterrupt;
		}

		History = `XCOMHISTORY;

		// get all aliens who can see the relay
		`TACTICALRULES.VisibilityMgr.GetAllViewersOfTarget(OwningObjectID, Viewers, class'XComGameState_Unit', -1, Conditions);

		foreach History.IterateByClassType(class'XComGameState_AIGroup', AIGroup)
		{
			// if this group hasn't activated yet
			if(!(AIGroup.bProcessedScamper || AIGroup.bPendingScamper))
			{
				// if this group has someone who can see the relay
				foreach Viewers(Ref)
				{
					if(INDEX_NONE != AIGroup.m_arrMembers.find('ObjectID',Ref.ObjectID))
					{
						`log("Activating"@AIGroup);
						AIGroup.ApplyAlertAbilityToGroup(eAC_TakingFire);
						AIGroup.InitiateReflexMoveActivate(XComGameState_Unit(EventSource), eAC_SeesSpottedUnit);
						break;
					}
				}
			}
		}
	}
	
	return ELR_NoInterrupt;
}

defaultproperties
{
	Begin Object Class=X2Condition_UnitProperty Name=DefaultCSRLivingAlienProperty
		ExcludeDead=true
		ExcludeCivilian=true
		ExcludeHostileToSource=true // doesn't seem to actually exclude xcom from results, I guess relays don't consider them hostile
		ExcludeCosmetic=true
	End Object

	Conditions(0)=DefaultCSRLivingAlienProperty
}