local format = string.format
local formatMoney = function(value)
	if value >= 1e4 then
		return format("|cffffd700%dg |r|cffc7c7cf%ds |r|cffeda55f%dc|r", value/1e4, strsub(value, -4) / 1e2, strsub(value, -2))
	elseif value >= 1e2 then
		return format("|cffc7c7cf%ds |r|cffeda55f%dc|r", strsub(value, -4) / 1e2, strsub(value, -2))
	else
		return format("|cffeda55f%dc|r", strsub(value, -2))
	end
end

local oldMoney
local itemCount = 0

local event = CreateFrame("Frame")
event:SetScript("OnEvent", function(self, event, ...) self[event](self, event, ...) end)
event:RegisterEvent"MERCHANT_SHOW"
event:RegisterEvent"PLAYER_MONEY"

event.MERCHANT_SHOW = function(self, event, ...)
	oldMoney = GetMoney()
	-- repair
	if not IsAltKeyDown() then
		if CanMerchantRepair() then
			local cost, needed = GetRepairAllCost()
			if needed then
				local GuildWealth = CanGuildBankRepair() and GetGuildBankWithdrawMoney() > cost
				if GuildWealth then
					RepairAllItems(1)
					print(format("Guild bank repaired for %s.", formatMoney(cost)))
				elseif cost < GetMoney() then
					RepairAllItems()
					print(format("Repaired for %s.", formatMoney(cost)))
				else
					print("Repairs were unaffordable.")
				end
				HideRepairCursor()
			end
		end
	end
	-- sell junk
	for bag = 0, 4 do
		for slot=0,GetContainerNumSlots(bag) do
			local link = GetContainerItemLink(bag, slot)
			if link and select(3, GetItemInfo(link)) == 0 then
				ShowMerchantSellCursor(1)
				UseContainerItem(bag, slot)
				itemCount = itemCount + GetItemCount(link)
			end
		end
	end
end
event.PLAYER_MONEY = function(self, event, ...)
	local newMoney = GetMoney()
	if oldMoney and oldMoney > 0 then
		diffMoney = newMoney - oldMoney
	else
		diffMoney = 0
	end

	if diffMoney > 0 and itemCount > 0 then
		print(format("Sold %d trash item%s for %s.", itemCount, itemCount ~= 1 and "s" or "", formatMoney(diffMoney)))
	end
	itemCount = 0
end
