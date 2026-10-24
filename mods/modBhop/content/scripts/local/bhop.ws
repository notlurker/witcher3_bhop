@addField(CExplorationStateJump)
var m_BhopActiveB : bool;

@addField(CExplorationStateJump)
var m_BhopWasAirborneB : bool;

@addField(CExplorationStateJump)
var m_BhopLastDtF : float;

@addField(CExplorationStateJump)
var m_BhopVelV : Vector;

@addField(CExplorationStateJump)
var m_BhopCamStoredB : bool;

@addField(CExplorationStateJump)
var m_BhopCamWasOnB : bool;

@addField(CExplorationStateJump)
var m_BhopCamRotXB : bool;

@addField(CExplorationStateJump)
var m_BhopCamRotYB : bool;

@addField(CExplorationStateJump)
var m_BhopCamMaxStoredB : bool;

@addField(CExplorationStateJump)
var m_BhopCamMaxDistF : float;

@addField(CExplorationStateJump)
var m_BhopCamCtrlStoredB : bool;

@addField(CExplorationStateJump)
var m_BhopCamRotN : name;

@addField(CExplorationStateJump)
var m_BhopCamPosN : name;

@addField(CExplorationStateJump)
var m_BhopCamPosV : Vector;

@addField(CExplorationStateJump)
var m_BhopCamVelV : Vector;

@addField(CExplorationStateJump)
var m_BhopCamTargetV : Vector;

@addField(CExplorationStateJump)
var m_BhopCamZStoredB : bool;

@addField(CExplorationStateJump)
var m_BhopCamLocalV : Vector;

@addField(CExplorationStateJump)
var m_BhopCamLocalStoredB : bool;

@addField(CExplorationStateManager)
var m_BhopJumpO : CExplorationStateJump;


@addMethod(CExplorationStateJump)
function BhopAirAccel() : float
{
	return 6.0;
}

@addMethod(CExplorationStateJump)
function BhopAirWishCap() : float
{
	return 30.0;
}

@addMethod(CExplorationStateJump)
function BhopAirMaxSpeed() : float
{
	return 320.0;
}

@addMethod(CExplorationStateJump)
function BhopStrafeKeyScale() : float
{
	return 0.75;
}

@addMethod(CExplorationStateJump)
function BhopCurveRadius() : float
{
	return 6.0;
}

@addMethod(CExplorationStateJump)
function BhopCameraFollowOmega() : float
{
	return 10.0;
}

@addMethod(CExplorationStateJump)
function BhopCameraHeightOffset() : float
{
	return 0.7;
}

@addMethod(CExplorationStateJump)
function BhopCameraHeightSmooth() : float
{
	return 0.6;
}

@addMethod(CExplorationStateJump)
function BhopMetersPerUnit() : float
{
	return 0.0254;
}

@addMethod(CExplorationStateJump)
function BhopFriction() : float
{
	return 4.0;
}

@addMethod(CExplorationStateJump)
function BhopStopSpeed() : float
{
	return 2.54;
}

@addMethod(CExplorationStateJump)
function BhopJumpSpeed() : float
{
	return 7.0;
}

@addMethod(CExplorationStateJump)
function BhopGravity() : float
{
	return 7.0;
}

@addMethod(CExplorationStateJump)
function BhopMaxChainFall() : float
{
	return 6.0;
}

@addMethod(CExplorationStateJump)
function BhopCameraHopDist() : float
{
	return 3.0;
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
	return BhopPlayerIsOnFoot() && !BhopInteractionBlocks() && !BhopSignCastBlocks();
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
function BhopStripVanillaDelay()
{
	m_CooldownCurF = 0.0;
	m_CooldownTotalF = 0.0;
	m_JumpParmsIdleS.m_TakeOffTimeF = 0.0;
	m_JumpParmsIdleToWalkS.m_TakeOffTimeF = 0.0;
	m_JumpParmsWalkS.m_TakeOffTimeF = 0.0;
	m_JumpParmsWalkHighS.m_TakeOffTimeF = 0.0;
	m_JumpParmsRunS.m_TakeOffTimeF = 0.0;
	m_JumpParmsSprintS.m_TakeOffTimeF = 0.0;
	m_JumpParmsSlideS.m_TakeOffTimeF = 0.0;
	m_JumpParmsGenericS.m_TakeOffTimeF = 0.0;
}

@addMethod(CExplorationStateJump)
function BhopFallIsShort() : bool
{
	var fallDiff		: float;
	var jumpTotalDiff	: float;

	m_ExplorationO.m_SharedDataO.CalculateFallingHeights( fallDiff, jumpTotalDiff );
	return fallDiff <= BhopMaxChainFall();
}

@addMethod(CExplorationStateJump)
function BhopCanLand() : bool
{
	if( !m_BhopActiveB || m_ExplorationO.m_SharedDataO.m_LandingOnWater )
	{
		return false;
	}

	if( !BhopPlayerIsOnFoot() || BhopInteractionBlocks() || !BhopFallIsShort() )
	{
		return false;
	}

	return m_BhopWasAirborneB && m_ExplorationO.GetStateTimeF() > 0.05 && m_JumpParmsS.m_JumpTypeE != EJT_Skate;
}

@addMethod(CExplorationStateJump)
function BhopStop()
{
	m_BhopActiveB = false;
	m_BhopWasAirborneB = false;
	m_BhopVelV.X = 0.0;
	m_BhopVelV.Y = 0.0;
	m_BhopVelV.Z = 0.0;
	m_BhopVelV.W = 0.0;
}

@addMethod(CExplorationStateJump)
function BhopReleaseToGround()
{
	BhopStop();
	m_ExplorationO.m_MoverO.SetManualMovement( false );
	m_ExplorationO.m_MoverO.SetVerticalSpeed( 0.0 );
	BhopRestoreCameraCenter();
	SetReadyToChangeTo( m_ExplorationO.GetDefaultStateName() );
}

@addMethod(CExplorationStateJump)
function BhopHorizontalVelocity() : Vector
{
	var owned		: Vector;
	var moverVel	: Vector;
	var ownedSpeed	: float;
	var moverSpeed	: float;

	owned = BhopFlat( m_BhopVelV );
	moverVel = BhopFlat( m_ExplorationO.m_MoverO.GetMovementHorizontalVelocityV() );
	ownedSpeed = VecLength2D( owned );
	moverSpeed = VecLength2D( moverVel );

	if( ownedSpeed >= moverSpeed && ownedSpeed > 0.05 )
	{
		return owned;
	}

	if( moverSpeed < 0.2 && m_JumpParmsS.m_HorImpulseF > 0.2 )
	{
		moverVel = BhopFlat( VecFromHeading( m_OrientationInitialF ) * m_JumpParmsS.m_HorImpulseF );
	}

	return moverVel;
}

@addMethod(CExplorationStateJump)
function BhopApplyGroundFriction( velocity : Vector ) : Vector
{
	var speed		: float;
	var newSpeed	: float;
	var dt			: float;

	velocity = BhopFlat( velocity );
	speed = VecLength2D( velocity );
	if( speed < 0.05 )
	{
		return velocity;
	}

	dt = m_BhopLastDtF;
	if( dt <= 0.0 )
	{
		dt = 0.016;
	}

	newSpeed = MaxF( 0.0, speed - MaxF( speed, BhopStopSpeed() ) * BhopFriction() * dt );
	return BhopFlat( velocity * ( newSpeed / speed ) );
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
	vert.m_VertMaxSpeedF = -50.0;
	vert.m_GravityUpF = -BhopGravity();
	vert.m_GravityDownF = -BhopGravity();

	m_ExplorationO.m_MoverO.SetPlaneMovementParams( plane );
	m_ExplorationO.m_MoverO.SetVerticalMovementParams( vert );
}

@addMethod(CExplorationStateJump)
function BhopAirAccelerate( dt : float )
{
	var pad				: Vector;
	var wish			: Vector;
	var velocity		: Vector;
	var camForward		: Vector;
	var camRight		: Vector;
	var commandSpeed	: float;
	var wishCap			: float;
	var currentSpeed	: float;
	var addSpeed		: float;
	var accelSpeed		: float;
	var length			: float;
	var unit			: float;
	var oldSpeed		: float;
	var newSpeed		: float;
	var side			: Vector;
	var dir				: Vector;
	var sideLen			: float;
	var bonusSpeed		: float;
	var gain			: float;
	var camYaw			: float;
	var velYaw			: float;
	var turn			: float;
	var maxTurn			: float;
	var blend			: float;

	pad = m_ExplorationO.m_InputO.GetMovementOnPadV();
	if( AbsF( pad.X ) < 0.01 && AbsF( pad.Y ) < 0.01 )
	{
		return;
	}

	camForward = BhopFlatUnit( theCamera.GetCameraForward() );
	camRight = BhopFlatUnit( theCamera.GetCameraRight() );
	wish = BhopFlat( camRight * pad.X + camForward * pad.Y );
	length = VecLength2D( wish );
	if( length < 0.01 )
	{
		return;
	}

	unit = BhopMetersPerUnit();
	commandSpeed = MinF( length, 1.0 ) * BhopAirMaxSpeed() * unit;
	wishCap = MinF( commandSpeed, BhopAirWishCap() * unit );
	wish = wish * ( 1.0 / length );

	velocity = BhopFlat( m_BhopVelV );
	currentSpeed = VecDot( velocity, wish );
	addSpeed = wishCap - currentSpeed;
	if( addSpeed > 0.0 )
	{
		accelSpeed = BhopAirAccel() * commandSpeed * dt;
		if( accelSpeed > addSpeed )
		{
			accelSpeed = addSpeed;
		}

		oldSpeed = VecLength2D( velocity );
		velocity = BhopFlat( velocity + wish * accelSpeed );
		newSpeed = VecLength2D( velocity );
		if( pad.Y >= -0.01 && newSpeed < oldSpeed && newSpeed > 0.001 )
		{
			velocity = BhopFlat( velocity * ( oldSpeed / newSpeed ) );
		}
	}

	bonusSpeed = VecLength2D( velocity );
	if( AbsF( pad.X ) >= 0.01 && bonusSpeed > 0.2 && VecLength2D( camForward ) > 0.5 )
	{
		camYaw = VecHeading( camForward );
		velYaw = VecHeading( velocity );
		turn = AngleDistance( camYaw, velYaw );
		if( AbsF( turn ) > 0.05 )
		{
			maxTurn = ClampF( bonusSpeed * 57.3 / BhopCurveRadius(), 90.0, 220.0 ) * dt;
			blend = ClampF( maxTurn / AbsF( turn ), 0.0, 1.0 );
			dir = BhopFlat( velocity * ( 1.0 / bonusSpeed ) );
			dir = BhopFlat( dir + ( camForward - dir ) * blend );
			sideLen = VecLength2D( dir );
			if( sideLen > 0.01 )
			{
				velocity = BhopFlat( dir * ( bonusSpeed / sideLen ) );
				bonusSpeed = VecLength2D( velocity );
			}
		}
	}

	if( AbsF( pad.X ) >= 0.01 && pad.Y >= -0.01 )
	{
		gain = BhopAirAccel() * BhopStrafeKeyScale() * AbsF( pad.X ) * dt;
		if( bonusSpeed > 0.2 )
		{
			velocity = velocity * ( ( bonusSpeed + gain ) / bonusSpeed );
		}
		else
		{
			side = BhopFlat( camRight * pad.X );
			sideLen = VecLength2D( side );
			if( sideLen >= 0.01 )
			{
				velocity = velocity + side * ( gain / sideLen );
			}
		}
	}

	m_BhopVelV = BhopFlat( velocity );
}

@addMethod(CExplorationStateJump)
function BhopSlideOnContacts()
{
	var count		: int;
	var i			: int;
	var contact		: SCollisionData;
	var normal		: Vector;
	var velocity	: Vector;
	var into		: float;
	var len			: float;

	count = m_ExplorationO.m_OwnerMAC.GetCollisionDataCount();
	if( count <= 0 )
	{
		return;
	}

	velocity = BhopFlat( m_BhopVelV );
	for( i = 0; i < count; i += 1 )
	{
		contact = m_ExplorationO.m_OwnerMAC.GetCollisionData( i );
		normal = contact.normal;
		len = VecLength( normal );
		if( len < 0.01 )
		{
			continue;
		}

		normal = normal * ( 1.0 / len );
		if( normal.Z < -0.3 )
		{
			continue;
		}

		into = VecDot( velocity, normal );
		if( into < 0.0 )
		{
			velocity = BhopFlat( velocity - normal * into );
		}
	}

	m_BhopVelV = BhopFlat( velocity );
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
	camYaw = theCamera.GetCameraHeading();
	m_OrientationInitialF = camYaw;
	rotation = m_ExplorationO.m_OwnerMAC.GetWorldRotation();
	m_ExplorationO.m_MoverO.BhopSetYaw( AngleDistance( camYaw, rotation.Yaw ) );
}

@addMethod(CExplorationStateJump)
function BhopLaunch( horizontal : Vector )
{
	horizontal = BhopFlat( horizontal );
	m_BhopActiveB = true;
	m_BhopWasAirborneB = false;
	m_ExplorationO.m_BhopJumpO = this;
	m_BhopVelV = horizontal;

	m_JumpParmsS.m_UsePhysicJumpB = true;
	m_JumpParmsS.m_TakeOffTimeF = 0.0;
	m_JumpParmsS.m_RecalcSpeedOnInertialB = false;
	m_JumpParmsS.m_AllowAirDisplacementControlB = false;
	m_JumpParmsS.m_OrientationSpeedF = 0.0;
	m_CanSetVelocityB = true;
	m_SubstateE = JSS_Inertial;
	m_LandPredictedB = true;
	m_LandPredicedCoefF = 0.0;
	m_CooldownCurF = 0.0;

	m_ExplorationO.SetBehaviorParamBool( m_BehParamIsHandledByAnimS, false );
	m_ExplorationO.m_OwnerE.SetBehaviorVariable( m_BehEventPredictingS, 0.0 );
	m_ExplorationO.SendAnimEvent( 'Jump', true );
	if( IsNameValid( m_JumpParmsS.m_BehaviorEventN ) )
	{
		m_ExplorationO.SendAnimEvent( m_JumpParmsS.m_BehaviorEventN, true );
	}

	m_ExplorationO.m_MoverO.SetManualMovement( true );
	m_ExplorationO.m_OwnerMAC.EnableVirtualControllerCollisionResponse( 'MainCollider', true );
	m_ExplorationO.m_OwnerMAC.GetMovementAdjustor().CancelByName( 'turnOnJump' );
	m_ExplorationO.m_OwnerMAC.SetEnabledFeetIK( false );
	m_ExplorationO.m_SharedDataO.m_JumpIsTooSoonToLandB = true;
	m_ExplorationO.m_SharedDataO.m_LandingOnWater = false;
	m_ExplorationO.m_SharedDataO.ResetHeightFallen();

	BhopApplyCoastParams();
	m_ExplorationO.m_MoverO.SetVelocity( m_BhopVelV );
	m_ExplorationO.m_MoverO.SetVerticalSpeed( BhopJumpSpeed() );
	BhopSuppressCameraCenter();
	SetReadyToChangeTo( GetStateName() );
}

@addMethod(CExplorationStateJump)
function BhopSuppressCameraCenter()
{
	var camera : CCustomCamera;

	if( m_BhopCamStoredB )
	{
		return;
	}

	camera = theGame.GetGameCamera();
	if( !camera )
	{
		return;
	}

	m_BhopCamWasOnB = camera.allowAutoRotation;
	m_BhopCamRotXB = theGame.IsCameraAutoRotX();
	m_BhopCamRotYB = theGame.IsCameraAutoRotY();
	m_BhopCamStoredB = true;
	camera.allowAutoRotation = false;
	theGame.SetCameraAutoRotX( false );
	theGame.SetCameraAutoRotY( false );
}

@addMethod(CExplorationStateJump)
function BhopRestoreCameraCenter()
{
	var camera : CCustomCamera;

	if( !m_BhopCamStoredB )
	{
		return;
	}

	camera = theGame.GetGameCamera();
	if( camera )
	{
		camera.allowAutoRotation = m_BhopCamWasOnB;
	}

	theGame.SetCameraAutoRotX( m_BhopCamRotXB );
	theGame.SetCameraAutoRotY( m_BhopCamRotYB );
	m_BhopCamStoredB = false;
	m_BhopCamCtrlStoredB = false;
	m_BhopCamZStoredB = false;
	m_BhopCamLocalStoredB = false;
	BhopRestoreCameraDistance();
}

@addMethod(CExplorationStateJump)
function BhopEnableMouse()
{
	var camera : CCustomCamera;

	camera = theGame.GetGameCamera();
	if( camera && ( !camera.IsManualControledHor() || !camera.IsManualControledVer() ) )
	{
		camera.EnableManualControl( true );
	}
}

@addMethod(CExplorationStateJump)
function BhopKeepMouseCamera( rot : ICustomCameraPivotRotationController, pos : ICustomCameraPivotPositionController )
{
	var camera		: CCustomCamera;
	var rotName		: name;
	var posName		: name;
	var switched	: bool;

	cameraFallIsSet = false;
	if( rot )
	{
		rotName = rot.controllerName;
	}
	if( pos )
	{
		posName = pos.controllerName;
	}

	if( !m_BhopCamCtrlStoredB )
	{
		m_BhopCamRotN = rotName;
		m_BhopCamPosN = posName;
		m_BhopCamCtrlStoredB = true;
		BhopEnableMouse();
	}

	camera = theGame.GetGameCamera();
	if( camera && ( rotName == 'LongFall' || rotName == 'Jump' ) )
	{
		if( IsNameValid( m_BhopCamRotN ) && m_BhopCamRotN != 'LongFall' && m_BhopCamRotN != 'Jump' )
		{
			camera.ChangePivotRotationController( m_BhopCamRotN );
		}
		else
		{
			camera.ChangePivotRotationController( 'Exploration' );
		}
		switched = true;
	}

	if( camera && posName == 'Jump' )
	{
		if( IsNameValid( m_BhopCamPosN ) && m_BhopCamPosN != 'Jump' )
		{
			camera.ChangePivotPositionController( m_BhopCamPosN );
		}
		else
		{
			camera.ChangePivotPositionController( 'Default' );
		}
		switched = true;
	}

	if( switched )
	{
		BhopEnableMouse();
	}
}

@addMethod(CExplorationStateJump)
function BhopRestoreCameraDistance()
{
	var camera		: CCustomCamera;
	var controller	: ICustomCameraPivotDistanceController;

	if( !m_BhopCamMaxStoredB )
	{
		return;
	}

	camera = theGame.GetGameCamera();
	if( camera )
	{
		controller = camera.GetActivePivotDistanceController();
		if( controller )
		{
			controller.maxDist = m_BhopCamMaxDistF;
		}
	}

	m_BhopCamMaxStoredB = false;
}

@addMethod(CExplorationStateJump)
function BhopUpdateCameraDistance( controller : ICustomCameraPivotDistanceController )
{
	var dist : float;

	if( !controller )
	{
		return;
	}

	if( !m_BhopCamMaxStoredB )
	{
		m_BhopCamMaxDistF = controller.maxDist;
		m_BhopCamMaxStoredB = true;
	}

	dist = BhopCameraHopDist();
	if( controller.maxDist < dist )
	{
		controller.maxDist = dist;
	}

	controller.SetDesiredDistance( dist, 30.0 );
}

@addMethod(CExplorationStateJump)
function BhopUpdateCameraFollow( target : Vector, dt : float )
{
	var omega		: float;
	var error		: Vector;
	var targetVel	: Vector;
	var accel		: Vector;
	var step		: float;
	var goalZ		: float;

	if( !m_BhopCamZStoredB )
	{
		m_BhopCamPosV = target;
		m_BhopCamPosV.Z = target.Z + BhopCameraHeightOffset();
		m_BhopCamVelV = BhopFlat( m_BhopVelV );
		m_BhopCamTargetV = target;
		m_BhopCamZStoredB = true;
		return;
	}

	if( dt <= 0.0 )
	{
		return;
	}

	step = ClampF( dt, 0.0, 0.05 );
	targetVel = BhopFlat( ( target - m_BhopCamTargetV ) * ( 1.0 / step ) );
	error = BhopFlat( target - m_BhopCamPosV );
	m_BhopCamVelV = BhopFlat( m_BhopCamVelV );
	omega = BhopCameraFollowOmega();
	accel = BhopFlat( error * ( omega * omega ) + ( targetVel - m_BhopCamVelV ) * ( 2.0 * omega ) );
	m_BhopCamVelV = BhopFlat( m_BhopCamVelV + accel * step );
	m_BhopCamPosV = m_BhopCamPosV + m_BhopCamVelV * step;

	goalZ = target.Z + BhopCameraHeightOffset();
	m_BhopCamPosV.Z = m_BhopCamPosV.Z + ( goalZ - m_BhopCamPosV.Z ) * ClampF( step / BhopCameraHeightSmooth(), 0.0, 1.0 );
	m_BhopCamPosV.W = 0.0;
	m_BhopCamTargetV = target;
}

@addMethod(CExplorationStateJump)
function BhopApplyCamera( out moveData : SCameraMovementData, dt : float )
{
	var pos		: Vector;
	var posCtrl	: ICustomCameraPivotPositionController;

	BhopUpdateCameraDistance( moveData.pivotDistanceController );
	pos = thePlayer.GetWorldPosition();
	BhopUpdateCameraFollow( pos, dt );
	posCtrl = moveData.pivotPositionController;
	if( posCtrl )
	{
		posCtrl.SetDesiredPosition( m_BhopCamPosV, 30.0 );
	}

	BhopKeepMouseCamera( moveData.pivotRotationController, moveData.pivotPositionController );
	BhopHoldMouseLook( moveData );
	BhopHoldCameraOffset( moveData );
}

@addMethod(CExplorationStateJump)
function BhopHoldMouseLook( out moveData : SCameraMovementData )
{
	var rotCtrl		: ICustomCameraPivotRotationController;
	var rotation	: EulerAngles;

	rotCtrl = moveData.pivotRotationController;
	if( !rotCtrl )
	{
		return;
	}

	rotation = moveData.pivotRotationValue;
	rotCtrl.SetDesiredPitch( rotation.Pitch );
	rotCtrl.SetDesiredHeading( rotation.Yaw );
}

@addMethod(CExplorationStateJump)
function BhopHoldCameraOffset( out moveData : SCameraMovementData )
{
	if( !m_BhopCamLocalStoredB )
	{
		m_BhopCamLocalV = moveData.cameraLocalSpaceOffset;
		m_BhopCamLocalStoredB = true;
	}

	moveData.cameraLocalSpaceOffset = m_BhopCamLocalV;
	moveData.cameraLocalSpaceOffsetVel.X = 0.0;
	moveData.cameraLocalSpaceOffsetVel.Y = 0.0;
	moveData.cameraLocalSpaceOffsetVel.Z = 0.0;
	moveData.cameraLocalSpaceOffsetVel.W = 0.0;
}


@wrapMethod(CExplorationStateJump)
function StateWantsToEnter() : bool
{
	if( BhopCanHop() )
	{
		BhopStripVanillaDelay();
	}

	if( wrappedMethod() )
	{
		return true;
	}

	return m_ExplorationO.m_InputO.IsJumpPressed() && BhopCanHop();
}

@wrapMethod(CExplorationStateJump)
function StateEnterSpecific( prevStateName : name )
{
	BhopStripVanillaDelay();
	wrappedMethod( prevStateName );
	BhopStop();

	if( !BhopIsNormalJump() || !BhopCanHop() )
	{
		return;
	}

	if( m_JumpParmsS.m_JumpTypeE == EJT_Fall && !m_ExplorationO.m_InputO.IsJumpPressed() )
	{
		return;
	}

	BhopLaunch( BhopApplyGroundFriction( BhopHorizontalVelocity() ) );
}

@wrapMethod(CExplorationStateJump)
function StateUpdateSpecific( _Dt : float )
{
	m_BhopLastDtF = _Dt;
	if( m_BhopActiveB )
	{
		m_SubstateE = JSS_Inertial;
		m_LandPredictedB = true;
		BhopSlideOnContacts();
		BhopAirAccelerate( _Dt );
	}

	wrappedMethod( _Dt );

	if( m_BhopActiveB )
	{
		m_ExplorationO.m_MoverO.SetVelocity( m_BhopVelV );
		BhopFaceCamera();
		if( !m_BhopCamStoredB )
		{
			BhopSuppressCameraCenter();
		}
	}
}

@wrapMethod(CExplorationStateJump)
function Update2DLogicMovement( _Dt : float )
{
	if( m_BhopActiveB )
	{
		m_ExplorationO.m_MoverO.Translate( m_BhopVelV * _Dt );
		return;
	}

	wrappedMethod( _Dt );
}

@wrapMethod(CExplorationStateJump)
function ReactToLoseGround() : bool
{
	m_BhopWasAirborneB = true;
	return wrappedMethod();
}

@wrapMethod(CExplorationStateJump)
function ReactToHitGround() : bool
{
	var useVanilla : bool;

	useVanilla = !m_BhopActiveB || m_ExplorationO.m_SharedDataO.m_LandingOnWater || !BhopFallIsShort() || m_JumpParmsS.m_JumpTypeE == EJT_Skate;
	if( useVanilla )
	{
		return wrappedMethod();
	}

	if( m_ExplorationO.m_InputO.IsJumpPressed() && BhopCanHop() && m_ExplorationO.GetStateTimeF() > 0.05 )
	{
		BhopLaunch( BhopHorizontalVelocity() );
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
	BhopRestoreCameraCenter();
	wrappedMethod( nextStateName );
}

@wrapMethod(CR4Player)
function OnGameCameraPostTick( out moveData : SCameraMovementData, dt : float )
{
	var jumpState	: CExplorationStateJump;
	var handled		: bool;

	handled = wrappedMethod( moveData, dt );
	if( substateManager )
	{
		jumpState = substateManager.m_BhopJumpO;
	}

	if( !jumpState || !jumpState.m_BhopActiveB )
	{
		if( jumpState && jumpState.m_BhopCamMaxStoredB )
		{
			jumpState.BhopRestoreCameraDistance();
		}

		return handled;
	}

	jumpState.BhopApplyCamera( moveData, dt );
	return handled;
}

@wrapMethod(CExplorationStateJump)
function UpdateCameraChange()
{
	if( m_BhopActiveB )
	{
		cameraFallIsSet = false;
		return;
	}

	wrappedMethod();
}

@wrapMethod(CExplorationStateAirCollision)
function StateWantsToEnter() : bool
{
	var jumpState : CExplorationStateJump;

	jumpState = m_ExplorationO.m_BhopJumpO;
	if( jumpState && jumpState.m_BhopActiveB )
	{
		return false;
	}

	return wrappedMethod();
}

@wrapMethod(CCameraPivotPositionControllerJump)
function ControllerUpdate( out currentPosition : Vector, out currentVelocity : Vector, timeDelta : float )
{
	var jumpState : CExplorationStateJump;

	if( thePlayer.substateManager )
	{
		jumpState = thePlayer.substateManager.m_BhopJumpO;
	}

	if( jumpState && jumpState.m_BhopActiveB && jumpState.m_BhopCamZStoredB )
	{
		currentPosition = jumpState.m_BhopCamPosV;
		currentVelocity.X = 0.0;
		currentVelocity.Y = 0.0;
		currentVelocity.Z = 0.0;
		currentVelocity.W = 0.0;
		return;
	}

	wrappedMethod( currentPosition, currentVelocity, timeDelta );
}
