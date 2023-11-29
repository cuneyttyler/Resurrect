scriptName zyxResurrect extends activeMagicEffect

;-- Properties --------------------------------------
spell property zyxResurrectSpellVisual auto
keyword property ActorTypeFamiliar auto
keyword property ActorTypeHorse auto
keyword property ActorTypeGhost auto
keyword property ActorTypeDaedra auto
keyword property MagicNoReanimate auto
actorbase property encHare auto
message property zyxResurrectMSGTargetNoReanimate auto
effectshader property afterEffect auto
keyword property ActorTypeNPC auto
weapon property IronDagger auto
keyword property ActorTypeDragon auto
keyword property ActorTypeCreature auto
keyword property ActorTypeAnimal auto
keyword property ActorTypeDwarven auto
keyword property ActorTypeUndead auto
message property zyxResurrectMSGTargetForbidden auto
message property zyxResurrectMSGTargetAlive auto
spell property zyxResurrectSpellFailVisual auto
globalvariable property zyxResurrectTimer auto
globalvariable property GameDaysPassed auto
Spell property zyxResurrectActiveEffectSpell auto
Spell property zyxResurrectSpellScript auto

;-- Variables ---------------------------------------
objectReference dummyContainerReference
objectReference dummyTargetReference
actor targetReference
actor playerReference
int zyxResurrectTimeout = 87
;-- Functions ---------------------------------------

event OnUpdateGameTime()

	if GameDaysPassed.GetValue() - zyxResurrectTimer.GetValue() >= zyxResurrectTimeout && Game.GetPlayer().HasSpell(zyxResurrectSpellScript) && !Game.GetPlayer().HasSpell(zyxResurrectActiveEffectSpell)
		Game.GetPlayer().AddSpell(zyxResurrectActiveEffectSpell)
	else
		if Game.GetPlayer().HasSpell(zyxResurrectActiveEffectSpell)
			Game.GetPlayer().RemoveSpell(zyxResurrectActiveEffectSpell)
		endIf
	endIf
endEvent

function onAnimationEvent(objectReference akSource, String asEventName)

	if GameDaysPassed.GetValue() - zyxResurrectTimer.GetValue() >= zyxResurrectTimeout && akSource == targetReference as objectReference && asEventName == "GetupEnd"
		Debug.Trace("zyxResurrect: OnAnimationEvent")
		return 

		self.UnRegisterForAnimationEvent(targetReference as objectReference, "GetupEnd")
		if targetReference.hasKeyword(ActorTypeNPC)
			self.resurrectNPC()
		elseIf targetReference.hasKeyword(ActorTypeUndead)
			self.resurrectUndead()
		elseIf targetReference.hasKeyword(ActorTypeHorse)
			self.resurrectHorse()
		elseIf targetReference.hasKeyword(ActorTypeAnimal) || targetReference.hasKeyword(ActorTypeCreature)
			self.resurrectAnimalCreature()
		endIf
		afterEffect.play(targetReference as objectReference, 10.0000)
		self.dummyContainer("empty")
		self.dummyContainer("despawn")
		self.smoothFade(targetReference, 0.0500000, 1.00000, 0.750000)
		Game.GetPlayer().RemoveSpell(zyxResurrectActiveEffectSpell)
		zyxResurrectTimer.SetValue(GameDaysPassed.GetValue())
	else
		Debug.Trace("zyx:Resurrect: Fail")
		; zyxResurrectSpellFailVisual.Cast(playerReference as objectReference, targetReference as objectReference)
	endIf
endFunction

function setResurrectHealth()

	Float targetHealthModifier
	Float targetHealthBase = targetReference.getBaseAV("Health")
	Float playerRestorationLevel = playerReference.getAV("Restoration")
	if playerRestorationLevel > 100 as Float
		targetHealthModifier = 0 as Float
	elseIf playerRestorationLevel <= 0 as Float
		targetHealthModifier = 0.990000
	elseIf playerRestorationLevel > 0 as Float && playerRestorationLevel <= 100 as Float
		targetHealthModifier = (100 as Float - playerRestorationLevel) / 100 as Float
	endIf
	Float targetHealthResult = targetHealthBase * targetHealthModifier
	if targetHealthResult < targetReference.getAV("Health")
		targetReference.damageAV("Health", targetHealthResult)
	else
		targetReference.damageAV("Health", targetHealthBase * 0.990000)
	endIf
endFunction

function resurrectAnimalCreature()

	targetReference.resurrect()
	targetReference.removeAllItems(none, false, false)
	self.setResurrectHealth()
endFunction

function onEffectStart(actor akTarget, actor akCaster)

	targetReference = akTarget
	playerReference = game.getPlayer()
	if targetReference == playerReference
		
	elseIf !targetReference.isDead()
		
	elseIf targetReference.isDead() && targetReference.hasKeyword(MagicNoReanimate) && !targetReference.hasKeyword(ActorTypeHorse)
		zyxResurrectMSGTargetNoReanimate.show(0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000)
	elseIf targetReference.hasKeyword(ActorTypeGhost) || targetReference.hasKeyword(ActorTypeDragon) || targetReference.hasKeyword(ActorTypeDwarven) || targetReference.hasKeyword(ActorTypeDaedra) || targetReference.hasKeyword(ActorTypeFamiliar)
		zyxResurrectMSGTargetForbidden.show(0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000)
	elseIf targetReference.hasKeyword(ActorTypeNPC) || targetReference.hasKeyword(ActorTypeUndead) || targetReference.hasKeyword(ActorTypeAnimal) || targetReference.hasKeyword(ActorTypeCreature) || targetReference.hasKeyword(ActorTypeHorse)
		if GameDaysPassed.GetValue() - zyxResurrectTimer.GetValue() >= zyxResurrectTimeout
			zyxResurrectSpellVisual.Cast(playerReference as objectReference, targetReference as objectReference)
			self.registerForAnimationEvent(targetReference as objectReference, "GetupEnd")
			debug.sendAnimationEvent(targetReference as objectReference, "GetupBegin")
			self.smoothFade(targetReference, 1.00000, 0.0500000, 1.50000)
			self.dummyContainer("spawn")
			self.dummyContainer("fill")
		endIf
	else
		zyxResurrectMSGTargetForbidden.show(0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000)
	endIf
endFunction

function resurrectNPC()

	Int relationshipRank = targetReference.getRelationshipRank(playerReference)
	targetReference.resurrect()
	targetReference.removeAllItems(none, false, false)
	self.setResurrectHealth()
	targetReference.setRelationshipRank(playerReference, relationshipRank)
endFunction

function smoothFade(actor targetActor, Float alphaInitial, Float alphaFinal, Float alphaDuration)

	if alphaInitial > alphaFinal
		Float fadeIterations = alphaDuration / 0.100000
		Float fadeWait = alphaDuration / fadeIterations
		Float fadeDecrement = (alphaInitial - alphaFinal) / fadeIterations
		Float alphaCurrent = alphaInitial
		while alphaCurrent >= alphaFinal
			targetActor.setAlpha(alphaCurrent, true)
			alphaCurrent -= fadeDecrement
			utility.wait(fadeWait)
		endWhile
		if alphaFinal == 0 as Float
			targetActor.setAlpha(0 as Float, true)
		endIf
	elseIf alphaInitial < alphaFinal
		Float fadeiterations = alphaDuration / 0.100000
		Float fadewait = alphaDuration / fadeiterations
		Float fadeIncrement = (alphaFinal - alphaInitial) / fadeiterations
		Float alphacurrent = alphaInitial
		while alphacurrent <= alphaFinal
			targetActor.setAlpha(alphacurrent, true)
			alphacurrent += fadeIncrement
			utility.wait(fadewait)
		endWhile
		if alphaFinal == 1.00000
			targetActor.setAlpha(1.00000, true)
		endIf
	endIf
endFunction

function dummyEffect(String inputOption)

	if inputOption == "spawn"
		Float[] targetReferencePosition = new Float[3]
		targetReferencePosition[0] = targetReference.getPositionX()
		targetReferencePosition[1] = targetReference.getPositionY()
		targetReferencePosition[2] = targetReference.getPositionZ()
		Float[] playerPositionOffset = new Float[3]
		playerPositionOffset[0] = -2048 as Float * math.sin(playerReference.getAngleZ())
		playerPositionOffset[1] = -2048 as Float * math.cos(playerReference.getAngleZ())
		playerPositionOffset[2] = 0 as Float
		utility.wait(1.00000)
		dummyTargetReference = playerReference.placeAtMe(encHare as form, 1, false, true)
		(dummyTargetReference as actor).moveTo(playerReference as objectReference, playerPositionOffset[0], playerPositionOffset[1], playerPositionOffset[2], true)
		dummyTargetReference.enable(false)
		(dummyTargetReference as actor).setAlpha(0.0100000, false)
		(dummyTargetReference as actor).setRestrained(true)
		(dummyTargetReference as actor).setPosition(targetReferencePosition[0], targetReferencePosition[1], targetReferencePosition[2])
		zyxResurrectSpellVisual.Cast(playerReference as objectReference, (dummyTargetReference as actor) as objectReference)
	elseIf inputOption == "despawn"
		utility.wait(1.00000)
		(dummyTargetReference as actor).setAlpha(0 as Float, true)
		dummyTargetReference.delete()
	endIf
endFunction

function dummyContainer(String inputOption)

	if inputOption == "spawn"
		dummyContainerReference = playerReference.placeAtMe(encHare as form, 1, false, true)
	elseIf inputOption == "despawn"
		dummyContainerReference.delete()
	elseIf inputOption == "fill"
		targetReference.removeAllItems(dummyContainerReference, true, true)
	elseIf inputOption == "empty"
		dummyContainerReference.removeAllItems(targetReference as objectReference, true, true)
		targetReference.addItem(IronDagger as form, 1, false)
		targetReference.removeItem(IronDagger as form, 1, false, none)
	endIf
endFunction

; Skipped compiler generated GetState

function resurrectUndead()

	targetReference.resurrect()
	targetReference.removeAllItems(none, false, false)
	self.setResurrectHealth()
endFunction

function resurrectHorse()

	targetReference.resurrect()
	targetReference.removeAllItems(none, false, false)
	self.setResurrectHealth()
endFunction

; Skipped compiler generated GotoState
