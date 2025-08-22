if SERVER then
    AddCSLuaFile()
	
	util.AddNetworkString("EquipArmorVestOnPlayer")
	util.AddNetworkString("RemoveArmorVestOnPlayer")
end

DEFINE_BASECLASS("ttt_base_placeable")

ENT.Type = "anim"
ENT.PrintName = "Armor Vest"
ENT.Base = "ttt_base_placeable"
ENT.Author = "milkwater"
ENT.Model = "models/player/armor_module3m/module3m.mdl"

local soundPickup = Sound("plate_in.wav")

function ENT:Initialize()
	self:SetModel(self.Model)

    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local b = 8

    self:SetCollisionBounds(Vector(-b, -b, -b), Vector(b, b, b))

    if SERVER then
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:SetMass(50)
			phys:Wake()
        end

        self:SetUseType(SIMPLE_USE)
    end
end

if SERVER then
    function ENT:Use(ply)
        -- make sure the guy using the item exists
        if not IsValid(ply) or not ply:IsPlayer() or not ply:IsActive() then return end
		
		-- make sure he doesnt have armor already
		if ply:GetArmor() >= 20 then return end
		
        -- make sound for feedback
        self:EmitSound(soundPickup)
		
		-- do something for the player
		ply:GiveArmor(20)
		
		-- blah blah blah
		net.Start("EquipArmorVestOnPlayer")
        net.WriteEntity(ply)
        net.WriteString("models/player/armor_module3m/module3m.mdl")
        net.Send(player.GetAll())
		
        -- delete item so he cant use it again
        self:Remove()
    end
	
	-- remove armor on death
	hook.Add("PostPlayerDeath", "RemoveVestHookOnDeath", function(ply)
		net.Start("RemoveArmorVestOnPlayer")
        net.WriteEntity(ply)
        net.Send(player.GetAll())
	end)
	
	-- remove armor on round preparing (most immersive)
	hook.Add("TTTPrepareRound", "RemoveVestHookOnRoundPrep", function()
		for _, ply in ipairs(player.GetAll()) do
			net.Start("RemoveArmorVestOnPlayer")
			net.WriteEntity(ply)
			net.Send(player.GetAll())
		end
	end)
end

if CLIENT then
	local TryT = LANG.TryTranslation
    local ParT = LANG.GetParamTranslation

    local key_params = {
        usekey = Key("+use", "USE"),
        walkkey = Key("+walk", "WALK"),
    }
	
	local vestData = {}

	net.Receive("EquipArmorVestOnPlayer", function()
		local ply = net.ReadEntity()
		local modelPath = net.ReadString()

		if not IsValid(ply) then return end

		vestData[ply] = {
			model = ClientsideModel(modelPath),
			path = modelPath
		}

		vestData[ply].model:SetNoDraw(true)
	end)
	
	net.Receive("RemoveArmorVestOnPlayer", function()
		local ply = net.ReadEntity()
		local modelPath = net.ReadString()

		if not IsValid(ply) then return end
		
		print("Trying to remove vest from " .. ply:Nick())
		
		if vestData[ply] and IsValid(vestData[ply].model) then
			vestData[ply].model:Remove()
		end

		vestData[ply] = nil
	end)

    ---
    -- Hook that is called if a player uses their use key while focusing on the entity.
    -- Early check if client can use the item
    -- @return bool True to prevent pickup
    -- @realm client
    function ENT:ClientUse()
        local client = LocalPlayer()

        if not IsValid(client) or not client:IsPlayer() or not client:IsActive() then
            return true
        end
    end

    -- handle looking at item
    hook.Add("TTTRenderEntityInfo", "HUDDrawTargetIDArmorVest", function(tData)
        local client = LocalPlayer()
        local ent = tData:GetEntity()

        if
            not IsValid(client)
            or not client:IsTerror()
            or not client:Alive()
            or not IsValid(ent)
            or tData:GetEntityDistance() > 100
            or ent:GetClass() ~= "ent_armor_vest"
        then
            return
        end

        -- enable targetID rendering
        tData:EnableText()
        tData:EnableOutline()
        tData:SetOutlineColor(client:GetRoleColor())

        tData:SetTitle(TryT(ent.PrintName))
        tData:SetSubtitle("Press [E] to equip the armor vest.")

        tData:AddDescriptionLine("Armor reduces incoming damage. Unless you get headshot.")
		
		if client:GetArmor() > 0 then
            tData:AddDescriptionLine("You cannot wear more than 1 armor vest!", COLOR_RED)
        end
    end)
	
	-- handle drawing it on the player
	hook.Add("PostPlayerDraw", "DrawCustomVest", function(ply)
		local data = vestData[ply]
		if not data or not IsValid(data.model) then return end

		local boneID = ply:LookupBone("ValveBiped.Bip01_Spine2")
		if not boneID then return end

		local pos, ang = ply:GetBonePosition(boneID)
		ang:RotateAroundAxis(ang:Forward(), 90)
		ang:RotateAroundAxis(ang:Right(), -90)
		pos = pos - ang:Up() * 11 + ang:Forward() * 4

		local vest = data.model
		vest:SetRenderOrigin(pos)
		vest:SetRenderAngles(ang)
		vest:SetModelScale(1.25)
		vest:DrawModel()
	end)
end