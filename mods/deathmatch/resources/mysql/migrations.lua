--[[
	Migrations allow resources to specify MySQL alterations that they wish to only run once.
	This will allow for developers on different databases to stay up to date with the latest
	changes that others have made.
]]

function createMigrationsTable()
	local db = getConn()
	local query = [[
	CREATE TABLE IF NOT EXISTS `migrations` (
	  `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	  `resource` VARCHAR(45) NULL,
	  `migration` INT NULL,
	  UNIQUE INDEX `UNIQUE` (`resource` ASC, `migration` ASC));
	]]
	db:exec(query)
end

local function buildMigrations(query, resource, migrations)
	local db = getConn()
	local result = query:poll(0)
	for migrationIndex, migration in ipairs(migrations) do
		if migrationIndex > #result then
			db:exec(migration)
			outputServerLog('[ Migration ] ' .. resource .. ': ' .. tostring(migrationIndex))
			db:exec('INSERT INTO `migrations` (`resource`, `migration`) VALUES (?, ?)', resource, migrationIndex)
		end
	end
end

--[[
	createMigrations
	params:
		(string) resource - the name of the resource the migration applies to.
		(array) migrations - the array of migrations to be applied.
]]
function createMigrations(resource, migrations)
	local db = getConn()
	db:query(buildMigrations, { resource, migrations }, "SELECT `migration` FROM `migrations` WHERE `resource` = ?", resource)
end