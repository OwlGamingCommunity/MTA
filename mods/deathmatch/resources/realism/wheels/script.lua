info = { 
["wheels/wheel_gn1.dff"] = 1082,
["wheels/wheel_gn2.dff"] = 1085,
["wheels/wheel_gn3.dff"] = 1096,
["wheels/wheel_gn4.dff"] = 1097,
["wheels/wheel_gn5.dff"] = 1098,
["wheels/wheel_lr1.dff"] = 1077,
["wheels/wheel_lr2.dff"] = 1083,
["wheels/wheel_lr3.dff"] = 1078,
["wheels/wheel_lr4.dff"] = 1076,
["wheels/wheel_lr5.dff"] = 1084,
["wheels/wheel_or1.dff"] = 1025,
["wheels/wheel_sr1.dff"] = 1079,
["wheels/wheel_sr2.dff"] = 1075,
["wheels/wheel_sr3.dff"] = 1074,
["wheels/wheel_sr4.dff"] = 1081,
["wheels/wheel_sr5.dff"] = 1080,
["wheels/wheel_sr6.dff"] = 1073,
      }

addEvent("vehicle_rims", true)
addEventHandler('vehicle_rims', root,
    function(value)
      if getElementData(getLocalPlayer(), "vehicle_rims") == "0" then 
            if value == "0" then
                  for k,v in pairs(info) do
                        engineRestoreModel(v)
                  end
            end
            return false
      end
      for k,v in pairs(info) do
            downloadFile(k)
      end
    end
)

addEventHandler("onClientFileDownloadComplete", resourceRoot,
 function(file, success)
      if success then
            dff = engineLoadDFF ( file, info[file])
            engineReplaceModel ( dff, info[file])
      end
 end )
