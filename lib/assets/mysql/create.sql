CREATE TABLE word (
	`id` int not null auto_increment,
	`word` varchar(64) not null,
	`picture` varchar(255) default null,
	`timestamp` timestamp default now(),
	primary key (`id`),
	unique key word (`word`)
) ENGINE=innodb Default charset=utf8;

CREATE TABLE user (
	`id` int not null auto_increment,
	`username` varchar(64) not null,
	`email` varchar(255) not null,
	`password` varchar(255) not null,
	`timestamp` timestamp default now(),
	primary key (`id`),
	unique key username (`username`),
	unique key email (`email`)
) ENGINE=innodb Default charset=utf8;

