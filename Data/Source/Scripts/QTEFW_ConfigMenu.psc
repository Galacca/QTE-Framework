Scriptname QTEFW_ConfigMenu extends ski_configbase  

string[] _QTEStyle
string[] _FailureMode
string keyName
string keyIndex

int _menuStyle_M

int _toggleFailureIncreasesDifficulty_B
int _toggleStartTest_B

int _sliderInitialInputTime_S
int _sliderInputTimeReset_S
int _sliderInputTimeModifierCorrect_S
int _sliderInputTimeModifierFailure_S

int _sliderMaxFailures_S
int _sliderMinCorrect_S


string lastValueVisited
string lastValueType
	
Event OnConfigInit()
	
	Pages = new string[3]
	Pages[0] = "General"
	Pages[1] = "Timers"
	Pages[2] = "Debug/Test"
	
	_QTEStyle = new string[2]
	_QTEStyle[0] = "Single"
	_QTEStyle[1] = "Sequence"

	_FailureMode = new string[2]
	_FailureMode[0] = "Correct Plus"
	_FailureMode[1] = "Total Plus"
	
EndEvent

Event OnPageReset(string page)
	if (page == "General")
		SetCursorFillMode(TOP_TO_BOTTOM)
		AddMenuOptionST("STYLE_MENU", "QTE Style", _QTEStyle[StorageUtil.GetIntValue(None, "QTEFW_Default_Style_MCM_Index")])
		AddMenuOptionST("FAILURE_MODE_MENU", "Failure Mode", _FailureMode[StorageUtil.GetIntValue(None, "QTEFW_Default_FailureMode_MCM_Index")])
		AddSliderOptionST("FAILURE_INCREASE", "Extra input on failure", StorageUtil.GetIntValue(None, "QTEFW_Default_FailureIncrease"))
		AddSliderOptionST("MAX_FAILURES", "Failures to completely fail", StorageUtil.GetIntValue(None, "QTEFW_Default_MaxFailures"))
		AddSliderOptionST("MIN_CORRECT", "Correct inputs in a row to win", StorageUtil.GetIntValue(None, "QTEFW_Default_MinCorrect"))
	ElseIf(page == "Timers")
		float timerReset = StorageUtil.GetFloatValue(None, "QTEFW_Default_InputTimeReset")
		
		SetCursorFillMode(TOP_TO_BOTTOM)
		AddSliderOptionST("TIMER_INITIAL", "Seconds to hit the first input", StorageUtil.GetFloatValue(None, "QTEFW_Default_InputTimeInitial"),"{2}")
		AddSliderOptionST("TIMER_RESET", "Reset timer in seconds", StorageUtil.GetFloatValue(None, "QTEFW_Default_InputTimeReset"),"{2}")

		if timerReset != 00
			AddSliderOptionST("TIMER_MODIFY_CORRECT", "Modify the reset timer on correct input", StorageUtil.GetFloatValue(None, "QTEFW_Default_InputTimeModifierCorrect"),"{2}")
			AddSliderOptionST("TIMER_MODIFY_FAILURE", "Modify the reset timer on incorrect input", StorageUtil.GetFloatValue(None, "QTEFW_Default_InputTimeModifierFailure"),"{2}")
		else
			AddSliderOptionST("TIMER_MODIFY_CORRECT", "Modify the reset timer on correct input", StorageUtil.GetFloatValue(None, "QTEFW_Default_InputTimeModifierCorrect"),"{2}",OPTION_FLAG_DISABLED)
			AddSliderOptionST("TIMER_MODIFY_FAILURE", "Modify the reset timer on incorrect input", StorageUtil.GetFloatValue(None, "QTEFW_Default_InputTimeModifierFailure"),"{2}",OPTION_FLAG_DISABLED)
		EndIf

	ElseIf (page == "Debug/Test")
		AddTextOptionST("QTE_TEST", "Start a QTE test", "")
	EndIf

EndEvent

state STYLE_MENU

	event OnMenuOpenST()
		SetMenuDialogStartIndex(StorageUtil.GetIntValue(None, "QTEFW_Default_Style_MCM_Index"))
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(_QTEStyle)
	endEvent

	event OnMenuAcceptST(int index)
			StorageUtil.SetStringValue(None,"QTEFW_Default_Style", _QTEStyle[index])
			StorageUtil.SetIntValue(None, "QTEFW_Default_Style_MCM_Index", index)
			SetMenuOptionValueST(_QTEStyle[index])
			if (index == 1)
				SetObjectiveDisplayed(0)
			EndIf
	endEvent

	event OnDefaultST()
		SetMenuOptionValueST(_QTEStyle[0])
	endEvent

	event OnHighlightST()
		SetInfoText("Two different styles of QTE's. Single displays one button at a time on screen. Sequence displays from 1-9 buttons as a quest objective. You can test these in Debug/Test menu.")
	endEvent

endState

state FAILURE_MODE_MENU

	event OnMenuOpenST()
		SetMenuDialogStartIndex(StorageUtil.GetIntValue(None, "QTEFW_Default_FailureMode_MCM_Index"))
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(_FailureMode)
	endEvent

	event OnMenuAcceptST(int index)
			StorageUtil.SetStringValue(None,"QTEFW_Default_FailureMode", _FailureMode[index])
			StorageUtil.SetIntValue(None, "QTEFW_Default_FailureMode_MCM_Index", index)
			SetMenuOptionValueST(_FailureMode[index])
	endEvent

	event OnDefaultST()
		SetMenuOptionValueST(_FailureMode[0])
	endEvent

	event OnHighlightST()
		SetInfoText("On failing a QTE does the next QTE need more inputs? Example: You set the extra input to 1. You had to hit 3 inputs, but only hit 2. Correct+ sets the next one to 1+1, Total+ sets it to 3+1.")
	endEvent

endState

state FAILURE_INCREASE

	event OnSliderOpenST()
		SetSliderDialogStartValue(StorageUtil.GetIntValue(None, "QTEFW_Default_FailureIncrease"))
		SetSliderDialogDefaultValue(1)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		int sliderVal = value as int
		SetSliderDialogStartValue(StorageUtil.SetIntValue(None, "QTEFW_Default_FailureIncrease", sliderVal))
		SetSliderOptionValueST(sliderVal )
	endEvent

	event OnDefaultST()
		SetSliderOptionValueST(1)
	endEvent

	event OnHighlightST()
		SetInfoText("After failing how many extra inputs the next QTE has. Can be set to 0. Will never go over 9 in Sequence mode")
	endEvent
endState

state MAX_FAILURES

	event OnSliderOpenST()
		SetSliderDialogStartValue(StorageUtil.GetIntValue(None, "QTEFW_Default_MaxFailures"))
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(-1, 100)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		int sliderVal = value as int
		SetSliderDialogStartValue(StorageUtil.SetIntValue(None, "QTEFW_Default_MaxFailures", sliderVal))
		SetSliderOptionValueST(sliderVal )
	endEvent

	event OnDefaultST()
		SetSliderOptionValueST(-1)
	endEvent

	event OnHighlightST()
		SetInfoText("How many times can the player fail until the QTE ends in a total failure state. -1 for infinite")
	endEvent
endState

state MIN_CORRECT

	event OnSliderOpenST()
		SetSliderDialogStartValue(StorageUtil.GetIntValue(None, "QTEFW_Default_MinCorrect"))
		SetSliderDialogDefaultValue(3)
		SetSliderDialogRange(1, 100)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		int sliderVal = value as int
		SetSliderDialogStartValue(StorageUtil.SetIntValue(None, "QTEFW_Default_MinCorrect", sliderVal))
		SetSliderOptionValueST(sliderVal )
	endEvent

	event OnDefaultST()
		SetSliderOptionValueST(3)
	endEvent

	event OnHighlightST()
		SetInfoText("How many correct inputs must the player hit in a row to end the QTE in a win state.")
	endEvent
endState

state TIMER_INITIAL

	event OnSliderOpenST()
		SetSliderDialogStartValue(StorageUtil.GetFloatValue(None, "QTEFW_Default_InputTimeInitial"))
		SetSliderDialogDefaultValue(2.00)
		SetSliderDialogRange(0, 120)
		SetSliderDialogInterval(0.1)
	endEvent

	event OnSliderAcceptST(float sliderVal)
		SetSliderDialogStartValue(StorageUtil.SetFloatValue(None, "QTEFW_Default_InitialInputTimet", sliderVal))
		SetSliderOptionValueST(sliderVal,"{2}")
	endEvent

	event OnDefaultST()
		SetSliderOptionValueST(2.00,"{2}")
	endEvent

	event OnHighlightST()
		SetInfoText("How much time (in seconds) does the player have to hit the first correct input. 0 for infinite.")
	endEvent
endState

state TIMER_RESET

	event OnSliderOpenST()
		SetSliderDialogStartValue(StorageUtil.GetFloatValue(None, "QTEFW_Default_InputTimeReset"))
		SetSliderDialogDefaultValue(2.00)
		SetSliderDialogRange(0, 120)
		SetSliderDialogInterval(0.1)
	endEvent

	event OnSliderAcceptST(float sliderVal)
		SetSliderDialogStartValue(StorageUtil.SetFloatValue(None, "QTEFW_Default_InputTimeReset", sliderVal))
		SetSliderOptionValueST(sliderVal,"{2}")

	if (sliderVal == 0.00)
		SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "TIMER_MODIFY_FAILURE")
		SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "TIMER_MODIFY_CORRECT")
	Else
		SetOptionFlagsST(OPTION_FLAG_NONE, true, "TIMER_MODIFY_FAILURE")
		SetOptionFlagsST(OPTION_FLAG_NONE, true, "TIMER_MODIFY_CORRECT")
	EndIf

	endEvent

	event OnDefaultST()
		SetSliderOptionValueST(2.00)
	endEvent

	event OnHighlightST()
		SetInfoText("How much time (in seconds) to hit the next input after a correct input. 0 for infinite. Note that this value is NOT added to any time possibly remaining.")
	endEvent
endState

state TIMER_MODIFY_CORRECT
		
	event OnSliderOpenST()
		SetSliderDialogStartValue(StorageUtil.GetFloatValue(None, "QTEFW_Default_InputTimeModifierCorrect"))
		SetSliderDialogDefaultValue(0.00)
		SetSliderDialogRange(-120, 120)
		SetSliderDialogInterval(0.1)
	endEvent

	event OnSliderAcceptST(float sliderVal)
		SetSliderDialogStartValue(StorageUtil.SetFloatValue(None, "QTEFW_Default_InputTimeModifierCorrect", sliderVal))
		SetSliderOptionValueST(sliderVal,"{2}")
	
	endEvent

	event OnDefaultST()
		SetSliderOptionValueST(0.00)
	endEvent

	event OnHighlightST()
		SetInfoText("Modify the reset timer by this amont (in seconds) whenever a correct input is pressed.")
	endEvent
endState

state TIMER_MODIFY_FAILURE

	event OnSliderOpenST()
		SetSliderDialogStartValue(StorageUtil.GetFloatValue(None, "QTEFW_Default_InputTimeModifierFailure"))
		SetSliderDialogDefaultValue(0.00)
		SetSliderDialogRange(-120, 120)
		SetSliderDialogInterval(0.1)
	endEvent

	event OnSliderAcceptST(float sliderVal)
		SetSliderDialogStartValue(StorageUtil.SetFloatValue(None, "QTEFW_Default_InputTimeModifierFailure", sliderVal))
		SetSliderOptionValueST(sliderVal,"{2}")
	endEvent

	event OnDefaultST()
		SetSliderOptionValueST(0.00)
	endEvent

	event OnHighlightST()
		SetInfoText("Modify the reset timer by this amont (in seconds) whenever an incorrect input is pressed.")
	endEvent
endState
		
state QTE_TEST
	event OnSelectST()	
		string myEventOnCorrect = "myEventOnCorrect"
		string myEventOnFailure = "myEventOnFailure"
		string myEventOnSuccessEnd = "myEventOnSuccessEnd"
		string myEventOnTotalFailureEnd = "myEventOnTotalFailureEnd"

		RegisterForModEvent(myEventOnCorrect, "myCallbackOnCorrect")
		RegisterForModEvent(myEventOnFailure, "myCallbackOnFailure")
		RegisterForModEvent(myEventOnSuccessEnd, "myCallbackOnSuccessEnd")
		RegisterForModEvent(myEventOnTotalFailureEnd, "myCallBackOnSuccessEnd")

		StorageUtil.SetStringValue(None, "QTEFW_Override_modEventOnCorrect", myEventOnCorrect)
		StorageUtil.SetStringValue(None, "QTEFW_Override_modEventOnFailure", myEventOnFailure)
		StorageUtil.SetStringValue(None, "QTEFW_Override_modEventOnSuccessEnd", myEventOnSuccessEnd)
		StorageUtil.SetStringValue(None, "QTEFW_Override_modEventOnTotalFailureEnd", myEventOnTotalFailureEnd)

		PlayerRef.EquipItem(TestPotion)
   	endEvent
endState

Event myCallBackOnCorrect(int Correct)
	Debug.Notification(Correct + " correct!")
EndEvent	

Event myCallBackOnFailure(string Reason, int Failures)
	Debug.MessageBox(Failures + " failures! Reason: " +Reason)
EndEvent

Event myCallBackOnSuccessEnd()
	Debug.MessageBox("It's over! Good job!")
EndEvent

Event myCallbackOnTotalFailureEnd()
	Debug.MessageBox("It's over! You messed up too many times!")
EndEvent
Potion Property TestPotion  Auto  

Actor Property PlayerRef  Auto  
