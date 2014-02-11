CREATE TABLE `profile` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `type` enum('user','group') NOT NULL DEFAULT 'user',
  `title` varchar(255) DEFAULT NULL,
  `enabledAt` timestamp NULL DEFAULT NULL,
  `updatedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_profile` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8;

INSERT INTO `profile` (`id`, `name`, `type`, `title`, `enabledAt`) VALUES

('1', 'root', 'user', 'Главрут', NOW()),
('2', 'admins', 'group', 'Администраторы', NOW()),
('3', 'anonymous', 'user', 'Анонимус', NOW()),
('4', 'anons', 'group', 'Аноны', NOW())

;
