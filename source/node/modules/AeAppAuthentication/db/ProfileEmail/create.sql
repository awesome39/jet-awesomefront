CREATE TABLE `profile_email` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `profileId` int(11) NOT NULL,
  `value` varchar(255) NOT NULL,
  `verifiedAt` timestamp NULL DEFAULT NULL,
  `enabledAt` timestamp NULL DEFAULT NULL,
  `updatedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_profile_email` (`value`),
  KEY `i_profile_email_profileId` (`profileId`),
  CONSTRAINT `f_profile_email_profileId` FOREIGN KEY (`profileId`) REFERENCES `profile` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2701 DEFAULT CHARSET=utf8;

INSERT INTO `profile_email` (`id`, `profileId`, `value`, `verifiedAt`, `enabledAt`) VALUES

('1', '1', 'root@awesome39.com', NOW(), NOW()),
('2', '2', 'admins@awesome39.com', NOW(), NOW())

;
