ScriptName zyxResurrectSpellTomeScript extends ObjectReference

Event OnRead()
    If GameDaysPassed.GetValue() - zyxResurrectTimer.GetValue() >= zyxResurrectTimeout && !Game.GetPlayer().HasSpell(zyxResurrectSpellScript)
        Game.GetPlayer().AddSpell(zyxResurrectActiveEffectSpell)
    EndIf
EndEvent

int zyxResurrectTimeout = 87

Spell property zyxResurrectActiveEffectSpell auto

Spell property zyxResurrectSpellScript auto

globalvariable property zyxResurrectTimer auto

globalvariable property GameDaysPassed auto