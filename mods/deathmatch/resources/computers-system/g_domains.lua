local domains = {
	-- domains that exist locally only
	{ fake = 'mdc.gov' },
	{ fake = 'bankofsa.sa', fn = function() triggerServerEvent("computers:onlineBanking", localPlayer) end },
	{ fake = 'ippc.sa' },
	{ fake = 'faa.gov', fn = function() triggerEvent("faa:maingui", localPlayer) end },
	{ fake = 'investplace.net', fn = function() triggerServerEvent("invest:open", localPlayer, localPlayer) end },

	-- real domains translated to fake *.sa addresses
	{ fake = 'google.sa', real = 'google.com', ssl = true, query = '/ncr' },
	{ fake = 'linkbook.sa', real = 'linkbook.thomaspwn.com' },
	{ fake = 'findbook.sa', real = 'findbook.owlgaming.net' },
	{ fake = 'youtube.sa', real = 'youtube.com', query = '/tv', append_query_only_on_fake_url = true, ssl = true },
}

function getDomainInformation(domain)
	local domain = domain:gsub("www.", ""):lower()
	for _, info in ipairs(domains) do
		if info.fake == domain or info.real == domain then
			return info
		end
	end
	return nil
end

-- we're using this list to allow wildcard requests for domains, for example visiting forums.owlgaming.net would ask for permission to visit 'owlgaming.net'
-- this list is not complete, and likely will never be.
-- do NOT add .uk or any zones with possible second-level domains here, this should be handled with extra logic (both .co.uk and .uk could be valid, but allowing *.co.uk is a mistake)
local simple_top_level_domains = {'com', 'org', 'net', 'eu', 'me', 'info', 'biz'}
function getDomainForRequestingWhitelist(domain)
	local s = split(domain, '.')
	if #s < 2 then
		return domain
	end

	for _, name in ipairs(simple_top_level_domains) do
		if s[#s] == name then
			return s[#s-1] .. "." .. name
		end
	end
	return domain
end

local blocked_domains = {'.sa', '.ls', '.gov', 'doubleclick.net'}
function isBlockedDomain(domain)
	if #domain <= 2 then
		return false
	end

	for _, d in ipairs(blocked_domains) do
		if domain:sub(#domain - #d + 1, #domain) == d then
			return true
		end
	end
	return false
end
