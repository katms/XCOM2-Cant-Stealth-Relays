class CSRGameState_InteractiveObject_Attacked extends XComGameState_BaseObject
	config(CantStealthRelays);

// artificially limit activations to pods within this radius, to prevent too many cases of WHAT DO YOU MEAN YOU CAN SEE IT TOO?
var config float AlertRadius;

var array<X2Condition> Conditions;

function InitComponent()
{
	local Object this;
	this = self;

	// listen for attacks
	`XEVENTMGR.RegisterForEvent(this, 'AbilityActivated', OnAbilityActivated, ELD_OnStateSubmitted);
}

// if the owning relay was shot
function EventListenerReturn OnAbilityActivated(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local XComGameStateContext_Ability AbilityContext;
	local XComGameStateHistory History;
	local XComGameState_Ability AbilityState;
	local array<StateObjectReference> Viewers;
	local StateObjectReference Ref;
	local XComGameState_AIGroup AIGroup;

	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());

	// if the owning relay was attacked and this isn't an interrupt
	if(OwningObjectID == AbilityContext.InputContext.PrimaryTarget.ObjectID || INDEX_NONE != AbilityContext.InputContext.MultiTargets.find('ObjectID', OwningObjectID))
	{
		// causes a compiler error if I try to put the constant on the left or in the same if statement as above
		if(AbilityContext.InterruptionStatus == eInterruptionStatus_Interrupt)
		{
			return ELR_NoInterrupt;
		}

		AbilityState = XComGameState_Ability(EventData);

		// ignore yells
		if('Yell' == AbilityState.GetMyTemplateName())
		{
			return ELR_NoInterrupt;			
		}

		History = `XCOMHISTORY;

		// get all aliens who can see the relay
		`TACTICALRULES.VisibilityMgr.GetAllViewersOfTarget(OwningObjectID, Viewers, class'XComGameState_Unit', -1, Conditions);

		foreach History.IterateByClassType(class'XComGameState_AIGroup', AIGroup)
		{
			// if this group hasn't activated yet
			if(!(AIGroup.bProcessedScamper || AIGroup.bPendingScamper) && ApplyFilter(AIGroup))
			{
				// if this group has someone who can see the relay
				foreach Viewers(Ref)
				{
					if(INDEX_NONE != AIGroup.m_arrMembers.find('ObjectID',Ref.ObjectID))
					{
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

// filter AIGroups based on config settings
function bool ApplyFilter(const XComGameState_AIGroup AIGroup)
{
	//return default.LimitActivationsToSeen ? AIGroup.EverSightedByEnemy : true;
	local XComGameStateHistory History;
	local StateObjectReference Ref;
	local XComGameState_Unit Unit;
	local XComGameState_InteractiveObject OwnerRelay;

	History = `XCOMHISTORY;
	OwnerRelay = XComGameState_InteractiveObject(History.GetGameStateForObjectID(OwningObjectID));

	// no limit
	if(AlertRadius <= 0)
	{
		return true;
	}

	// check if any members are within AlertRadius tiles
	foreach AIGroup.m_arrMembers(Ref)
	{
		Unit = XComGameState_Unit(History.GetGameStateForObjectID(Ref.ObjectID));
		if(class'Helpers'.static.IsTileInRange(Unit.TileLocation, OwnerRelay.TileLocation, AlertRadius*AlertRadius))
		{
			return true;
		}
	}
	return false;
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