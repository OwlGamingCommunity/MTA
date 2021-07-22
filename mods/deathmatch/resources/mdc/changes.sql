Installation:

1. Run SQL to create new db table for usergroup permissions:

DROP TABLE IF EXISTS `mdc_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mdc_groups` (
  `faction_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `haveMdcInAllVehicles` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `canSeeWarrants` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `canSeeCalls` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `canAddAPB` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `canSeeVehicles` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `canSeeProperties` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `canSeeLicenses` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `canSeePilotStuff` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `impound_can_see` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `settingUsernameFormat` tinyint(1) unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`faction_id`),
  UNIQUE KEY `name_UNIQUE` (`name`),
  UNIQUE KEY `faction_id_UNIQUE` (`faction_id`),
  KEY `idx_idx` (`faction_id`)
) ENGINE=InnoDB AUTO_INCREMENT=60 DEFAULT CHARSET=utf8 COMMENT='User group''s permissions based on factions.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mdc_groups`
--

LOCK TABLES `mdc_groups` WRITE;
/*!40000 ALTER TABLE `mdc_groups` DISABLE KEYS */;
INSERT INTO `mdc_groups` VALUES (1,'LSPD',1,1,1,1,1,1,1,0,1,2),(2,'LSES',0,1,1,0,0,1,0,0,0,1),(3,'LS GOV',0,1,0,1,1,1,0,0,0,1),(4,'Rapid Towing',0,0,0,0,0,0,0,0,1,1),(47,'FAA',0,1,0,1,1,0,0,1,0,1),(50,'SCoSA',0,1,1,1,1,1,1,1,1,2),(59,'SAHP',1,1,1,1,1,1,1,1,1,2);
/*!40000 ALTER TABLE `mdc_groups` ENABLE KEYS */;
UNLOCK TABLES;

2. Execute /convertmdcaccounts

3. Execute /removeduplicatedaccounts

4. Run SQL to change database structure.
DELETE FROM `owl_mta`.`mdc_users` WHERE `organization`='DOC' and id > 0;
ALTER TABLE `owl_mta`.`mdc_users` 
CHANGE COLUMN `id` `id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '' ,
CHANGE COLUMN `charid` `charid` INT(11) UNSIGNED NOT NULL COMMENT '' ,
CHANGE COLUMN `level` `level` INT(11) UNSIGNED NOT NULL COMMENT '' ,
CHANGE COLUMN `organization` `organization` INT(11) UNSIGNED NOT NULL COMMENT '' ;
