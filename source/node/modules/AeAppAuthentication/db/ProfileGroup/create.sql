CREATE TABLE `profile_group` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `profileId` int(11) NOT NULL,
  `groupId` int(11) NOT NULL,
  `priority` int(11) NOT NULL DEFAULT '1',
  `enabledAt` timestamp NULL DEFAULT NULL,
  `updatedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `i_profile_group_profileId` (`profileId`),
  KEY `i_profile_group_groupId` (`groupId`),
  CONSTRAINT `f_profile_group_groupId` FOREIGN KEY (`groupId`) REFERENCES `profile` (`id`) ON DELETE CASCADE,
  CONSTRAINT `f_profile_group_profileId` FOREIGN KEY (`profileId`) REFERENCES `profile` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2701 DEFAULT CHARSET=utf8;

INSERT INTO `profile_group` (`id`, `profileId`, `groupId`, `enabledAt`) VALUES

('1', '1', '2', NOW()),
('2', '3', '4', NOW())

;
