Scriptname QTEFW_QTEScript extends Quest

ObjectReference[] Property QTEInputArray  Auto  
Message[] Property DirectionMessages  Auto  ;0 forward, 1 backward, 2 left, 3 right
Quest Property QTEFW_Quest  Auto  
Int[] Property QTEKeyCodes  Auto  
Message[] Property SingleStyleMessages  Auto  

string style
string failureMode
string modEventOnCorrect
string modEventOnFailure
string modEventOnSuccessEnd
string modEventOnTotalFailureEnd

float inputTimeInitial
float delayBeforeNext
float inputTimeReset
float inputTimeModifierCorrect
float inputTimeModifierFailure

int maxFailures
int minCorrect
int failureIncrease
int timesFailed = 0
int intrusiveErrors
int QTEsReady
Int CorrectKeysPressed = 0
Int ForwardKey
Int BackwardKey
Int LeftKey
Int RightKey

bool active = false
bool Initial = True
Actor Property Player  Auto 

Function BeginQTE()

intrusiveErrors = StorageUtil.GetIntValue(None, "QTEFW_Intrusive_Errors")

if(active)
	If(intrusiveErrors > 0)
		Debug.MessageBox("Tried to start a QTE while one was already running.")
	Else
		Debug.Trace("QTEFW: Tried to start a QTE while one was already running.")
	EndIf
EndIf	

	

	;Check for Overrides, pluck the valid ones, if there is no override use the default
	style = StorageUtil.PluckStringValue(None, "QTEFW_Override_Style", StorageUtil.GetStringValue(None, "QTEFW_Default_Style"))
	failureMode = StorageUtil.PluckStringValue(None, "QTEFW_Override_FailureMode", StorageUtil.GetStringValue(None, "QTEFW_Default_FailureMode"))
	
	inputTimeInitial = StorageUtil.PluckFloatValue(None, "QTEFW_Override_InputTimeInitial", StorageUtil.GetFloatValue(None, "QTEFW_Default_InputTimeInitial"))
	delayBeforeNext = StorageUtil.PluckFloatValue(None, "QTEFW_Override_DelayBeforeNext", StorageUtil.GetFloatValue(None, "QTEFW_Default_DelayBeforeNext"))
	inputTimeReset = StorageUtil.PluckFloatValue(None, "QTEFW_Override_InputTimeReset", StorageUtil.GetFloatValue(None, "QTEFW_Default_InputTimeReset"))
	inputTimeModifierCorrect = StorageUtil.PluckFloatValue(None, "QTEFW_Override_InputTimeModifierCorrect", StorageUtil.GetFloatValue(None, "QTEFW_Default_InputTimeModifierCorrect"))
	inputTimeModifierFailure = StorageUtil.PluckFloatValue(None, "QTEFW_Override_inputTimeModifierFailure", StorageUtil.GetFloatValue(None, "QTEFW_Default_InputTimeModifierFailure"))

	maxFailures = StorageUtil.PluckIntValue(None, "QTEFW_Override_MaxFailures", StorageUtil.GetIntValue(None, "QTEFW_Default_MaxFailures"))
	minCorrect = StorageUtil.PluckIntValue(None, "QTEFW_Override_MinCorrect", StorageUtil.GetIntValue(None, "QTEFW_Default_MinCorrect"))
	failureIncrease = StorageUtil.PluckIntValue(None, "QTEFW_Override_FailureIncrease", StorageUtil.GetIntValue(None, "QTEFW_Default_FailureIncrease"))
	
	modEventOnCorrect = StorageUtil.PluckStringValue(None, "QTEFW_Override_modEventOnCorrect", "none")
	modEventOnFailure = StorageUtil.PluckStringValue(None, "QTEFW_Override_modEventOnFailure", "none")
	modEventOnSuccessEnd = StorageUtil.PluckStringValue(None, "QTEFW_Override_modEventOnSuccessEnd", "none")
	modEventOnTotalFailureEnd = StorageUtil.PluckStringValue(None, "QTEFW_Override_modEventOnTotalFailureEnd", "none")

	;Anything returned by this was not plucked so there is a syntax error in the key
	int invalidOverrides = StorageUtil.ClearAllObjPrefix(none, "QTEFW_Override")

	if (invalidOverrides > 0)
		if (IntrusiveErrors > 0)
			Debug.MessageBox("QTEFW: " +invalidOverrides+ " invalid override(s) received. Check syntax.")
		Else
			Debug.Trace("QTEFW: " +invalidOverrides+ " invalid override(s) received. Check syntax.")
		EndIf
	EndIf

	if (minCorrect < 1 && maxFailures == -1)

		if (IntrusiveErrors > 1)
			Debug.MessageBox("Attempted to start a QTE event with no max failure or min success conditions. Terminating request.")
		Else
			Debug.Trace("QTEFW: Attempted to start a QTE event with no max failure or min success conditions. Terminating request.")
		EndIf
		
	EndIf

	ForwardKey = Input.GetMappedKey("Forward")
	BackwardKey = Input.GetMappedKey("Back")
	LeftKey = Input.GetMappedKey("Strafe Left")
	RightKey = Input.GetMappedKey("Strafe Right")

if(!active)
	SetUpQTE()
EndIf
	
EndFunction

;Sequence Style: We are renaming barrels in the QTEFW_RefHolderCell to random directions then filling the actual array that holds the correct keycodes to press accordingly.
;The barrels are linked to the QTE Framework quest and will display the directions as quest objectives.
;But why? Because I simply do not have the time to learn flash right now to do an actual UI widget for this. This will have to do until I have a bit more time.
;Single Style: Same principle except we are not renaming barrels, we simply have messages that give a graphical representation of the correct button.
;The buttons are displayed one at a time. The reason why we do not use these graphical buttons in Sequence style is that a help message cannot hold dynamic data of any kind.
;and help message is the only way to get the graphical buttons to appear (until I learn flash...)
;I wish I wouldnt have to resort in two arrays, but since there are no lists I have to improvise.

Function SetUpQTE()
	active = true

	SingleStyleMessages = new message [9]
	QTEKeyCodes = new int [9]
	QTEsReady = 0
	String BlankString
	Message BlankMessage

		if(style == "sequence")
			While (minCorrect > QTEsReady)
				QTEInputArray[QTEsReady].GetBaseObject().SetName(RandomDirection())
				QTEKeyCodes[QTEsReady] = DirectionToKeyCode(QTEInputArray[QTEsReady].GetBaseObject().GetName(), BlankMessage)
				QTEsReady += 1
			EndWhile	
		Else
			While (minCorrect > QTEsReady)
				SingleStyleMessages[QTEsReady] = DirectionMessages[Utility.RandomInt(0, 3)]
				QTEKeyCodes[QTEsReady] = DirectionToKeyCode(BlankString, SingleStyleMessages[QTEsReady])
				QTEsReady += 1
			EndWhile	
		EndIf
	
	DisplayQTE()
EndFunction

;Function that handles the visual feedback whenever a new QTE starts
Function DisplayQTE()

	If (Initial)
		Utility.Wait(2.0) ;Changing this to a MCM settable global later
	Endif

	RegisterForKey(ForwardKey)
	RegisterForKey(BackwardKey)
	RegisterForKey(LeftKey)
	RegisterForKey(RightKey)
	;RegisterForKey(JournalKey) // This is for later
	
		if(style == "sequence")
			SetObjectiveDisplayed(minCorrect, abForce = true)
			;Since I cant control how fast this pops up we have to wait a bit here before registering for the timeout event
			Utility.Wait(1.0)
		Else
			;Found out that unique tagging the first one of the sequence gets more reliable results. How? Why? I have no idea.
			Message.ResetHelpMessage("Initial")
			SingleStyleMessages[CorrectKeysPressed].ShowAsHelpMessage("Initial", 2 ,3, 1)
		Endif
		
		If (Initial && inputTimeInitial > 0.00)
			RegisterForSingleUpdate(inputTimeInitial)
		ElseIf( inputTimeReset > 0.00)
			RegisterForSingleUpdate(inputTimeReset)
		EndIf

Initial = False
EndFunction

Event OnKeyDown(Int KeyCode)

int handle
	
	If (KeyCode == QTEKeyCodes[CorrectKeysPressed])
		CorrectKeysPressed = CorrectKeysPressed +1
		
			;handle displaying the next input requested in single style
			if(style == "single")
				Message.ResetHelpMessage(CorrectKeysPressed - 1)
				Message.ResetHelpMessage(CorrectKeysPressed)
				Debug.MessageBox("Correct keys pressed = " +CorrectKeysPressed)
				SingleStyleMessages[CorrectKeysPressed].ShowAsHelpMessage(CorrectKeysPressed, 2 , 2, 1)
			EndIf


				;If the calling script wants to receive an event when the QTE is completed succesfully
				
				if (minCorrect == CorrectKeysPressed)
					if(modEventOnSuccessEnd != "none")
							handle = ModEvent.Create(modEventOnSuccessEnd)

							if (handle)
								ModEvent.Send(handle)
							EndIf

						CleanUp()

					EndIf
				Else

				;If the calling script wants to receive an event when a correct input is received
					if(modEventOnCorrect != "none")
						handle = ModEvent.Create(modEventOnCorrect)

							if (handle)
								ModEvent.pushInt(handle, CorrectKeysPressed)
								ModEvent.Send(handle)
							EndIf
					EndIf

					If (inputTimeReset > 0.00)
						UnregisterForUpdate()
						
						if(inputTimeModifierCorrect > 0.00)
							inputTimeReset = inputTimeReset + inputTimeModifierCorrect
						ElseIf(inputTimeModifierCorrect < 0.00)
							inputTimeReset = inputTimeReset - inputTimeModifierCorrect
								;We have to assume for now that going for an infinite timer when using modifiers is not desired by the sending script
								;Good luck trying to hit this one in time.
								if(inputTimeReset <= 0.00)
									inputTimeReset = 0.10
								EndIf
						EndIf
						
						RegisterForSingleUpdate(inputTimeReset)
					EndIf
				EndIf
	Else
			if(style == "single")
				Message.ResetHelpMessage(CorrectKeysPressed)
			EndIf
		PlayerFailure("incorrectInput")
	EndIf
EndEvent

Function PlayerFailure(string failureReason)
	int handle
	timesFailed = timesFailed + 1

	
	;Unregister everything so the player cant double/triple/quadruple screw up and confuse the script.
	UnregisterForUpdate()
	UnregisterForKey(ForwardKey)
	UnregisterForKey(BackwardKey)
	UnregisterForKey(LeftKey)
	UnregisterForKey(RightKey)

	if (timesFailed >= maxFailures && maxFailures > -1)

		;If the calling script wants to receive an event when the player has messed up too many times
		if(modEventOnTotalFailureEnd != "none")
			handle = ModEvent.Create(modEventOnTotalFailureEnd)

				if (handle)
					ModEvent.Send(handle)
				EndIf
		EndIf

		CleanUp()
			
	Else

		;If the calling script wants to receive an event every time the player messes up, wheter it be a timeout or an incorrect input
		if(modEventOnFailure != "none")	
			handle = ModEvent.Create(modEventOnFailure)
				if (handle)
					ModEvent.PushString(handle, FailureReason)
					ModEvent.PushInt(handle, timesFailed)
					ModEvent.Send(handle)
				EndIf

		EndIf

		;FailureModes:
		;Correct+ when the player makes an error the next QTE sequence will be more lenient by reducing the needed inputs by the amount of correct inputs received before the mistake
		;Total+ take whatever the difficulty of the messed up QTE was and add to it (if desired)
		
		if (failureMode == "Correct Plus")
			if(failureIncrease > 0)
				minCorrect = minCorrect - CorrectKeysPressed
				minCorrect = minCorrect + failureIncrease
			EndIf
		ElseIf(failureMode == "Total Plus")
				if(failureIncrease > 0)
					minCorrect = minCorrect + 1
				EndIf
		EndIf
		
		CorrectKeysPressed = 0	

		;The ShowQuestObjective message cant handle more than 9 aliases, so we have to limit this here to 9.
		;Besides 9 is a lot already. There are many other ways to up the difficulty.

			if(minCorrect > 9)
				minCorrect = 9
			EndIf

		;Lets not send a new QTE in case the player has managed to get himself killed
		
		if(Player.IsDead())
			CleanUp()
		Else
			SetUpQTE()
		EndIf
	EndIf

EndFunction

;Function that renames the barrels to random directions (Style Sequence)
string Function RandomDirection()
	string direction
	int random = Utility.RandomInt(1, 4)
		If (random == 1)
			direction = "forward"
		ElseIf (random == 2)
			direction = "backward"
		ElseIf (random == 3)
			direction = "left"
		Else
			direction = "right"
		EndIf
	Return direction	
EndFunction

;DECREPIT, just randomize the array index.
;This was from before when the directional messages were not in an array
;Function that randomizes the order of QTE inputs (Style Single)
message Function RandomMessage()
	message messageToReturn
	int	random = Utility.RandomInt(0,3)
	
		If (random == 0)
			messageToReturn = DirectionMessages[0]
		ElseIf (random == 1)
			messageToReturn = DirectionMessages[1]
		ElseIf (random == 2)
			messageToReturn = DirectionMessages[2]
		Else
			messageToReturn =  DirectionMessages[3]
		EndIf

	Return messageToReturn
EndFunction

;Takes the name of a barrel or a directional message. Returns the corresponding keycode regardless of player keybindings.
;Does not work with VR im pretty sure

int Function  DirectionToKeyCode(String direction, Message directionMessage)
	int KeyCodeToReturn
		if (direction == "forward" || directionMessage == DirectionMessages[0])
			return ForwardKey
		ElseIf(direction == "backward" || directionMessage == DirectionMessages[1])
			return BackwardKey
		ElseIf(direction == "left" || directionMessage == DirectionMessages[2])
			return LeftKey
		ElseIf(direction == "right" || directionMessage == DirectionMessages[3])
			return RightKey
		Else
			;Memory of a time when I got bamboozled by this thing randoming right eight times in a row and I thought it was bugged
			Debug.MessageBox("Fallthrough in DirectionToKeyCode")
			return ForwardKey
		EndIf
EndFunction

Function CleanUp()
	CorrectKeysPressed = 0
	UnregisterForUpdate()
	UnregisterForKey(ForwardKey)
	UnregisterForKey(BackwardKey)
	UnregisterForKey(LeftKey)
	UnregisterForKey(RightKey)

	UnregisterForModEvent(modEventOnCorrect)
	UnregisterForModEvent(modEventOnFailure)
	UnregisterForModEvent(modEventOnSuccessEnd)
	UnregisterForModEvent(modEventOnTotalFailureEnd)
	
	;Just in case the calling script tried to override something during a modEvent.
	StorageUtil.ClearAllObjPrefix(none, "QTEFW_Override")

	active = false
	
EndFunction

Event OnUpdate()
	PlayerFailure("outOfTime")	
EndEvent
