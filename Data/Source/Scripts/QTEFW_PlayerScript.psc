Scriptname QTEFW_PlayerScript extends ReferenceAlias  

Event OnInit()
	RegisterForModEvent("QTEWF_useDefaults", "QTE_Default")

	;String lists
	StorageUtil.StringListAdd(none, "QTEFW_Default_KeysToRegister", "Forward", false)
	StorageUtil.StringListAdd(none, "QTEFW_Default_KeysToRegister",  "Back", false)
	StorageUtil.StringListAdd(none, "QTEFW_Default_KeysToRegister", "Strafe Left", false)
	StorageUtil.StringListAdd(none, "QTEFW_Default_KeysToRegister", "Strafe Right", false)

	;Strings
	StorageUtil.SetStringValue(None, "QTEFW_Default_Style", "Single")
	StorageUtil.SetStringValue(None, "QTEFW_Default_FailureMode", "Total Plus")
			
	;Floats
	;StorageUtil.SetFloatValue(None, "QTEFW_Default_DelayOnStart", 0.00)
	StorageUtil.SetFloatValue(None, "QTEFW_Default_InputTimeInitial", 2.00)
	;StorageUtil.SetFloatValue(None, "QTEFW_Default_DelayBeforeNext", 0.00)
	StorageUtil.SetFloatValue(None, "QTEFW_Default_InputTimeReset", 2.00)
	StorageUtil.SetFloatValue(None, "QTEFW_Default_InputTimeModifierCorrect", 0.00)
	StorageUtil.SetFloatValue(None, "QTEFW_Default_InputTimeModifierFailure", 0.00)

	;Ints
	StorageUtil.SetIntValue(None, "QTEFW_Default_MaxFailures", -1)
	StorageUtil.SetIntValue(None, "QTEFW_Default_MinCorrect", 3)
	StorageUtil.SetIntValue(None, "QTEFW_Default_FailureIncrease", 1)
	
	StorageUtil.SetIntValue(None, "QTEFW_Intrusive_Errors", 1)
	StorageUtil.SetIntValue(None, "QTEFW_Default_Style_MCM_Index", 0)
	StorageUtil.SetIntValue(None, "QTEFW_Default_FailureMode_MCM_Index", 1)
	
	RegisterForModEvent("QTEWF_useDefaults", "QTE_Default")

EndEvent

Event OnPlayerLoadGame()
	RegisterForModEvent("QTEWF_useDefaults", "QTE_Default")
EndEvent

Event QTE_Default()

	  (QTEFW_Quest as QTEFW_QTEScript).InitializeQTE()

EndEvent


Quest Property QTEFW_Quest  Auto  

ReferenceAlias Property DummyPointer  Auto  
