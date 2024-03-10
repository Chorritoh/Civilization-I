-- Asumiendo que tienes un modelo de NPC de mujer en ReplicatedStorage.Humans.Models
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NPCModel = ReplicatedStorage.Humans.Models.Women -- reemplaza esto con la ruta al modelo de tu NPC
local NameGenerator = require(game.ServerScriptService.Civilians.NameGenerator)

-- Asumiendo que tienes una carpeta llamada "Spawners" en Workspace con Partes dentro
local Workspace = game:GetService("Workspace")
local Spawners = Workspace.Spawners
local SpawnerParts = Spawners:GetChildren()

-- Asumiendo que tienes una carpeta llamada "Humans" en Workspace donde se colocarán los NPCs clonados
local Humans = Workspace.Humans

-- Número de NPCs a generar
local npcsAGenerar = 2

-- Servicio Http para generar UUIDs
local HttpService = game:GetService("HttpService")

-- Servicio DataStore para guardar y cargar datos de NPCs
local DataStoreService = game:GetService("DataStoreService")
local CiviliansDS = DataStoreService:GetDataStore("CiviliansDS")

wait(0.1)
-- Función para generar un color de pelo aleatorio
local function generateHairColor()
	local randomNumber = math.random()
	if randomNumber <= 0.5 then
		return "Brown"
	elseif randomNumber <= 0.8 then
		return "Black"
	else
		return "Blonde"
	end
end

-- Función para clonar el NPC en una posición aleatoria
local function spawnNPC()
	for i = 1, npcsAGenerar do
		-- Seleccionar un Spawner aleatorio
		local randomIndex = math.random(#SpawnerParts)
		local randomSpawner = SpawnerParts[randomIndex]

		-- Clonar el NPC y colocarlo en la posición del Spawner
		local clonedNPC = NPCModel:Clone()
		clonedNPC.Parent = Humans
		clonedNPC.PrimaryPart.CFrame = randomSpawner.CFrame

		-- Generar un UUID y asignarlo al NPC
		local uuid = HttpService:GenerateGUID(false) -- genera un UUID sin llaves
		clonedNPC.Configuration.ID.Value = uuid

		-- Verificar si la ID ya existe en la DataStore
		local existingData = CiviliansDS:GetAsync(uuid)
		if existingData then
			-- Si la ID ya existe, usar los datos existentes
			clonedNPC.Configuration.HairColor.Value = existingData.hairColor
			clonedNPC.Configuration:WaitForChild("Name").Value = existingData.name
			clonedNPC.Configuration.Age.Value = existingData.age
		else
			-- Si la ID no existe, generar nuevos datos y guardarlos en la DataStore
			local hairColor = generateHairColor()
			clonedNPC.Configuration.HairColor.Value = hairColor

			-- Seleccionar un pelo aleatorio del color correspondiente y asignarlo al NPC
			local hairOptions = ReplicatedStorage.Humans.Appearance.Hair[clonedNPC.Configuration.Gender.Value][hairColor]:GetChildren()
			local randomHair = hairOptions[math.random(#hairOptions)]
			randomHair:Clone().Parent = clonedNPC

			-- Generar un nombre completo y asignarlo al NPC
			local nombreCompleto = NameGenerator:GenerarNombreCompleto(clonedNPC.Configuration.Gender.Value)
			clonedNPC.Configuration:WaitForChild("Name").Value = nombreCompleto

			-- Cambiar el nombre del modelo del NPC clonado al nombre que sale en el configuration
			clonedNPC.Name = nombreCompleto

			-- Generar una edad aleatoria entre 18 y 28 años y asignarla al NPC
			clonedNPC.Configuration.Age.Value = math.random(18, 28)

			-- Guardar los datos en la DataStore
			local dataToSave = {
				hairColor = hairColor,
				name = nombreCompleto,
				age = clonedNPC.Configuration.Age.Value
			}
			CiviliansDS:SetAsync(uuid, dataToSave)
		end
	end
end

-- Función para generar un NPC con una ID específica
local function spawnNPCWithID(id)
	-- Seleccionar un Spawner aleatorio
	local randomIndex = math.random(#SpawnerParts)
	local randomSpawner = SpawnerParts[randomIndex]

	-- Clonar el NPC y colocarlo en la posición del Spawner
	local clonedNPC = NPCModel:Clone()
	clonedNPC.Parent = Humans
	clonedNPC.PrimaryPart.CFrame = randomSpawner.CFrame

	-- Asignar la ID al NPC
	clonedNPC.Configuration.ID.Value = id

	-- Verificar si la ID ya existe en la DataStore
	local existingData = CiviliansDS:GetAsync(id)
	if existingData then
		-- Si la ID ya existe, usar los datos existentes
		clonedNPC.Configuration.HairColor.Value = existingData.hairColor
		clonedNPC.Configuration:WaitForChild("Name").Value = existingData.name
		clonedNPC.Configuration.Age.Value = existingData.age
	else
		-- Si la ID no existe, generar nuevos datos y guardarlos en la DataStore
		local hairColor = generateHairColor()
		clonedNPC.Configuration.HairColor.Value = hairColor

		-- Seleccionar un pelo aleatorio del color correspondiente y asignarlo al NPC
		local hairOptions = ReplicatedStorage.Humans.Appearance.Hair[clonedNPC.Configuration.Gender.Value][hairColor]:GetChildren()
		local randomHair = hairOptions[math.random(#hairOptions)]
		randomHair:Clone().Parent = clonedNPC

		-- Generar un nombre completo y asignarlo al NPC
		local nombreCompleto = NameGenerator:GenerarNombreCompleto(clonedNPC.Configuration.Gender.Value)
		clonedNPC.Configuration:WaitForChild("Name").Value = nombreCompleto

		-- Cambiar el nombre del modelo del NPC clonado al nombre que sale en el configuration
		clonedNPC.Name = nombreCompleto

		-- Generar una edad aleatoria entre 18 y 28 años y asignarla al NPC
		clonedNPC.Configuration.Age.Value = math.random(18, 28)

		-- Guardar los datos en la DataStore
		local dataToSave = {
			hairColor = hairColor,
			name = nombreCompleto,
			age = clonedNPC.Configuration.Age.Value
		}
		CiviliansDS:SetAsync(id, dataToSave)
	end
end

-- Llamar a la función para probarla
spawnNPC()
