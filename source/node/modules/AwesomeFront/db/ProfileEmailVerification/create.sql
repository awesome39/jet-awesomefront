CREATE TABLE `profile_email_verification` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `token` varchar(50) NOT NULL,
  `emailId` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `email_fk_constraint` (`emailId`),
  CONSTRAINT `email_fk_constraint` FOREIGN KEY (`emailId`) REFERENCES `profile_email` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8
