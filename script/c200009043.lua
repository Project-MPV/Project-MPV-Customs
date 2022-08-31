local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
    Fusion.AddProcMixN(c,true,true,200009312,3)
end
s.material_setcode=0x7530,0x776e
s.listed_name=(c200009312)