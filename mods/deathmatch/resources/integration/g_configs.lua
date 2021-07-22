--MAXIME
mysql = exports.mysql
TESTER = 25
SCRIPTER = 32
LEADSCRIPTER = 79
COMMUNITYLEADER = 14
TRIALADMIN = 18
ADMIN = 17
SENIORADMIN = 64
LEADADMIN = 15
SUPPORTER = 30
VEHICLE_CONSULTATION_TEAM_LEADER = 39
VEHICLE_CONSULTATION_TEAM_MEMBER = 43
MAPPING_TEAM_LEADER = 44
MAPPING_TEAM_MEMBER = 28
STAFF_MEMBER = {32, 14, 18, 17, 64, 15, 30, 39, 43, 44, 28}
AUXILIARY_GROUPS = {32, 39, 43, 44, 28}
ADMIN_GROUPS = {14, 18, 17, 64, 15}

staffTitles = {
	[1] = {
		[0] = "Player",
		[1] = "Trial Administrator",
		[2] = "Administrator",
		[3] = "Senior Administrator",
		[4] = "Lead Administrator",
		[5] = "Head Administrator"
	}, 
	[2] = {
		[0] = "Player",
		[1] = "Supporter",
		[2] = "Supporter Manager",
	}, 
	[3] = {
		[0] = "Player",
		[1] = "VT Member",
		[2] = "VT Leader",
	}, 
	[4] = {
		[0] = "Player",
		[1] = "Script Tester",
		[2] = "Trial Scripter",
		[3] = "Scripter",
	}, 
	[5] = {
		[0] = "Player",
		[1] = "Mapper",
		[2] = "Lead Mapper",
	}, 
	[6] = {
		[0] = "Player",
		[1] = "FT Member",
		[2] = "FT Leader",
	}
}

function getStaffTitle(teamID, rankID) 
	return staffTitles[tonumber(teamID)][tonumber(rankID)]
end

function getStaffTitles()
	return staffTitles
end