function showPedNametag(ped)
	if(getElementData(ped, "rpp.npc.nametag") == "true") then
		return true
	else
		return false
	end
end
function getPedName(ped)
	return getElementData(ped, "rpp.npc.name")
end

function getRandomName(type, gender) --type: "first","last","full","gender" or nil. gender: "male","female" or nil.
	local genders = {
	"male",
	"female"
	}	
	local males = {
	"John",
	"Will",
	"Jacob",
	"Henry",
	"Oliver",
	"Adam",
	"Christian",
	"Chris",
	"Christopher",
	"Michael",
	"Mike",
	"Joe",
	"Aaron",
	"Ethan",
	"Noah",
	"Lucas",
	"Lukas",
	"Gabriel",
	"Owen",
	"Jack",
	"Dorian",
	"James",
	"Colin",
	"Luke",
	"Daniel",
	"Evan",
	"Seth",
	"Jason",
	"David",
	"Thomas",
	"Justin",
	"Jasper",
	"Alex",
	"Alexander",
	"William"
	}	
	local females = {
	"Rebecca",
	"Eva",
	"Emma",
	"Olivia",
	"Lilly",
	"Sophie",
	"Chloe",
	"Hannah",
	"Emily",
	"Claire",
	"Belle",
	"Natalie",
	"Page",
	"Mia",
	"Leah",
	"Gabriella",
	"Zoe",
	"Kylie",
	"Samantha",
	"Alex",
	"Alexis",
	"Catherine",
	"Cathy",
	"Faith",
	"Victoria",
	"Lillian",
	"Brooke",
	"Julia",
	"Alice",
	"Caroline",
	"Allison",
	"Amy",
	"Dolly",
	"Juliet",
	"Ashley",
	"Amber",
	"Kate",
	"Katie",
	"Mary",
	"Evelyn",
	"Pamela",
	"Jaqueline",
	"Elliot"
	}	
	local lastnames = {
	"Goldsmith",
	"Carter",
	"Cooper",
	"Ford",
	"Montana",
	"Hut",
	"Willson",
	"Smith",
	"Johnson",
	"Jones",
	"Williams",
	"Brown",
	"Davis",
	"Miller",
	"Wilson",
	"Moore",
	"Taylor",
	"Anderson",
	"Jackson",
	"Harris",
	"Thompson",
	"Martinez",
	"Rodriguez",
	"Lewis",
	"Lee",
	"Walker",
	"Hall",
	"Allen",
	"Young",
	"Hernandez",
	"Jimenez",
	"Nilson",
	"Adams",
	"Baker",
	"Turner",
	"Reed",
	"Bell",
	"Cox",
	"Howard",
	"Watson",
	"Brooks",
	"Jenkins",
	"Foster",
	"Butler",
	"Diaz",
	"West",
	"Fisher",
	"Hunter",
	"Stevens",
	"Tucker",
	"Daniels",
	"Porter",
	"Rice",
	"Burns",
	"Black",
	"White",
	"Crawford",
	"Robinson"
	}	
	if not type then
		type = "full"
	end
	if(type == "full") then
		if not gender then
			gender = genders[math.random(table.getn(genders))]
		end
		local randFirstname
		if(gender == "male") then
			randFirstname = males[math.random(table.getn(males))]
		elseif(gender == "female") then
			randFirstname = females[math.random(table.getn(females))]
		end
		local randLastname = lastnames[math.random(table.getn(lastnames))]
		local name = tostring(randFirstname.." "..randLastname)
		return name
	elseif(type == "last") then
		local randLastname = lastnames[math.random(table.getn(lastnames))]
		return randLastname
	elseif(type == "first") then
		if not gender then
			gender = genders[math.random(table.getn(genders))]
		end
		local randFirstname
		if(gender == "male") then
			randFirstname = males[math.random(table.getn(males))]
		elseif(gender == "female") then
			randFirstname = females[math.random(table.getn(females))]
		end
		return randFirstname
	elseif(type == "gender") then
		gender = genders[math.random(table.getn(genders))]
		return gender
	end
end