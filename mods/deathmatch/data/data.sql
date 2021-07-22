-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               10.1.28-MariaDB-1~stretch - mariadb.org binary distribution
-- Server OS:                    debian-linux-gnu
-- HeidiSQL Version:             9.4.0.5174
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- Dumping database structure for mta
CREATE DATABASE IF NOT EXISTS `core` /*!40100 DEFAULT CHARACTER SET latin1 */;

CREATE DATABASE IF NOT EXISTS `mta` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `mta`;

-- Dumping structure for table mta.settings
CREATE TABLE IF NOT EXISTS `settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` text,
  `value` text,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=10 DEFAULT CHARSET=latin1;

-- Dumping data for table mta.settings: 7 rows
/*!40000 ALTER TABLE `settings` DISABLE KEYS */;
REPLACE INTO `settings` (`id`, `name`, `value`) VALUES
	(1, 'tax', '5'),
	(2, 'incometax', '10'),
	(5, 'pdcodes', 'Radio Codes:\r\n10-1: Roll Call, all units respond to said location.\r\n10-2: Arrived on scene.\r\n10-3: Negative / No\r\n10-4: Acknowledgement / Affirmative / Yes\r\n10-5: Repeat last transmission\r\n10-6: Stand-by\r\n10-7: Unavailable for calls\r\n10-8: Available for calls\r\n10-9: Suspect Lost (Usually followed by a 10-17)\r\n10-10: Activity update along with giving your current position\r\n10-12: Backup Required (Specify situation and location)\r\n10-13: Requesting Speciality unit(specify: To SAM, EDWARD, HENRY, TOM, X-RAY, Towtruck, DFT) \r\n10-14: Requesting Medical Unit\r\n10-17: Requesting description on the suspect\r\n10-18: Requesting MDC check (on First-name Last-name)\r\n10-19: Response to MDC (On a 10-18)\r\n10-20: Requesting Location\r\n10-22: Disregard last transmission\r\n10-30: Starting Patrol/Resuming patrol after Code 7\r\n10-31: Returning to Station\r\n10-33: Officer in distress (Use when not able to use backup COMMS i.e; "Lincoln 1 to COMMS, Going 10-33 for a meal break.")\r\n10-50: Car accident\r\n10-55: Traffic Stop\r\n10-56: Speed Trap\n10-57 Victor: Vehicle pursuit.\r\n10-57 Foxtrot: Foot pursuit.\r\n10-66: Felony Stop\r\n10-88 Suspicious Person(s)\r\n10-99: Assignment complete (State condition and at what call)\r\n\r\n11-98: Emergency at Office\r\n11-99: Officer Down\n\r\n\r\nStatus-codes:\r\nStatus 1: Starting tour of Duty.\r\nStatus 2: Ending tour of Duty.\r\n\r\nIdentity Codes:\r\nIC-1: White\r\nIC-2: Black\r\nIC-3: Latino or Mexican\r\nIC-4: Middle-Eastern\r\nIC-5: Asian\r\nIC-6: Unknown ethnicity.\r\n\r\n\r\nSituation codes:\r\nCode 0: Absolute emergency. Drop everything you have and respond.\nCode 1: Non-emergency. If you\'re doing something, deal with it first. Respond without lights or sirens.\r\nCode 2: Non-emergency. If you\'re doing something, drop it and respond. Respond with lights only.\r\nCode 3: There is an emergency. Respond with lights and sirens.\r\nCode 4: No assistance required, situation under control.\r\nCode 5: All units stay out of <location>.\r\nCode 6: Out of car at <location>.\r\nCode 7: Break, specify if available for calls or not.\r\n\r\n\r\nCriminal Codes:\r\n148: Resisting Arrest \r\n187: Homicide\r\n192: Manslaughter\r\n207: Kidnapping\r\n211: Robbery\r\n240: Assault\r\n242: Battery\r\n245: Assault W/Deadly Weapon\r\n417: Brandishing a weapon\r\n459: Burglary\r\n487: Grand Theft (Exceeding $400)\r\n487: Petty Theft\r\n602: Trespass/Fraud\n\n\nSECTOR ASSIGNMENTS\r\n01 - CENTRAL BUREAU;\r\n02 - NORTH-WEST BUREAU;\r\n03 - DETECTIVE BUREAU;\r\n04 - SPECIAL OPERATIONS DIVISION;\r\n05 - SUPERVISOR - SUPERVISORY STAFF;\r\n06 - SUPERVISOR - COMMAND STAFF;\r\n07- SUPERVISOR - EXECUTIVE STAFF;\n\n\nUNIT TYPES\r\nADAM (A): Partnered patrol unit;\r\nAIR: Helicopter unit;\r\nBOY (B): Bicycle patrol unit;\r\nCHARLIE (C): Crime Suppression Unit;\nDAVID (D): Special Weapons and Tactics;\r\nFRANK (F): Footbeat patrol unit;\r\nGEORGE (G): Partnered detective unit.\r\nHENRY (H): Single detective unit;\r\nLINCOLN (L): Single deputy patrol unit;\r\nMARINE: Boat patrol unit;\r\nMARY (M): Motorcycle patrol unit;\r\nPETER (P): Partnered "LINCOLN" units;\r\nTOM (T): Marked Traffic Unit;\r\nUNION (U): Unmarked Traffic Unit;\r\nWILLIAM (W): High-Speed Interception Unit;\n\n\nPhonetics:\r\nA: Adam\r\nB: Boy\r\nC: Charlie\r\nD: David\r\nE: Edward\r\nF: Frank\r\nG: George\r\nH: Henry\r\nI: Ida\r\nJ: John\r\nK: King\r\nL: Lincoln\r\nM: Mary\r\nN: Nora\r\nO: Ocean\r\nP: Paul\r\nQ: Queen\r\nR: Robert\r\nS: Sam\r\nT: Tom\r\nU: Union\r\nV: Victor\r\nW: William\r\nX: X-Ray\r\nY: Young\r\nZ: Zebra\r\n\r\nSlang:\r\nAPB: All points bulletin\r\nBOLO: Be on look out\r\nCOMMS: Communications\r\nDOA: Dead on arrival \r\nDOB: Date of birth\r\nDWI: Driving while intoxicated \r\nETA: Estimative Time of Arrival\r\nGOV: Government of Los Santos\r\nGSW: Gun shot wound\r\nHQ: Headquarters \r\nHzM: HazMat\r\nKIA: Killed in Action\r\nLSFD: Los Santos Fire Department\r\nLSIA: Los Santos International Airport\r\nLSPD: Los Santos Police Department\r\nMHD: Mental Health Division\r\nMVA: Motor-Vehicle Accident \r\nNiner: 9-1-1 call\r\nOCI: Office of Criminal Intelligence\r\nRO: registered owner\r\nSAR: Search and Rescue\r\nTC: Traffic Collision\r\n5150: Possible mental case (IE: a troll, a person refusing to RP, a noob.)\n'),
	(6, 'pdprocedures', 'It\'s lonely here or content is out of date. \n\nPlease refresh..\n'),
	(7, 'welfare', '200'),
	(8, 'lottery', '0'),
	(9, 'lotteryNumber', '13');
/*!40000 ALTER TABLE `settings` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
