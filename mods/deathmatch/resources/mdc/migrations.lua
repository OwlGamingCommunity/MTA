local migrations = {
    "alter table mdc_criminals modify details text default \"None.\";",
}
addEventHandler('onResourceStart', resourceRoot,
    function ()
        exports.mysql:createMigrations(getResourceName(getThisResource()), migrations)
    end
)
