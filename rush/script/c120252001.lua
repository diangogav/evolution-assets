local cm,m=GetID()
local list={120120000}
cm.name="青眼究极龙"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedureSP(c,true,true,cm.matfilter,cm.check,2,3)
	RD.SetFusionMaterial(c,{list[1]},3,3)
end
--Fusion Material
function cm.matfilter(c,fc,sub)
	return c:IsFusionCode(list[1]) or (sub and c:CheckFusionSubstitute(fc))
end
function cm.exfilter(c)
	return RD.IsCanBeDoubleFusionMaterial(c,120252001)
end
function cm.check(g,tp,fc,chkf)
	return g:GetCount()==3 or g:IsExists(cm.exfilter,1,nil)
end