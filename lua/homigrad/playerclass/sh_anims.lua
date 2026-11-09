
if SERVER then return end
if concommand.GetTable()["hg_getanim"] then return end
concommand.Add("hg_getanim", function()
	if IsValid(hg_getanim) then hg_getanim:Remove() end
	hg_getanim = vgui.Create("ZFrame")
	local frame = hg_getanim
	frame:SetSize(700, 700)
	frame:Center()
	frame:MakePopup()
	local hF = frame:GetTall() - 30
	local wF = frame:GetWide()
	local viewModel = vgui.Create("DModelPanel", frame)
	viewModel:SetSize(wF / 2, hF / 2)
	viewModel:SetPos(wF - viewModel:GetWide(), 30)
	viewModel:SetModel("models/player/alyx.mdl")
	viewModel:SetAnimated(true)
	local list = vgui.Create("DListView", frame)
	list:SetSize(wF / 2, hF)
	list:SetPos(0, 30)
	function list:UpdateContent()
		list:Clear()
		list:SetMultiSelect(false)
		list:AddColumn("ID")
		list:AddColumn("Name")
		local ent = viewModel.Entity
		local count = viewModel.Entity:GetSequenceCount() - 1
		for i = 1, count do
			local info = ent:GetSequenceInfo(i)
			list:AddLine(i, info.label)
		end
	end

	function list:OnRowSelected(id, panel)
		local id = panel:GetColumnText(1)
		local ent = viewModel.Entity
		ent:SetSequence(id)
	end

	local dTextEntry = vgui.Create("DTextEntry", frame)
	dTextEntry:SetPos(wF / 2, hF / 2 + 30)
	dTextEntry:SetSize(wF / 2, 25)
	function dTextEntry:OnEnter(value)
		viewModel:SetModel(value)
		list:UpdateContent()
	end

	list:UpdateContent()
end)
intersect_xyPartDeg = 1024