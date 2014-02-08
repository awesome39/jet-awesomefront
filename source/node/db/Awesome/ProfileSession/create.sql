CREATE TABLE `profile_session` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `profileId` int(11) NOT NULL,
  `sessionId` varchar(45) NOT NULL,
  `ip` varchar(45) DEFAULT NULL,
  `headers` text,
  `createdAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `expiredAt` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_profile_session_sessionId` (`sessionId`),
  KEY `i_profile_session_profileId` (`profileId`),
  CONSTRAINT `f_profile_session_profileId` FOREIGN KEY (`profileId`) REFERENCES `profile` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
