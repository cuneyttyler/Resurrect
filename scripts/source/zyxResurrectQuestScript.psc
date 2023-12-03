Scriptname zyxResurrectQuestScript extends Quest

Event OnInit()
    While True
        If GameDaysPassed.GetValue() - zyxResurrectTimer.GetValue() >= zyxResurrectTimeout
            If !spellAdded
                Game.GetPlayer().AddSpell(zyxResurrectActiveEffectSpell)
                spellAdded = True
            EndIf
        Else
            If spellAdded
                Game.GetPlayer().RemoveSpell(zyxResurrectActiveEffectSpell)
                spellAdded = False
            EndIf
        EndIf
    EndWhile
EndEvent

Bool spellAdded = False

int zyxResurrectTimeout = 29

Spell property zyxResurrectActiveEffectSpell auto

globalvariable property zyxResurrectTimer auto

globalvariable property GameDaysPassed auto