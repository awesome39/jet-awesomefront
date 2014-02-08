CREATE TABLE `profile_account_github` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `profileId` int(11) NOT NULL,
  `providerId` int(11) NOT NULL,
  `providerName` varchar(255) NOT NULL,
  `enabledAt` timestamp NULL DEFAULT NULL,
  `updatedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_profile_account_github_providerId` (`providerId`),
  UNIQUE KEY `u_profile_account_github_providerName` (`providerName`),
  KEY `i_profile_account_github_profileId` (`profileId`),
  CONSTRAINT `f_profile_account_github_profileId` FOREIGN KEY (`profileId`) REFERENCES `profile` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2701 DEFAULT CHARSET=utf8;

INSERT INTO `profile_account_github` (`id`, `profileId`, `providerId`, `providerName`, `enabledAt`) VALUES

('7', '1', '386459', 'tehfreak', NOW())

;
