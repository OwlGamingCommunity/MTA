skinsMale = {7,14,15,17,20,21,24,25,26,29,35,36,37,44,46,57,58,59,60,68,72,98,147,185,186,187,223,227,228,234,235,240,258,259}
skinsFemale = {9,11,12,40,41,55,56,69,76,88,89,91,93,129,130,141,148,150,151,190,191,192,193,194,196,211,215,216,219,224,225,226,233,263}

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

function getRandomSkin(gender)
	if gender then
		if(gender == 0) then
			return skinsMale[math.random(#skinsMale)]
		elseif(gender == 1) then
			return skinsFemale[math.random(#skinsFemale)]
		end
	end
	return false
end

function getRandomName(type, gender) --type: "first","last","full","gender" or nil. gender: "male","female" or nil.
	--outputDebugString("getting random name.. ("..tostring(type)..", "..tostring(gender)..")")	
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
	
	if gender then
		if(gender == 0) then
			gender = "male"
		elseif(gender == 1) then
			gender = "female"
		end
	end
	
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
		--outputDebugString("result: "..tostring(name))
		return name
	elseif(type == "last") then
		local randLastname = lastnames[math.random(table.getn(lastnames))]
		--outputDebugString("result: "..tostring(randLastname))
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
		--outputDebugString("result: "..tostring(randFirstname))
		return randFirstname
	elseif(type == "gender") then
		gender = genders[math.random(table.getn(genders))]
		if(gender == "male") then
			return 0
		elseif(gender == "female") then
			return 1
		end
	end
end

skinGenders = {[0]=0,[1]=0,[2]=0,[7]=0,[14]=0,[15]=0,[16]=0,[17]=0,[18]=0,[19]=0,[20]=0,[21]=0,[22]=0,[23]=0,[24]=0,[25]=0,[26]=0,[27]=0,[28]=0,[29]=0,[30]=0,[32]=0,[33]=0,[34]=0,[35]=0,[36]=0,[37]=0,[43]=0,[44]=0,[45]=0,[46]=0,[47]=0,[48]=0,[49]=0,[50]=0,[51]=0,[52]=0,[57]=0,[58]=0,[59]=0,[60]=0,[61]=0,[62]=0,[66]=0,[67]=0,[68]=0,[70]=0,[71]=0,[72]=0,[73]=0,[78]=0,[79]=0,[80]=0,[81]=0,[82]=0,[83]=0,[84]=0,[94]=0,[95]=0,[96]=0,[97]=0,[98]=0,[99]=0,[100]=0,[101]=0,[102]=0,[103]=0,[104]=0,[105]=0,[106]=0,[107]=0,[108]=0,[109]=0,[110]=0,[111]=0,[112]=0,[113]=0,[114]=0,[115]=0,[116]=0,[117]=0,[118]=0,[120]=0,[121]=0,[122]=0,[123]=0,[124]=0,[125]=0,[126]=0,[127]=0,[128]=0,[132]=0,[133]=0,[134]=0,[135]=0,[136]=0,[137]=0,[142]=0,[143]=0,[144]=0,[146]=0,[147]=0,[153]=0,[154]=0,[155]=0,[156]=0,[158]=0,[159]=0,[160]=0,[161]=0,[162]=0,[163]=0,[164]=0,[165]=0,[166]=0,[167]=0,[168]=0,[170]=0,[171]=0,[173]=0,[174]=0,[175]=0,[176]=0,[177]=0,[179]=0,[180]=0,[181]=0,[182]=0,[183]=0,[184]=0,[185]=0,[186]=0,[187]=0,[188]=0,[189]=0,[200]=0,[202]=0,[203]=0,[204]=0,[206]=0,[209]=0,[210]=0,[212]=0,[213]=0,[217]=0,[220]=0,[221]=0,[222]=0,[223]=0,[227]=0,[228]=0,[229]=0,[230]=0,[234]=0,[235]=0,[236]=0,[240]=0,[241]=0,[242]=0,[247]=0,[248]=0,[249]=0,[250]=0,[252]=0,[253]=0,[254]=0,[255]=0,[258]=0,[259]=0,[260]=0,[261]=0,[262]=0,[264]=0,[265]=0,[266]=0,[267]=0,[268]=0,[269]=0,[270]=0,[271]=0,[272]=0,[274]=0,[275]=0,[276]=0,[277]=0,[278]=0,[279]=0,[280]=0,[281]=0,[282]=0,[283]=0,[284]=0,[285]=0,[286]=0,[287]=0,[288]=0,[290]=0,[291]=0,[292]=0,[293]=0,[294]=0,[295]=0,[296]=0,[297]=0,[299]=0,[300]=0,[301]=0,[302]=0,[303]=0,[305]=0,[306]=0,[307]=0,[308]=0,[309]=0,[310]=0,[311]=0,[312]=0,[9]=1,[10]=1,[11]=1,[12]=1,[13]=1,[31]=1,[38]=1,[39]=1,[40]=1,[41]=1,[53]=1,[54]=1,[55]=1,[56]=1,[63]=1,[64]=1,[69]=1,[75]=1,[76]=1,[77]=1,[85]=1,[87]=1,[88]=1,[89]=1,[90]=1,[91]=1,[92]=1,[93]=1,[129]=1,[130]=1,[131]=1,[138]=1,[139]=1,[140]=1,[141]=1,[145]=1,[148]=1,[150]=1,[151]=1,[152]=1,[157]=1,[169]=1,[172]=1,[178]=1,[190]=1,[191]=1,[192]=1,[193]=1,[194]=1,[195]=1,[196]=1,[197]=1,[198]=1,[199]=1,[201]=1,[205]=1,[207]=1,[211]=1,[214]=1,[215]=1,[216]=1,[218]=1,[219]=1,[224]=1,[225]=1,[226]=1,[231]=1,[232]=1,[233]=1,[237]=1,[238]=1,[243]=1,[244]=1,[245]=1,[246]=1,[251]=1,[256]=1,[257]=1,[263]=1,[298]=1,[304]=1}
function getGenderFromSkin(skin)
	skin = tonumber(skin) or false
	if not skin then return false end
	return skinGenders[skin] or false
end
function getSkinGender(skin)
	skin = tonumber(skin) or false
	if not skin then return false end
	return skinGenders[skin] or false
end