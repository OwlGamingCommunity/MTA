ALTER TABLE `owl_mta`.`factions` 
ADD COLUMN `free_custom_ints` TINYINT(1) UNSIGNED NULL DEFAULT 0 COMMENT '' AFTER `max_interiors`,
ADD COLUMN `free_custom_skins` TINYINT(1) UNSIGNED NULL DEFAULT 0 COMMENT '' AFTER `free_custom_ints`;

ALTER TABLE `owl_mta`.`factions` 
CHANGE COLUMN `max_interiors` `max_interiors` INT(11) UNSIGNED NOT NULL DEFAULT '20' COMMENT '' ,
ADD COLUMN `max_vehicles` INT(11) UNSIGNED NOT NULL DEFAULT 40 COMMENT '' AFTER `max_interiors`;

