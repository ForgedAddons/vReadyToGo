local addon, ns = ...
local oldMoney
local itemCount = 0

ns.RegisterEvent("MERCHANT_SHOW", function(event, ...)
	oldMoney = GetMoney()
	-- repair
	if not IsAltKeyDown() then
		if CanMerchantRepair() then
			local cost, needed = GetRepairAllCost()
			if needed then
				local GuildWealth = CanGuildBankRepair() and GetGuildBankWithdrawMoney() > cost
				if GuildWealth then
					RepairAllItems(1)
					ns.Printf("Guild bank repaired for %s.", ns.FormatMoney(cost))
				elseif cost < GetMoney() then
					RepairAllItems()
					ns.Printf("Repaired for %s.", ns.FormatMoney(cost))
				else
					ns.Print("Repairs were unaffordable.")
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
end)

ns.RegisterEvent("PLAYER_MONEY", function(event, ...)
	local newMoney = GetMoney()
	if oldMoney and oldMoney > 0 then
		diffMoney = newMoney - oldMoney
	else
		diffMoney = 0
	end

	if diffMoney > 0 and itemCount > 0 then
		ns.Printf("Sold %d trash item%s for %s.", itemCount, itemCount ~= 1 and "s" or "", ns.FormatMoney(diffMoney))
		itemCount = 0
	end
end)
