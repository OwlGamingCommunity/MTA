-- metadata is a simple key/value store for items, allowing you to modify certain properties without changing how the
-- item behaves script-wise.

-- all properties you can reasonably expect to edit on all items (probably none).
-- g_items has more properties for specific items.
-- This should probably be empty.
-- default_metadata { item_name = { 'string', 'staff' } }
local default_metadata = { edited = { type = 'table', rank = 'no-one' } }

local function check(player, perm, edited)
	if perm == "staff" then
        return exports.integration:isPlayerTrialAdmin(player) or exports.integration:isPlayerSupporter(player) or exports.integration:isPlayerScripter(player)
    elseif perm == "player" then
        return getElementData(player, "loggedin") == 1
	elseif string.find(perm, ":once") then
		return check(player, gettok(perm, 1, string.byte(':'))) and not edited
    else
        return false
    end
end

function canOpenMetadataEditor(player, item)
    if not player or not item then
        return false
    elseif item then
        return #getEditableMetadataFor(player, item) > 0
    end
end

--- returns a table of all editable metadata
function getEditableMetadataFor(player, item)
	local item_id = item[1]
	local metadata = item[5]
    if not g_items[item_id] then return {} end

    local properties = {}

    for _, t in ipairs({default_metadata, g_items[item_id].metadata or {}}) do
        for name, data in pairs(t) do
			if metadata and not metadata['edited'] then metadata['edited'] = {} end
            if check(player, data.rank, metadata and metadata['edited'][name]) then
                local tmp = { name = name }
                for k, v in pairs(data) do
                    tmp[k] = v
                end

                table.insert(properties, tmp)
            end
        end
    end

    table.sort(properties, function(a, b) return a.name <= b.name end)

    return properties
end

--- returns information about the current item/metadata key combination
function getEditableMetadataInfo(player, item_id, key)
    for _, t in ipairs({default_metadata, g_items[item_id].metadata or {}}) do
        for name, data in pairs(t) do
            if name == key then
                if check(player, data.rank) then
                    return { type = data.type }
                end
            end
        end
    end
    return nil
end

function getStringForMetadataValue(item, def)
    -- do we actually have metadata?
    local value = item[5] and item[5][def.name] or nil
    if value ~= nil then
        if def.type == "string" or def.type == "integer" then
            return tostring(value)
        elseif def.type == "table" then
            return toJSON(value)
        else
            return "<unknown>"
        end
    end
    return ""
end
