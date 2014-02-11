CREATE TABLE `profile_permission` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `profileId` int(11) NOT NULL,
  `permissionId` int(11) NOT NULL,
  `value` int(1) NOT NULL DEFAULT '1',
  `enabledAt` timestamp NULL DEFAULT NULL,
  `updatedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_profile_permission` (`profileId`, `permissionId`, `value`),
  KEY `i_profile_permission_profileId` (`profileId`),
  KEY `i_profile_permission_permissionId` (`permissionId`),
  CONSTRAINT `f_profile_permission_permissionId` FOREIGN KEY (`permissionId`) REFERENCES `permission` (`id`) ON DELETE CASCADE,
  CONSTRAINT `f_profile_permission_profileId` FOREIGN KEY (`profileId`) REFERENCES `profile` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2701 DEFAULT CHARSET=utf8;

INSERT INTO `profile_permission` (`id`, `profileId`, `permissionId`, `value`, `enabledAt`) VALUES

('12', '1', '12', '1', NOW()),
('13', '1', '13', '1', NOW()),
('14', '1', '21', '1', NOW()),
('15', '1', '22', '1', NOW()),
('16', '1', '23', '1', NOW()),
('17', '1', '24', '1', NOW()),

('22', '3', '12', '1', NOW())

;
