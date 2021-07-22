--Client-side script: Taximeter
--Created by Exciter, anumaz, 04.05.2014
--Last updated 05.05.2014 by Exciter
--Released as open source. This header should remain intact. Otherwise no use restrictions.

-- configuration
taxiModels = {[420]=true, [438]=true} -- Vehicle models
defaultfare = 21 -- Default taxi fare
syncInterval = 30000 --ms
minFare, maxFare = 15, 30