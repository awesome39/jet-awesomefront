CREATE TABLE `permission` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `enabledAt` timestamp NULL DEFAULT NULL,
  `updatedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_permission` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8;

INSERT INTO `permission` (`id`, `name`, `enabledAt`) VALUES

('12', 'profile.select', NOW()),
('13', 'profile.update', NOW()),

('21', 'profiles.insert', NOW()),
('22', 'profiles.select', NOW()),
('23', 'profiles.update', NOW()),
('24', 'profiles.delete', NOW())

;
