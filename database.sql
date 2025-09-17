-- Housing System Database Setup
-- This file is optional - the system will create the table automatically
-- But you can use this for manual setup if needed

CREATE TABLE IF NOT EXISTS `houses` (
    `id` INT(11) AUTO_INCREMENT PRIMARY KEY,
    `house_id` INT(11) NOT NULL UNIQUE,
    `owner` VARCHAR(60) DEFAULT NULL,
    `owned` BOOLEAN DEFAULT FALSE,
    INDEX `idx_house_id` (`house_id`),
    INDEX `idx_owner` (`owner`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default houses
INSERT IGNORE INTO `houses` (`house_id`, `owner`, `owned`) VALUES
(1, NULL, FALSE),
(2, NULL, FALSE),
(3, NULL, FALSE),
(4, NULL, FALSE),
(5, NULL, FALSE),
(6, NULL, FALSE);