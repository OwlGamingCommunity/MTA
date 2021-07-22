#!/bin/sh
set -e

# Make sure line endings are properly set

cd /home/mtasa/server/

# SET THE mtaserver.conf FROM mtaserver.conf.bak
cat ./mods/deathmatch/mtaserver.conf.bak \
    | sed "s/SERVER_IP/${SERVER_IP}/" \
    | sed "s/SHOULD_BROADCAST/${SHOULD_BROADCAST}/" \
    | sed "s/mta_mysql.dll/mta_mysql.so/" \
    | sed "s/bcrypt.dll/bcrypt.so/" \
    | sed "s/OWNER_EMAIL_ADDRESS/${OWNER_EMAIL_ADDRESS}/" \
    > ./mods/deathmatch/mtaserver.conf

# SET THE settings.xml FROM settings.xml.bak
cat ./mods/deathmatch/settings.xml.bak \
    | sed "s/PRODUCTION_SERVER/${PRODUCTION_SERVER}/" \
	| sed "s/MTA_DATABASE_NAME/${MTA_DATABASE_NAME}/" \
	| sed "s/MTA_DATABASE_USERNAME/${MTA_DATABASE_USERNAME}/" \
	| sed "s/MTA_DATABASE_PASSWORD/${MTA_DATABASE_PASSWORD}/" \
	| sed "s/MTA_DATABASE_HOST/${MTA_DATABASE_HOST}/" \
	| sed "s/MTA_DATABASE_PORT/${MTA_DATABASE_PORT}/" \
	| sed "s/CORE_DATABASE_NAME/${CORE_DATABASE_NAME}/" \
    | sed "s/CORE_DATABASE_USERNAME/${CORE_DATABASE_USERNAME}/" \
	| sed "s/CORE_DATABASE_PASSWORD/${CORE_DATABASE_PASSWORD}/" \
	| sed "s/CORE_DATABASE_HOST/${CORE_DATABASE_HOST}/" \
	| sed "s/CORE_DATABASE_PORT/${CORE_DATABASE_PORT}/" \
	| sed "s/FORUMS_API_KEY/${FORUMS_API_KEY}/" \
	| sed "s/IMGUR_API_KEY/${IMGUR_API_KEY}/" \
	| sed "s/WEBSITE_PASSWORD/${WEBSITE_PASSWORD}/" \
    > ./mods/deathmatch/settings.xml

# Move our modules to the right paths
if [ ! -d "./x64/modules" ]; then
	mv ./mods/deathmatch/modules/ ./x64/modules
	# Delete the conflicting linux lib
	# rm ./x64/linux-libs/libstdc++.so.6
	# apparently they don't include it anymore
fi

# Start mtasa server
exec ./mta-server64 -n -t -u

# The flags allow us to Cntrl+C or docker stop gracefully
# Details here: https://github.com/multitheftauto/mtasa-blue/blob/master/Server/launcher/Main.cpp