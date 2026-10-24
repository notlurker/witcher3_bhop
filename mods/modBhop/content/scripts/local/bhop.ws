// Half-Life 1 air strafing, active only while Gervant First Person is the view.
// GoldSrc units: sv_airaccelerate 10, sv_maxspeed 320, wish cap 30, command speed 400, 100 Hz.
// Holding jump skips the HL1 jump-release check. The 1.7x bunnyhop speed crop is not applied.

@addField(CExplorationStateJump)
var m_BhopActiveB : bool;

@addField(CExplorationStateJump)
var m_BhopWasAirborneB : bool;

@addField(CExplorationStateJump)
var m_BhopVelV : Vector;

@addField(CExplorationStateJump)
var m_BhopStepV : Vector;

@addField(CExplorationStateJump)
var m_BhopSimTimeF : float;

@addField(CExplorationStateJump)
var m_BhopMotionOffB : bool;

@addField(CExplorationStateJump)
var m_BhopHasSavedJumpB : bool;

@addField(CExplorationStateJump)
var m_BhopSavedSubstateE : EJumpSubState;

@addField(CExplorationStateJump)
var m_BhopSavedTakeOffF : float;

@addField(CExplorationStateJump)
var m_BhopSavedPhysicB : bool;

@addField(CExplorationStateJump)
var m_BhopSavedRecalcB : bool;

@addField(CExplorationStateJump)
var m_BhopSavedAirControlB : bool;

@addField(CExplorationStateJump)
var m_BhopSavedOrientF : float;

@addField(CExplorationStateJump)
var m_BhopSavedLandTimeF : float;

@addField(CExplorationStateJump)
var m_BhopSavedCanSetVelB : bool;

@addField(CExplorationStateJump)
var m_BhopSavedVelV : Vector;

@addField(CExplorationStateManager)
var m_BhopJumpO : CExplorationStateJump;


@addMethod(CExplorationStateJump)
function BhopTick() : float
{
	return 0.01;
}

@addMethod(CExplorationStateJump)
function BhopAirAccelRate() : float
{
	return 10.0;
}

@addMethod(CExplorationStateJump)
function BhopWishCapUU() : float
{
	return 30.0;
}

@addMethod(CExplorationStateJump)
function BhopMaxSpeedUU() : float
{
	return 320.0;
}

@addMethod(CExplorationStateJump)
function BhopCommandSpeedUU() : float
{
	return 400.0;
}

@addMethod(CExplorationStateJump)
function BhopSimLimit() : float
{
	return 0.1;
}

@addMethod(CExplorationStateJump)
function BhopMetersPerUnit() : float
{
	return 0.0254;
}

@addMethod(CExplorationStateJump)
function BhopJumpSpeed() : float
{
	// sqrt(2 * 800 * 45) inches/s, in meters. Standing HL1 jump.
	return 6.815535;
}

@addMethod(CExplorationStateJump)
function BhopGravity() : float
{
	// sv_gravity 800 inches/s^2 is 20.32 m/s^2. UpdateParabolicVerticalMovement
	// decelerates at three times the stored value, so store one third.
	return 6.773333;
}

@addMethod(CExplorationStateJump)
function BhopTerminalSpeed() : float
{
	// sv_maxvelocity 2000 inches/s, in meters.
	return 50.8;
}

@addMethod(CExplorationStateJump)
function BhopFlat( v : Vector ) : Vector
{
	v.Z = 0.0;
	v.W = 0.0;
	return v;
}

@addMethod(CExplorationStateJump)
function BhopFlatUnit( v : Vector ) : Vector
{
	v = BhopFlat( v );
	if( VecLength2D( v ) >= 0.01 )
	{
		return VecNormalize2D( v );
	}

	return v;
}

@addMethod(CExplorationStateJump)
function BhopInFirstPerson() : bool
{
	return FP().IsRunning();
}

@addMethod(CExplorationStateJump)
function BhopPlayerIsOnFoot() : bool
{
	return thePlayer.GetCurrentStateName() == 'Exploration'
		&& !thePlayer.IsInCombatAction()
		&& !thePlayer.IsInCombat()
		&& !thePlayer.IsSwimming()
		&& !thePlayer.IsInShallowWater();
}

@addMethod(CExplorationStateJump)
function BhopNearHorse() : bool
{
	if( !m_LockingJumpOnHorseAreaB )
	{
		return false;
	}

	if( !thePlayer.horseInteractionSource )
	{
		return false;
	}

	if( !thePlayer.IsMountingHorseAllowed( true ) )
	{
		return false;
	}

	return VecDistance( thePlayer.GetWorldPosition(), thePlayer.horseInteractionSource.GetWorldPosition() ) < 3.0;
}

@addMethod(CExplorationStateJump)
function BhopInteractionBlocks() : bool
{
	return m_InteractionLastLockingF > 0.0 || thePlayer.IsInsideInteraction() || BhopNearHorse();
}

@addMethod(CExplorationStateJump)
function BhopSignCastBlocks() : bool
{
	return !theInput.LastUsedPCInput() && thePlayer.GetInputHandler().GetIsAltSignCasting() && theInput.IsActionPressed( 'CastSign' );
}

@addMethod(CExplorationStateJump)
function BhopCanHop() : bool
{
	return BhopInFirstPerson() && BhopPlayerIsOnFoot() && !BhopInteractionBlocks() && !BhopSignCastBlocks();
}

@addMethod(CExplorationStateJump)
function BhopIsNormalJump() : bool
{
	var jumpType : EJumpType;

	jumpType = m_JumpParmsS.m_JumpTypeE;
	return jumpType == EJT_Idle
		|| jumpType == EJT_IdleToWalk
		|| jumpType == EJT_Walk
		|| jumpType == EJT_WalkHigh
		|| jumpType == EJT_Run
		|| jumpType == EJT_Sprint
		|| jumpType == EJT_Slide
		|| jumpType == EJT_Fall;
}

@addMethod(CExplorationStateJump)
function BhopCanLand() : bool
{
	if( !BhopPlayerIsOnFoot() || BhopInteractionBlocks() )
	{
		return false;
	}

	return m_BhopWasAirborneB && m_ExplorationO.GetStateTimeF() > 0.05;
}

@addMethod(CExplorationStateJump)
function BhopRememberJump()
{
	m_BhopHasSavedJumpB = true;
	m_BhopSavedSubstateE = m_SubstateE;
	m_BhopSavedTakeOffF = m_JumpParmsS.m_TakeOffTimeF;
	m_BhopSavedPhysicB = m_JumpParmsS.m_UsePhysicJumpB;
	m_BhopSavedRecalcB = m_JumpParmsS.m_RecalcSpeedOnInertialB;
	m_BhopSavedAirControlB = m_JumpParmsS.m_AllowAirDisplacementControlB;
	m_BhopSavedOrientF = m_JumpParmsS.m_OrientationSpeedF;
	m_BhopSavedLandTimeF = m_JumpParmsS.m_TimeToPrepareForLandF;
	m_BhopSavedCanSetVelB = m_CanSetVelocityB;
}

@addMethod(CExplorationStateJump)
function BhopRestoreJump()
{
	if( !m_BhopHasSavedJumpB )
	{
		return;
	}

	m_JumpParmsS.m_TakeOffTimeF = m_BhopSavedTakeOffF;
	m_JumpParmsS.m_UsePhysicJumpB = m_BhopSavedPhysicB;
	m_JumpParmsS.m_RecalcSpeedOnInertialB = m_BhopSavedRecalcB;
	m_JumpParmsS.m_AllowAirDisplacementControlB = m_BhopSavedAirControlB;
	m_JumpParmsS.m_OrientationSpeedF = m_BhopSavedOrientF;
	m_JumpParmsS.m_TimeToPrepareForLandF = m_BhopSavedLandTimeF;
	m_CanSetVelocityB = m_BhopSavedCanSetVelB;
	m_LandPredictedB = false;
	m_ExplorationO.m_SharedDataO.m_JumpIsTooSoonToLandB = m_ExplorationO.GetStateTimeF() < m_BhopSavedLandTimeF;
	m_ExplorationO.SetBehaviorParamBool( m_BehParamIsHandledByAnimS, !m_BhopSavedPhysicB );
	m_ExplorationO.m_MoverO.SetPlaneMovementParams( m_JumpParmsS.m_HorMovementS );
	m_ExplorationO.m_MoverO.SetVerticalMovementParams( m_JumpParmsS.m_VerticalMovementS );
	// Takeoff is already over. Putting that substate back makes the next update
	// play Flight, which applies a new jump impulse and refuses the landing.
	if( m_ExplorationO.GetStateTimeF() >= m_BhopSavedTakeOffF )
	{
		if( m_BhopSavedPhysicB && m_JumpParmsS.m_JumpTypeE != EJT_Sprint )
		{
			m_SubstateE = JSS_Inertial;
			m_ExplorationO.m_MoverO.SetPlaneMovementParams( m_JumpParmsFallS.m_HorMovementS );
			m_ExplorationO.m_MoverO.SetVerticalMovementParams( m_JumpParmsFallS.m_VerticalMovementS );
		}
		else
		{
			m_SubstateE = JSS_Flight;
		}
	}
	else
	{
		m_SubstateE = m_BhopSavedSubstateE;
	}
	m_BhopHasSavedJumpB = false;
}

@addMethod(CExplorationStateJump)
function BhopStop()
{
	if( m_BhopActiveB )
	{
		BhopRestoreJump();
	}

	m_BhopActiveB = false;
	m_BhopWasAirborneB = false;
	m_BhopSimTimeF = 0.0;
	VecSetZeros( m_BhopVelV );
	VecSetZeros( m_BhopSavedVelV );
	VecSetZeros( m_BhopStepV );

	if( m_BhopMotionOffB )
	{
		BhopSetExtractedMotion( true );
		m_BhopMotionOffB = false;
	}
}

@addMethod(CExplorationStateJump)
function BhopSetExtractedMotion( useMotion : bool )
{
	thePlayer.GetRootAnimatedComponent().SetUseExtractedMotion( useMotion );
}

@addMethod(CExplorationStateJump)
function BhopYieldToThirdPerson()
{
	if( m_BhopActiveB && !BhopInFirstPerson() )
	{
		BhopHandBack();
	}
}

@addMethod(CExplorationStateJump)
function BhopHandBack()
{
	var velocity	: Vector;
	var vertical	: float;
	var maxDown		: float;

	velocity = BhopFlat( m_BhopSavedVelV );
	if( VecLength2D( velocity ) < 0.01 )
	{
		velocity = BhopFlat( VecFromHeading( m_ExplorationO.m_OwnerE.GetHeading() ) * m_JumpParmsS.m_HorImpulseF );
	}
	vertical = m_ExplorationO.m_MoverO.GetMovementVerticalSpeedF();
	BhopStop();
	m_ExplorationO.m_MoverO.SetVelocity( velocity );

	if( m_SubstateE == JSS_Inertial )
	{
		maxDown = m_JumpParmsFallS.m_VerticalMovementS.m_VertMaxSpeedF;
	}
	else
	{
		maxDown = m_JumpParmsS.m_VerticalMovementS.m_VertMaxSpeedF;
	}
	if( maxDown < 0.0 && vertical < maxDown )
	{
		vertical = maxDown;
	}
	m_ExplorationO.m_MoverO.SetVerticalSpeed( vertical );
}

@addMethod(CExplorationStateJump)
function BhopReleaseToGround()
{
	var velocity : Vector;

	velocity = BhopFlat( m_BhopVelV );
	m_ExplorationO.m_MoverO.SetVelocity( velocity );
	m_ExplorationO.m_MoverO.SetManualMovement( false );
	m_ExplorationO.m_MoverO.SetVerticalSpeed( 0.0 );
	m_ExplorationO.m_SharedDataO.ResetHeightFallen();
	BhopStop();
	SetReadyToChangeTo( m_ExplorationO.GetDefaultStateName() );
}

@addMethod(CExplorationStateJump)
function BhopConsiderVelocity( current : Vector, candidate : Vector ) : Vector
{
	if( VecLength2D( candidate ) > VecLength2D( current ) )
	{
		return candidate;
	}

	return current;
}

@addMethod(CExplorationStateJump)
function BhopHorizontalVelocity() : Vector
{
	var best		: Vector;
	var impulse		: Vector;

	best = BhopFlat( m_ExplorationO.m_MoverO.GetMovementHorizontalVelocityV() );
	best = BhopConsiderVelocity( best, BhopFlat( m_ExplorationO.m_OwnerMAC.GetVelocity() ) );

	if( m_JumpParmsS.m_HorImpulseF > 0.2 )
	{
		impulse = BhopFlat( VecFromHeading( m_OrientationInitialF ) * m_JumpParmsS.m_HorImpulseF );
		best = BhopConsiderVelocity( best, impulse );
	}

	return best;
}

@addMethod(CExplorationStateJump)
function BhopApplyCoastParams()
{
	var plane	: SPlaneMovementParameters;
	var vert	: SVerticalMovementParams;

	plane.m_SpeedMaxF = 10000.0;
	plane.m_AccelF = 0.0;
	plane.m_DecelF = 0.0;
	plane.m_BrakeF = 0.0;
	plane.m_BrakeDotF = 1.0;

	vert.m_VertImpulseF = BhopJumpSpeed();
	vert.m_VertMaxSpeedF = -BhopTerminalSpeed();
	vert.m_GravityUpF = -BhopGravity();
	vert.m_GravityDownF = -BhopGravity();

	m_ExplorationO.m_MoverO.SetPlaneMovementParams( plane );
	m_ExplorationO.m_MoverO.SetVerticalMovementParams( vert );
}

@addMethod(CExplorationStateJump)
function BhopAirMoveTick( dt : float )
{
	var pad				: Vector;
	var wish			: Vector;
	var velocity		: Vector;
	var forward			: Vector;
	var right			: Vector;
	var look			: EulerAngles;
	var fmove			: float;
	var smove			: float;
	var wishSpeed		: float;
	var wishSpd			: float;
	var currentSpeed	: float;
	var addSpeed		: float;
	var accelSpeed		: float;
	var unit			: float;

	pad = m_ExplorationO.m_InputO.GetMovementOnPadV();
	fmove = ClampF( pad.Y, -1.0, 1.0 ) * BhopCommandSpeedUU();
	smove = ClampF( pad.X, -1.0, 1.0 ) * BhopCommandSpeedUU();
	if( AbsF( fmove ) < 0.1 && AbsF( smove ) < 0.1 )
	{
		return;
	}

	look = FP().GetRot();
	forward = BhopFlatUnit( RotForward( look ) );
	right = BhopFlatUnit( RotRight( look ) );
	wish = BhopFlat( right * smove + forward * fmove );
	wishSpeed = VecLength2D( wish );
	if( wishSpeed < 0.1 )
	{
		return;
	}

	if( wishSpeed > BhopMaxSpeedUU() )
	{
		wish = BhopFlat( wish * ( BhopMaxSpeedUU() / wishSpeed ) );
		wishSpeed = BhopMaxSpeedUU();
	}

	wish = BhopFlat( wish * ( 1.0 / wishSpeed ) );
	unit = BhopMetersPerUnit();
	velocity = BhopFlat( m_BhopVelV * ( 1.0 / unit ) );

	// PM_AirAccelerate. The 30 cap limits how fast wishdir may be, not the accel term.
	wishSpd = wishSpeed;
	if( wishSpd > BhopWishCapUU() )
	{
		wishSpd = BhopWishCapUU();
	}

	currentSpeed = VecDot( velocity, wish );
	addSpeed = wishSpd - currentSpeed;
	if( addSpeed <= 0.0 )
	{
		return;
	}

	accelSpeed = BhopAirAccelRate() * wishSpeed * dt;
	if( accelSpeed > addSpeed )
	{
		accelSpeed = addSpeed;
	}

	m_BhopVelV = BhopFlat( ( velocity + wish * accelSpeed ) * unit );
}

@addMethod(CExplorationStateJump)
function BhopAdvance( dt : float )
{
	BhopAirMoveTick( dt );
	BhopSlideOnContacts();
	m_BhopStepV = BhopFlat( m_BhopStepV + m_BhopVelV * dt );
}

@addMethod(CExplorationStateJump)
function BhopSimAir( frameDt : float )
{
	var steps	: int;
	var tick	: float;

	VecSetZeros( m_BhopStepV );
	if( frameDt <= 0.0 )
	{
		return;
	}

	m_BhopSimTimeF += frameDt;
	if( m_BhopSimTimeF > BhopSimLimit() )
	{
		m_BhopSimTimeF = BhopSimLimit();
	}

	tick = BhopTick();
	steps = 0;
	while( m_BhopSimTimeF >= tick && steps < 10 )
	{
		m_BhopSimTimeF -= tick;
		BhopAdvance( tick );
		steps += 1;
	}

	// A leftover shorter than one tick still has to move this frame. Dropping
	// it makes the view advance one tick, then two, at a steady frame rate.
	if( m_BhopSimTimeF > 0.0 )
	{
		BhopAdvance( m_BhopSimTimeF );
		m_BhopSimTimeF = 0.0;
	}
}

@addMethod(CExplorationStateJump)
function BhopClipOnNormal( velocity : Vector, normal : Vector ) : Vector
{
	var len		: float;
	var into	: float;

	len = VecLength( normal );
	if( len < 0.01 )
	{
		return velocity;
	}

	normal = normal * ( 1.0 / len );
	if( normal.Z < -0.3 )
	{
		return velocity;
	}

	into = VecDot( velocity, normal );
	if( into < 0.0 )
	{
		velocity = velocity - normal * into;
	}

	return velocity;
}

@addMethod(CExplorationStateJump)
function BhopSlideOnContacts( optional useGround : bool )
{
	var count		: int;
	var i			: int;
	var contact		: SCollisionData;
	var velocity	: Vector;

	count = m_ExplorationO.m_OwnerMAC.GetCollisionDataCount();
	if( count <= 0 && !useGround )
	{
		return;
	}

	// PM_ClipVelocity overbounce 1. Fall speed stays in the vector, so a
	// downhill ramp adds it to the run and an uphill ramp spends it.
	velocity = m_BhopVelV;
	velocity.Z = m_ExplorationO.m_MoverO.GetMovementVerticalSpeedF();
	velocity.W = 0.0;
	for( i = 0; i < count; i += 1 )
	{
		contact = m_ExplorationO.m_OwnerMAC.GetCollisionData( i );
		velocity = BhopClipOnNormal( velocity, contact.normal );
	}

	if( useGround )
	{
		velocity = BhopClipOnNormal( velocity, m_ExplorationO.m_OwnerMAC.GetTerrainNormal( false ) );
	}

	m_BhopVelV = BhopFlat( velocity );
	m_ExplorationO.m_MoverO.SetVerticalSpeed( velocity.Z );
}

@addMethod(CExplorationMover)
function BhopSetYaw( delta : float )
{
	m_RotationDeltaEA.Yaw = delta;
}

@addMethod(CExplorationStateJump)
function BhopFaceCamera()
{
	var camYaw		: float;
	var rotation	: EulerAngles;

	m_ExplorationO.m_MoverO.BhopSetYaw( 0.0 );
	camYaw = FP().GetRotYaw();
	m_OrientationInitialF = camYaw;
	rotation = m_ExplorationO.m_OwnerMAC.GetWorldRotation();
	m_ExplorationO.m_MoverO.BhopSetYaw( AngleDistance( camYaw, rotation.Yaw ) );
}

@addMethod(CExplorationStateJump)
function BhopLaunch( horizontal : Vector, optional chain : bool )
{
	horizontal = BhopFlat( horizontal );
	if( !chain )
	{
		BhopRememberJump();
		m_BhopSavedVelV = horizontal;
	}
	m_BhopActiveB = true;
	m_BhopWasAirborneB = false;
	m_BhopSimTimeF = 0.0;
	VecSetZeros( m_BhopStepV );
	m_ExplorationO.m_BhopJumpO = this;
	m_BhopVelV = horizontal;

	m_JumpParmsS.m_UsePhysicJumpB = true;
	m_JumpParmsS.m_TakeOffTimeF = 0.0;
	m_JumpParmsS.m_RecalcSpeedOnInertialB = false;
	m_JumpParmsS.m_AllowAirDisplacementControlB = false;
	m_JumpParmsS.m_OrientationSpeedF = 0.0;
	m_CanSetVelocityB = true;
	m_LandPredicedCoefF = 0.0;
	m_CooldownCurF = 0.0;
	m_ExplorationO.m_OwnerE.SetBehaviorVariable( m_BehEventPredictingS, 0.0 );
	BhopSuppressLand();

	m_ExplorationO.m_SharedDataO.ResetHeightFallen();

	m_BhopMotionOffB = true;
	BhopSetExtractedMotion( false );
	m_ExplorationO.m_MoverO.SetManualMovement( true );
	m_ExplorationO.m_OwnerMAC.EnableVirtualControllerCollisionResponse( 'MainCollider', true );
	m_ExplorationO.m_OwnerMAC.GetMovementAdjustor().CancelByName( 'turnOnJump' );
	m_ExplorationO.m_OwnerMAC.SetEnabledFeetIK( false );
	m_ExplorationO.m_SharedDataO.m_LandingOnWater = false;

	BhopApplyCoastParams();
	m_ExplorationO.m_MoverO.SetVelocity( m_BhopVelV );
	m_ExplorationO.m_MoverO.SetVerticalSpeed( BhopJumpSpeed() );
	SetReadyToChangeTo( GetStateName() );
}

@addMethod(CExplorationStateJump)
function BhopSuppressLand()
{
	m_SubstateE = JSS_Inertial;
	m_LandPredictedB = true;
	m_JumpParmsS.m_TimeToPrepareForLandF = 100.0;
	m_ExplorationO.m_SharedDataO.m_JumpIsTooSoonToLandB = true;
	m_ExplorationO.SetBehaviorParamBool( m_BehParamIsHandledByAnimS, false );
}


@wrapMethod(CExplorationStateJump)
function StateWantsToEnter() : bool
{
	if( wrappedMethod() )
	{
		return true;
	}

	return m_ExplorationO.m_InputO.IsJumpPressed() && BhopCanHop();
}

@wrapMethod(CExplorationStateJump)
function StateEnterSpecific( prevStateName : name )
{
	var hop : bool;

	hop = BhopCanHop();
	wrappedMethod( prevStateName );
	BhopStop();

	if( !hop || !BhopIsNormalJump() )
	{
		return;
	}

	if( m_JumpParmsS.m_JumpTypeE == EJT_Fall && !m_ExplorationO.m_InputO.IsJumpPressed() )
	{
		return;
	}

	BhopLaunch( BhopHorizontalVelocity() );
}

@wrapMethod(CExplorationStateJump)
function StateUpdateSpecific( _Dt : float )
{
	BhopYieldToThirdPerson();

	if( m_BhopActiveB )
	{
		BhopSuppressLand();
		BhopApplyCoastParams();
		BhopSimAir( _Dt );
	}

	wrappedMethod( _Dt );

	if( m_BhopActiveB )
	{
		m_ExplorationO.SetBehaviorParamBool( m_BehParamIsHandledByAnimS, false );
		BhopSetExtractedMotion( false );
		m_ExplorationO.m_MoverO.SetVelocity( m_BhopVelV );
		if( m_ExplorationO.IsOnGround() && m_ExplorationO.m_InputO.IsJumpPressed() && BhopCanHop() )
		{
			m_ExplorationO.m_MoverO.SetVerticalSpeed( BhopJumpSpeed() );
		}
		BhopFaceCamera();
	}
}

@wrapMethod(CExplorationStateJump)
function Update2DLogicMovement( _Dt : float )
{
	if( m_BhopActiveB )
	{
		m_ExplorationO.m_MoverO.Translate( m_BhopStepV );
		return;
	}

	wrappedMethod( _Dt );
}

@wrapMethod(CExplorationStateJump)
function ReactToLoseGround() : bool
{
	if( m_BhopActiveB )
	{
		m_BhopWasAirborneB = true;
	}

	return wrappedMethod();
}

@wrapMethod(CExplorationStateJump)
function ReactToHitGround() : bool
{
	var useVanilla : bool;

	BhopYieldToThirdPerson();

	useVanilla = !m_BhopActiveB || m_ExplorationO.m_SharedDataO.m_LandingOnWater || m_JumpParmsS.m_JumpTypeE == EJT_Skate;
	if( useVanilla )
	{
		if( m_BhopActiveB )
		{
			BhopStop();
		}

		return wrappedMethod();
	}

	if( m_BhopWasAirborneB && m_ExplorationO.m_InputO.IsJumpPressed() && BhopCanHop() )
	{
		// Clip before the jump replaces vertical speed, or the landing gives none of it to the slope.
		// Keep the speed already carried. Sampling the body again here stacks
		// the measured velocity on top of itself every landing.
		BhopSlideOnContacts( true );
		BhopLaunch( BhopFlat( m_BhopVelV ), true );
		return true;
	}

	if( BhopCanLand() )
	{
		BhopReleaseToGround();
		return true;
	}

	return true;
}

@wrapMethod(CExplorationStateJump)
function StateExitSpecific( nextStateName : name )
{
	BhopStop();
	wrappedMethod( nextStateName );
}

@wrapMethod(CExplorationStateAirCollision)
function StateWantsToEnter() : bool
{
	var jumpState : CExplorationStateJump;

	jumpState = m_ExplorationO.m_BhopJumpO;
	if( jumpState && jumpState.m_BhopActiveB && jumpState.BhopInFirstPerson() )
	{
		return false;
	}

	return wrappedMethod();
}

@wrapMethod(CR4Player)
function ApplyFallingDamage( heightDiff : float, optional reducing : bool ) : float
{
	if( FP().IsRunning() )
	{
		return 0.0;
	}

	return wrappedMethod( heightDiff, reducing );
}
