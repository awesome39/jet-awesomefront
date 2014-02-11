CREATE TABLE `profile_phone` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `profileId` int(11) NOT NULL,
  `value` varchar(255) NOT NULL,
  `verifiedAt` timestamp NULL DEFAULT NULL,
  `enabledAt` timestamp NULL DEFAULT NULL,
  `updatedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_profile_phone` (`value`),
  KEY `i_profile_phone_profileId` (`profileId`),
  CONSTRAINT `f_profile_phone_profileId` FOREIGN KEY (`profileId`) REFERENCES `profile` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2701 DEFAULT CHARSET=utf8;

INSERT INTO `profile_phone` (`id`, `profileId`, `value`, `verifiedAt`, `enabledAt`) VALUES

('1', '1', '+7 123 456-78-90', NOW(), NOW()),
('2', '1', '+7 123 456-78-91', NOW(), NOW())

;
