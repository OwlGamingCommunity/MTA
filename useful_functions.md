# Useful exported functions and techniques. #
## 1. Debugging [Server & Client] ##
* Quickly hide/show all outputDebugString() within a resource:
- Step 1: Copy "\resources\debug\debug_g.lua" to your resource folder.
- Step 2: Add the following to your resource's meta.xml

```
<script src="debug_g.lua" type="shared"/>
```
Now all outputDebugString() are hidden by default. To show them, simply use /debugres [Your Resource Name]

## 2. Set & Change Protected Element Data (Server only) ##
It's very important to have a correct understanding about element data because setting element data incorrectly (server side) may cause significant unnecessary lag.
```
exports.anticheat:setEld(element, index, value, sync) --Set new and protect an element data.

```
- element : The element you want to set data on.
- index : element data name.
- value : element data value.
- newvalue : new value of the existing element data you want to change to.
- sync = "one" : sync to server, and the element's client.
- sync = "all" : sync to server,  the element's client and all other clients in game.
- sync = "none" : element data existed in server side or client side only, depends on where you call this function.

Calling function client side: Mostly you won't need to protect client side element data, so built in setElementData() is enough. Otherwise, use it with care.

## 3. Get element from ID without looping [Server-only] ##

This is extremely useful and necessary. Because you will have to get element from dbid a lot during scripting. And by using this instead of loop through getElementsByType() will significantly reduce the stress.

Only works server-side, client-side will be supported soon.

Syntax:
```
element exports.pool:getElement(string theType, int id )
```
Required Arguments:

- theType: The type of element you want to get: "player", "ped", "vehicle", "interior", "elevator", "object", "pickup", "marker", "colshape", "blip", "team"
- id: id of the element you want to get.

Others
```
table exports.pool:getPoolElementsByType(string theType)
/poolsize
```

## 4. Restarting your resource without losing data [Server-only] ##
Syntax:
```
bool exports.data:save(mixed data, string accessKey)
mixed exports.data:load(string accessKey)
```
- data : The data you want to save and load, it supports all kinds of data.
- accessKey : A string that is used as a key variable to save data as and then load the data from.

For many reasons you don't want to lose the data being processed within your resource. For example, a table of reports in report-system.
To achieve this goal, add 2 events on resource start and stop to save and load data:
```
local processingData = {"stuff", "nothing" } --Assuming this is the data you don't want to lose when resource restart.

function resourceStop()
	exports.data:save(processingData, "myData1")
end
addEventHandler("onResourceStop", resourceRoot, resourceStop)

function resourceStart()
	processingData= exports.data:load("myData1")
end
addEventHandler("onResourceStart", resourceRoot, resourceStart)
```

## 5. Money and banking  ##
# Banking functions #
```
bool exports.bank:hasBankMoney(element theElement, int amount)
bool exports.bank:takeBankMoney(element theElement, int amount)
bool exports.bank:giveBankMoney(element theElement, int amount)
bool exports.bank:setBankMoney(element theElement, int amount)
```
- theElement : player element or faction element.
- amount: a positive integer amount of money
```
bool exports.bank:addBankTransactionLog(int fromAccount, int toAccount, int amount, int type, [ string reason,string details,string fromCard,string toCard] )
```
- fromAccount and toAccount is negative if it's a faction id, and positive for character id.
- amount is always a positive number.
- type:
    0: Withdraw Personal
    1: Deposit Personal
    2: Transfer from Personal to Personal/Business
    3: Transfer from Business to Personal/Business
    4: Withdraw Business
    5: Deposit Business
    6: Wage/State Benefits
    7: everything in payday except Wage/State Benefits
    8: faction budget
    9: fuel
    10: repair


## 5. Useful GUI exported functions [Client-only] ##
Screen centralizing a GUI element (Works for all kinds of GUI elements) :
```
exports.global:centerWindow(element guiElement)
```
Adjust combobox height
```
exports.global:guiComboBoxAdjustHeight(element combobox, int lines)
```
