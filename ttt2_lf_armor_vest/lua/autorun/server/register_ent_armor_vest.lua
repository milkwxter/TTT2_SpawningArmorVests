-- this hook will register the item to the database
hook.Add("Initialize", "LOOTBASERegister_ArmorVest", function()
    if not LOOT_BASE then return end

	-- when registering item, spaces are ILLEGAL
    LOOT_BASE:RegisterItem("armorvest", {
	itemClassName = "ent_armor_vest",
	itemMaxSpawn = 2
	})
end)