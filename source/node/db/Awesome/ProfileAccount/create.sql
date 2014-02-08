CREATE TABLE `profile_account` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `profileId` int(11) NOT NULL,
  `type` varchar(45) NOT NULL DEFAULT 'local',
  `name` varchar(45) NOT NULL,
  `pass` varchar(40) NOT NULL,
  `enabledAt` timestamp NULL DEFAULT NULL,
  `updatedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_profile_identity` (`name`),
  UNIQUE KEY `u_profile_credential` (`name`,`pass`),
  KEY `i_profile_account_profileId` (`profileId`),
  CONSTRAINT `f_profile_account_profileId` FOREIGN KEY (`profileId`) REFERENCES `profile` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2701 DEFAULT CHARSET=utf8;

INSERT INTO `profile_account` (`id`, `profileId`, `type`, `name`, `pass`, `enabledAt`) VALUES

('1', '1', 'local', 'root', '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', NOW()),
('2', '1', 'local', 'admin', '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', NULL)

;
