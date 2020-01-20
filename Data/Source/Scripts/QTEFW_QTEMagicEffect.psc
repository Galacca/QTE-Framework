Scriptname QTEFW_SingleME extends activemagiceffect  

ObjectReference[] Property QTEInputArray  Auto  
Int[] Property QTEKeyCodes  Auto 
Message[] Style1Messages

Actor Property Player  Auto  

Float QTETimeToComplete
Float QTEExtraTimeOnCorrect

string style
string failureMode

string modEventOnCorrect
string modEventOnFailure
string modEventOnSuccessEnd
string modEventOnTotalFailureEnd

int MinCorrect
Int MaxFailures
int failureIncrease
Int CorrectKeysPressed = 0
Int TimesFailed = 0
Int ForwardKey
Int BackwardKey
Int LeftKey
Int RightKey
;Int JournalKey // This is for later

;Bool used to make sure the script actually stops if we get a Dispel or EffectFinish call while stuck in a wait.
bool TerminateCalled = False

bool FirstTimeHit = True


Event OnEffectStart(Actor Target, Actor Caster)
	;Pluck an override value, if the pluck fails then use the default value

	;Strings
	style = StorageUtil.PluckStringValue(None, "QTEFW_Override_Style", StorageUtil.GetStringValue(None, "QTEFW_Default_Style"))
	failureMode = StorageUtil.PluckStringValue(None, "QTEFW_Override_FailureMode", StorageUtil.GetStringValue(None, "QTEFW_Default_FailureMode"))

	;Integers
	minCorrect = StorageUtil.GetIntValue(None, "QTEFW_Default_MinCorrect")
	maxFailures = StorageUtil.PluckIntValue(None, "QTEFW_Override_MaxFailures", StorageUtil.GetIntValue(None, "QTEFW_Default_MaxFailures"))
	failureIncrease = StorageUtil.PluckIntValue(None, "QTEFW_Override_FailureIncrease", StorageUtil.GetIntValue(None, "QTEFW_Default_FailureIncrease"))

	;ModEvent registrations
	modEventOnCorrect = StorageUtil.PluckStringValue(None, "QTEFW_Override_modEventOnCorrect", "none")
	modEventOnFailure = StorageUtil.PluckStringValue(None, "QTEFW_Override_modEventOnFailure", "none")
	modEventOnSuccessEnd = StorageUtil.PluckStringValue(None, "QTEFW_Override_modEventOnSuccessEnd", "none")
	modEventOnTotalFailureEnd = StorageUtil.PluckStringValue(None, "QTEFW_Override_modEventOnTotalFailureEnd", "none")

	;Anything caught by this was not handled by the script. So there is a syntax error in the override
	int invalidOverrides = StorageUtil.ClearAllObjPrefix(none, "QTEFW_Override")

	if (invalidOverrides > 0)
		SendErrorMessage("QTEFW: " +invalidOverrides+ " invalid override(s) received. Check syntax.")
	EndIf

	if (minCorrect < 1 && maxFailures == -1)
		SendErrorMessage("QTEFW: Attempted to start a QTE event with no max failure or min success conditions. Terminating.")
		Dispel()
	EndIf

QTEKeyCodes = new int[9]
Style1Messages = new message[9]

;remnants of the older version, renaming and moving these very soon
QTETimeToComplete = StorageUtil.GetFloatValue(None, "QTEFW_Default_InputTimeInitial")
QTEExtraTimeOnCorrect = StorageUtil.GetFloatValue(None, "QTEFW_Default_InputTimeReset")

;Get the player's movement bindings
ForwardKey = Input.GetMappedKey("Forward")
BackwardKey = Input.GetMappedKey("Back")
LeftKey = Input.GetMappedKey("Strafe Left")
RightKey = Input.GetMappedKey("Strafe Right")
;JournalKey =  Input.GetMappedKey("Journal") // This is for later

;Call the setup function
SetUpQTE(minCorrect)

EndEvent

;This function makes sure the direction holding barrels/messages and the keycode array are in sync.
Function SetUpQTE(Int NumberToSet)
	
	Int QTEsReady = 0
	String BlankString
	Message BlankMessage

		if(style == "sequence")	
			
			While (NumberToSet > QTEsReady)
				QTEInputArray[QTEsReady].GetBaseObject().SetName(RandomDirection())
				QTEKeyCodes[QTEsReady] = DirectionToKeyCode(QTEInputArray[QTEsReady].GetBaseObject().GetName(), BlankMessage)
				QTEsReady += 1
			EndWhile	
		Else
			While (NumberToSet > QTEsReady)
				Style1Messages[QTEsReady] = RandomMessage()
				QTEKeyCodes[QTEsReady] = DirectionToKeyCode(BlankString, Style1Messages[QTEsReady])
				QTEsReady += 1
			EndWhile	
		EndIf

	BeginQTE(NumberToSet)
EndFunction

;Everything is setup, register the QTE keys.
Function BeginQTE(Int NumberToSet)

	;If this is the first time the player has been hit (not sent here by a messed up QTE), pause everything for 2 seconds to give the player some time to figure out what just happened

		If (FirstTimeHit)
			Utility.Wait(2.0)
		Endif

	RegisterForKey(ForwardKey)
	RegisterForKey(BackwardKey)
	RegisterForKey(LeftKey)
	RegisterForKey(RightKey)
	;RegisterForKey(JournalKey) // This is for later
	
		if(style == "sequence")
			QTEFW_Quest.SetObjectiveDisplayed(NumberToSet, abForce = true)
			;Since I cant control how fast this pops up we have to wait a bit here before registering for the timeout event
			Utility.Wait(1.0)
		Else
			Message.ResetHelpMessage("Style1InitialQTE")
			Style1Messages[CorrectKeysPressed].ShowAsHelpMessage("Style1InitialQTE", 2 ,3, 1)
		Endif
	
	FirstTimeHit = False
		
		If (QTETimeToComplete > 0.00)
			RegisterForSingleUpdate(QTETimeToComplete)
		EndIf

EndFunction

;Compare the players input to the required input and release the player when conditions are met. Array indexes make sure everything works in order.
Event OnKeyDown(Int KeyCode)

;soon as any input is received stop the timer
UnregisterForUpdate()

int handle

	If (KeyCode == QTEKeyCodes[CorrectKeysPressed])
		;Debug.Notification("Right key!")
				CorrectKeysPressed = CorrectKeysPressed +1
			if(style == "single")
				Message.ResetHelpMessage(CorrectKeysPressed - 1)
				Message.ResetHelpMessage(CorrectKeysPressed)
				Style1Messages[CorrectKeysPressed].ShowAsHelpMessage(CorrectKeysPressed, 2 , 2, 1)
			EndIf

				if (minCorrect == CorrectKeysPressed)
					Dispel()
					;Check if the calling script wants an event in case the player completes the QTE succesfully
					if(modEventOnSuccessEnd != "none")
							handle = ModEvent.Create(modEventOnSuccessEnd)

							if (handle)
								ModEvent.Send(handle)
							EndIf
					EndIf

					TerminateCalled = True

				ElseIf (QTEExtraTimeOnCorrect > 0.00)
					RegisterForSingleUpdate(QTEExtraTimeOnCorrect)
				EndIf

				;Check if the calling script wants an event in case the player presses a right button pass the # of correct key presses
				if(modEventOnCorrect != "none")
						handle = ModEvent.Create(modEventOnCorrect)

							if (handle)
								ModEvent.pushInt(handle, CorrectKeysPressed)
								ModEvent.Send(handle)
							EndIf
					EndIf
	Else
			if(style == "single")
				Message.ResetHelpMessage(CorrectKeysPressed)
			EndIf
		PlayerFailure("incorrectInput")
	EndIf
EndEvent

Function PlayerFailure(string reason)
int handle
	;Unregister everything so the player cant double/triple/quadruple screw up and confuse the script.
	UnregisterForKey(ForwardKey)
	UnregisterForKey(BackwardKey)
	UnregisterForKey(LeftKey)
	UnregisterForKey(RightKey)

	timesFailed += 1

		if (timesFailed >= maxFailures && maxFailures > -1)

			;Check if the calling script wants an event in case the player totally fails the QTE
			if(modEventOnTotalFailureEnd != "none")
				handle = ModEvent.Create(modEventOnTotalFailureEnd)
					Debug.MessageBox(modEventOnTotalFailureEnd)
					if (handle)
						ModEvent.Send(handle)
					EndIf
			EndIf
			Dispel()
			TerminateCalled = true
		Else

			;Check if the calling script wants an event in case the player screws up, pass # of mistakes and the reason why
			if(modEventOnFailure != "none")	
				handle = ModEvent.Create(modEventOnFailure)
				if (handle)
					ModEvent.PushString(handle, reason)
					ModEvent.PushInt(handle, timesFailed)
					ModEvent.Send(handle)
				EndIf

			EndIf

		EndIf
		
		;FailureModes:
		;Correct+ when the player makes an error the next QTE sequence will be more lenient by reducing the needed inputs by the amount of correct inputs received before the mistake
		;Total+ take whatever the difficulty of the messed up QTE was
		;Add a number of extra input requirements for the next QTE if desired
		
		if (failureMode == "Correct Plus")
			if(failureIncrease > 0)
				minCorrect = minCorrect - CorrectKeysPressed
				minCorrect = minCorrect + failureIncrease
			Else
				minCorrect = minCorrect - CorrectKeysPressed
			EndIf
		ElseIf(failureMode == "Total Plus")
				if(failureIncrease > 0)
					minCorrect += 1
				EndIf
		EndIf
			
		;The ShowQuestObjective message cant handle more than 9 aliases, so we have to limit this here to 9.
		;Besides 9 is a lot already. Plenty of other ways to make it more challenging.

		if(minCorrect > 9)
			minCorrect = 9
		EndIf
			
		CorrectKeysPressed = 0
		; Should make this MCM configurable at some point. Maybe. I dont know if anyone even notices. I think a small break here is good anyway. Regain composure for the next QTE round or something.
		; and give the sluggish quest objective messages some time to fade
		Utility.Wait(2.0)

		;If the script has been asked to terminate or the player has managed to die. Stop.
		if(!TerminateCalled && !Player.IsDead())
			SetUpQTE(minCorrect)
		EndIf

EndFunction 

;Function that renames the barrels to random directions (Style index 0, Sequence)
string Function RandomDirection()
	string direction
	int random = Utility.RandomInt(1, 4)
		If (random == 1)
			direction = "forward"
		ElseIf (random == 2)
			direction = "backward"
		ElseIf (random == 3)
			direction = "left"
		ElseIf (random == 4)
			direction = "right"
		Else
			SendErrorMessage("Fallthrough in RandomDirection()")
		EndIf
	Return direction	
EndFunction

;Function that randomizes the order of QTE inputs (Style index 1, Single)
message Function RandomMessage()
	message messageToReturn
	int	random = Utility.RandomInt(1,4)
	
		If (random == 1)
			messageToReturn = ForwardMessage
		ElseIf (random == 2)
			messageToReturn = BackwardMessage
		ElseIf (random == 3)
			messageToReturn = LeftMessage
		ElseIf (random == 4)
			messageToReturn = RightMessage
		Else
			SendErrorMessage("Fallthrough in RandomMessage()")
		EndIf

	Return messageToReturn
EndFunction

;Function that takes a renamed barrel or a message and returns the corresponding keycode. Used by both QTE styles.
int Function  DirectionToKeyCode(String direction, Message directionMessage)
	int KeyCodeToReturn
		if (direction == "forward" || directionMessage == ForwardMessage)
			KeyCodeToReturn = ForwardKey
		ElseIf(direction == "backward" || directionMessage == BackwardMessage)
			KeyCodeToReturn = BackwardKey
		ElseIf(direction == "left" || directionMessage == LeftMessage)
			KeyCodeToReturn = LeftKey
		ElseIf(direction == "right" || directionMessage == RightMessage)
			KeyCodeToReturn = RightKey
		Else
			Debug.Notification("Fallthrough DirectionToKeyCode()")
		EndIf
	Return KeyCodeToReturn			
EndFunction

Function SendErrorMessage(string Error)

int intrusiveErrors = StorageUtil.GetIntValue(None, "QTEFW_Intrusive_Errors")

	If(intrusiveErrors > 0)
		Debug.MessageBox(Error)
	Else
		Debug.Trace(Error)
	EndIf

EndFunction

;Player ran out of time, run the failure function.
Event OnUpdate()
	PlayerFailure("outOfTime")	
EndEvent

;this bad boy unregisters everything this script has registered so I dont have to bother.
Event OnEffectFinish(Actor Target, Actor Caster)
	TerminateCalled = True
EndEvent	



Message Property ForwardMessage  Auto  

Message Property BackwardMessage  Auto  

Message Property LeftMessage  Auto  

Message Property RightMessage  Auto  

Quest Property QTEFW_Quest  Auto  
