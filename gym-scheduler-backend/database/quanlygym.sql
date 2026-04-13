-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Jan 22, 2026 at 10:30 PM
-- Server version: 9.1.0
-- PHP Version: 8.3.14

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `quanlygym`
--

-- --------------------------------------------------------

--
-- Table structure for table `booking_classes`
--

DROP TABLE IF EXISTS `booking_classes`;
CREATE TABLE IF NOT EXISTS `booking_classes` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `class_id` bigint UNSIGNED DEFAULT NULL,
  `schedule` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `booking_classes_user_class_schedule_unique` (`user_id`,`class_id`,`schedule`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `booking_classes`
--

INSERT INTO `booking_classes` (`id`, `user_id`, `class_id`, `schedule`, `status`, `created_at`, `updated_at`) VALUES
(1, 8, 1, 'thứ 2 | 06:00', 'confirmed', '2026-01-22 03:16:49', NULL),
(2, 8, 2, 'thứ 2 | 07:00', 'confirmed', '2026-01-22 03:23:38', '2026-01-22 03:23:38'),
(3, 8, 2, 'thứ 3 | 07:00', 'confirmed', '2026-01-22 03:23:38', '2026-01-22 03:23:38'),
(4, 8, 2, 'thứ 5 | 07:00', 'confirmed', '2026-01-22 03:23:38', '2026-01-22 03:23:38'),
(5, 8, 3, 'thứ 3 | 18:00', 'confirmed', '2026-01-22 04:15:09', '2026-01-22 04:15:09'),
(6, 8, 3, 'thứ 5 | 18:00', 'confirmed', '2026-01-22 04:15:09', '2026-01-22 04:15:09'),
(7, 8, 3, 'thứ 7 | 18:00', 'confirmed', '2026-01-22 04:15:09', '2026-01-22 04:15:09'),
(8, 8, 6, 'thứ 2-7 | 09:00', 'confirmed', '2026-01-22 04:52:01', '2026-01-22 04:52:01'),
(9, 8, 5, 'thứ 7 | 19:00', 'confirmed', '2026-01-22 04:57:25', '2026-01-22 04:57:25');

-- --------------------------------------------------------

--
-- Table structure for table `booking_trainers`
--

DROP TABLE IF EXISTS `booking_trainers`;
CREATE TABLE IF NOT EXISTS `booking_trainers` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `trainer_id` bigint UNSIGNED DEFAULT NULL,
  `schedule_info` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `booking_trainers`
--

INSERT INTO `booking_trainers` (`id`, `user_id`, `trainer_id`, `schedule_info`, `status`, `created_at`, `updated_at`) VALUES
(1, 8, 7, '22/01/2026 | 21:00 (Tối)', 'rejected', '2026-01-22 03:04:24', '2026-01-22 03:51:51'),
(2, 8, 7, '22/01/2026 | 19:30 (Tối)', 'confirmed', '2026-01-22 03:10:51', '2026-01-22 03:51:41'),
(3, 8, 2, '22/01/2026 | 21:00 (Tối)', 'confirmed', '2026-01-22 04:17:19', '2026-01-22 04:17:35'),
(4, 8, 7, '28/01/2026 | 09:00 (Sáng)', 'confirmed', '2026-01-22 04:52:58', '2026-01-22 04:53:09'),
(5, 8, 7, '31/01/2026 | 19:30 (Tối)', 'confirmed', '2026-01-22 04:55:16', '2026-01-22 04:55:37'),
(6, 8, 7, '30/01/2026 | 15:00 (Chiều)', 'confirmed', '2026-01-22 04:57:57', '2026-01-22 04:58:08'),
(7, 8, 7, '28/01/2026 | 16:30 (Chiều)', 'confirmed', '2026-01-22 05:01:09', '2026-01-22 05:01:14'),
(8, 8, 7, '28/01/2026 | 13:30 (Chiều)', 'confirmed', '2026-01-22 05:04:42', '2026-01-22 05:05:39'),
(9, 8, 7, '28/01/2026 | 21:00 (Tối)', 'pending', '2026-01-22 05:13:23', NULL),
(10, 8, 2, '31/01/2026 | 21:00 (Tối)', 'confirmed', '2026-01-22 05:39:56', '2026-01-22 05:40:59');

-- --------------------------------------------------------

--
-- Table structure for table `gym_classes`
--

DROP TABLE IF EXISTS `gym_classes`;
CREATE TABLE IF NOT EXISTS `gym_classes` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `trainer_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `time` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `duration` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `days` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `location` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `capacity` int NOT NULL,
  `registered` int DEFAULT '0',
  `price` decimal(10,0) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `gym_classes`
--

INSERT INTO `gym_classes` (`id`, `name`, `trainer_name`, `time`, `duration`, `days`, `location`, `capacity`, `registered`, `price`, `created_at`, `updated_at`) VALUES
(1, 'Boxing', 'Nguyễn Văn A', '06:00', '60 phút', 'Thứ 2, 4, 6', 'Phòng 1', 20, 13, 100000, '2026-01-22 08:38:17', '2026-01-22 08:38:17'),
(2, 'Yoga', 'Nguyễn Thị B', '07:00', '75 phút', 'Thứ 2, 3, 5', 'Phòng 2', 25, 21, 80000, '2026-01-22 08:38:17', '2026-01-22 08:38:17'),
(3, 'Strength Training', 'Trần Văn C', '18:00', '90 phút', 'Thứ 3, 5, 7', 'Phòng 3', 15, 11, 150000, '2026-01-22 08:38:17', '2026-01-22 08:38:17'),
(5, 'Wrestling & MMA', 'Hoàng Văn E', '19:00', '90 phút', 'Thứ 4, 6, 7', 'Phòng 5', 12, 6, 180000, '2026-01-22 08:38:17', '2026-01-22 08:38:17'),
(6, 'Gym & Fitness', 'Võ Thị F', '09:00', '60 phút', 'Thứ 2-7', 'Phòng 1', 40, 36, 90000, '2026-01-22 08:38:17', '2026-01-22 08:38:17'),
(7, 'a', 'a', '06:00 AM', '1', '2', 'a', 3, 1, 2, '2026-01-22 02:49:42', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `members`
--

DROP TABLE IF EXISTS `members`;
CREATE TABLE IF NOT EXISTS `members` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pack` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `duration` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `start` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `end` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `price` decimal(10,0) DEFAULT NULL,
  `status` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `members`
--

INSERT INTO `members` (`id`, `name`, `email`, `phone`, `pack`, `duration`, `start`, `end`, `price`, `status`, `created_at`, `updated_at`) VALUES
(9, 'abc', 'abc@gmail.com', '0123456789', 'VIP', '12', '2026-01-22', '2027-01-22', 3800000, 'active', '2026-01-22 02:21:16', '2026-01-22 02:21:16'),
(10, 'Thành viên 5', 'member5@gmail.com', NULL, 'Standard', '3', '2026-01-22', '2026-04-22', 1200000, 'active', '2026-01-22 02:50:27', '2026-01-22 02:50:27');

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
CREATE TABLE IF NOT EXISTS `migrations` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `migration` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '2026_01_22_095957_add_schedule_info_to_booking_trainers_table', 1),
(2, '2026_01_22_100303_create_orders_and_order_items_tables', 2),
(3, '2026_01_22_095957_add_schedule_info_to_booking_trainers_table', 1),
(4, '2026_01_22_100303_create_orders_and_order_items_tables', 1),
(5, '2026_01_22_101432_add_schedule_to_booking_classes_table', 3),
(6, '2026_01_22_101900_update_booking_classes_unique', 4),
(7, '2026_01_22_104444_add_email_phone_to_trainers_table', 5),
(8, '2026_01_22_104921_create_notifications_table', 6),
(10, '2026_01_22_000001_create_pending_registrations_table', 7),
(11, '2026_01_23_000002_add_avatar_to_users_table', 8);

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
CREATE TABLE IF NOT EXISTS `notifications` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NOT NULL,
  `title` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'info',
  `related_type` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `related_id` bigint DEFAULT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `notifications_user_id_foreign` (`user_id`)
) ENGINE=MyISAM AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`id`, `user_id`, `title`, `message`, `type`, `related_type`, `related_id`, `is_read`, `created_at`, `updated_at`) VALUES
(1, 8, 'Đặt lịch được xác nhận', 'Huấn luyện viên Lê Văn A đã xác nhận lịch hẹn của bạn. Lịch: 22/01/2026 | 19:30 (Tối)', 'booking', 'trainer', 2, 1, '2026-01-22 03:51:41', '2026-01-22 05:41:29'),
(2, 8, 'Đặt lịch bị từ chối', 'Huấn luyện viên Lê Văn A đã từ chối lịch hẹn của bạn. Lịch: 22/01/2026 | 21:00 (Tối)', 'booking', 'trainer', 1, 1, '2026-01-22 03:51:51', '2026-01-22 05:41:29'),
(3, 8, 'Đặt lịch được xác nhận', 'Huấn luyện viên Nguyễn Thị B đã xác nhận lịch hẹn của bạn. Lịch: 22/01/2026 | 21:00 (Tối)', 'booking', 'trainer', 3, 1, '2026-01-22 04:17:35', '2026-01-22 05:41:29'),
(4, 8, 'Đặt lớp thành công', 'Boxing • thứ 2 | 06:00', 'success', 'class', 1, 1, '2026-01-22 04:28:57', '2026-01-22 05:41:29'),
(5, 8, 'Đặt lớp thành công', 'Yoga • thứ 2 | 07:00', 'success', 'class', 2, 1, '2026-01-22 04:28:57', '2026-01-22 05:41:29'),
(6, 8, 'Đặt lớp thành công', 'Yoga • thứ 3 | 07:00', 'success', 'class', 2, 1, '2026-01-22 04:28:57', '2026-01-22 05:41:29'),
(7, 8, 'Đặt lớp thành công', 'Yoga • thứ 5 | 07:00', 'success', 'class', 2, 1, '2026-01-22 04:28:57', '2026-01-22 05:41:29'),
(8, 8, 'Đặt lớp thành công', 'Strength Training • thứ 3 | 18:00', 'success', 'class', 3, 1, '2026-01-22 04:28:57', '2026-01-22 05:41:29'),
(9, 8, 'Đặt lớp thành công', 'Strength Training • thứ 5 | 18:00', 'success', 'class', 3, 1, '2026-01-22 04:28:57', '2026-01-22 05:41:29'),
(10, 8, 'Đặt lớp thành công', 'Strength Training • thứ 7 | 18:00', 'success', 'class', 3, 1, '2026-01-22 04:28:57', '2026-01-22 05:41:29'),
(11, 8, 'Đặt lớp thành công', 'Gym & Fitness • thứ 2-7 | 09:00', 'success', 'class', 6, 1, '2026-01-22 04:52:01', '2026-01-22 05:41:29'),
(12, 8, 'Yêu cầu thuê HLV đã tạo', 'HLV Lê Văn A • 28/01/2026 | 09:00 (Sáng)', 'booking', 'trainer', 7, 1, '2026-01-22 04:52:58', '2026-01-22 05:41:29'),
(13, 8, 'Đặt lịch được xác nhận', 'Huấn luyện viên Lê Văn A đã xác nhận lịch hẹn của bạn. Lịch: 28/01/2026 | 09:00 (Sáng)', 'booking', 'trainer', 4, 1, '2026-01-22 04:53:09', '2026-01-22 05:41:29'),
(14, 8, 'Yêu cầu thuê HLV đã tạo', 'HLV Lê Văn A • 31/01/2026 | 19:30 (Tối)', 'booking', 'trainer', 7, 1, '2026-01-22 04:55:16', '2026-01-22 05:41:29'),
(15, 8, 'Đặt lịch được xác nhận', 'Huấn luyện viên Lê Văn A đã xác nhận lịch hẹn của bạn. Lịch: 31/01/2026 | 19:30 (Tối)', 'booking', 'trainer', 5, 1, '2026-01-22 04:55:37', '2026-01-22 05:41:29'),
(16, 8, 'Đặt lớp thành công', 'Wrestling & MMA • thứ 7 | 19:00', 'success', 'class', 5, 1, '2026-01-22 04:57:25', '2026-01-22 05:41:29'),
(17, 8, 'Yêu cầu thuê HLV đã tạo', 'HLV Lê Văn A • 30/01/2026 | 15:00 (Chiều)', 'booking', 'trainer', 7, 1, '2026-01-22 04:57:57', '2026-01-22 05:41:29'),
(18, 8, 'Đặt lịch được xác nhận', 'Huấn luyện viên Lê Văn A đã xác nhận lịch hẹn của bạn. Lịch: 30/01/2026 | 15:00 (Chiều)', 'booking', 'trainer', 6, 1, '2026-01-22 04:58:08', '2026-01-22 05:41:29'),
(19, 8, 'Yêu cầu thuê HLV đã tạo', 'HLV Lê Văn A • 28/01/2026 | 16:30 (Chiều)', 'booking', 'trainer', 7, 1, '2026-01-22 05:01:09', '2026-01-22 05:41:29'),
(20, 8, 'Đặt lịch được xác nhận', 'Huấn luyện viên Lê Văn A đã xác nhận lịch hẹn của bạn. Lịch: 28/01/2026 | 16:30 (Chiều)', 'booking', 'trainer', 7, 1, '2026-01-22 05:01:14', '2026-01-22 05:41:29'),
(21, 8, 'Yêu cầu thuê HLV đã tạo', 'HLV Lê Văn A • 28/01/2026 | 13:30 (Chiều)', 'booking', 'trainer', 7, 1, '2026-01-22 05:04:42', '2026-01-22 05:41:29'),
(22, 8, 'Đặt lịch được xác nhận', 'Huấn luyện viên Lê Văn A đã xác nhận lịch hẹn của bạn. Lịch: 28/01/2026 | 13:30 (Chiều)', 'booking', 'trainer', 8, 1, '2026-01-22 05:05:39', '2026-01-22 05:41:29'),
(23, 8, 'Yêu cầu thuê HLV đã tạo', 'HLV Lê Văn A • 28/01/2026 | 21:00 (Tối)', 'booking', 'trainer', 7, 1, '2026-01-22 05:13:23', '2026-01-22 05:41:29'),
(24, 8, 'Yêu cầu thuê HLV đã tạo', 'HLV Nguyễn Thị B • 31/01/2026 | 21:00 (Tối)', 'booking', 'trainer', 2, 1, '2026-01-22 05:39:56', '2026-01-22 05:41:29'),
(25, 8, 'Đặt lịch được xác nhận', 'Huấn luyện viên Nguyễn Thị B đã xác nhận lịch hẹn của bạn. Lịch: 31/01/2026 | 21:00 (Tối)', 'booking', 'trainer', 10, 1, '2026-01-22 05:40:59', '2026-01-22 05:41:29');

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
CREATE TABLE IF NOT EXISTS `orders` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NOT NULL,
  `total_amount` decimal(10,0) NOT NULL,
  `payment_method` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('pending','completed','cancelled') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `orders_user_id_foreign` (`user_id`)
) ENGINE=MyISAM AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`id`, `user_id`, `total_amount`, `payment_method`, `status`, `created_at`, `updated_at`) VALUES
(1, 8, 308000, 'bank_transfer', 'completed', '2026-01-22 03:04:24', '2026-01-22 03:04:24'),
(2, 8, 308000, 'bank_transfer', 'completed', '2026-01-22 03:10:51', '2026-01-22 03:10:51'),
(3, 8, 330000, 'bank_transfer', 'completed', '2026-01-22 03:16:49', '2026-01-22 03:16:49'),
(4, 8, 264000, 'bank_transfer', 'completed', '2026-01-22 03:23:38', '2026-01-22 03:23:38'),
(5, 8, 495000, 'bank_transfer', 'completed', '2026-01-22 04:15:09', '2026-01-22 04:15:09'),
(6, 8, 275000, 'credit_card', 'completed', '2026-01-22 04:17:19', '2026-01-22 04:17:19'),
(7, 8, 99000, 'bank_transfer', 'completed', '2026-01-22 04:52:01', '2026-01-22 04:52:01'),
(8, 8, 308000, 'bank_transfer', 'completed', '2026-01-22 04:52:58', '2026-01-22 04:52:58'),
(9, 8, 308000, 'bank_transfer', 'completed', '2026-01-22 04:55:16', '2026-01-22 04:55:16'),
(10, 8, 198000, 'bank_transfer', 'completed', '2026-01-22 04:57:25', '2026-01-22 04:57:25'),
(11, 8, 308000, 'bank_transfer', 'completed', '2026-01-22 04:57:57', '2026-01-22 04:57:57'),
(12, 8, 308000, 'bank_transfer', 'completed', '2026-01-22 05:01:09', '2026-01-22 05:01:09'),
(13, 8, 308000, 'bank_transfer', 'completed', '2026-01-22 05:04:42', '2026-01-22 05:04:42'),
(14, 8, 308000, 'bank_transfer', 'completed', '2026-01-22 05:13:23', '2026-01-22 05:13:23'),
(15, 8, 275000, 'bank_transfer', 'completed', '2026-01-22 05:39:56', '2026-01-22 05:39:56');

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

DROP TABLE IF EXISTS `order_items`;
CREATE TABLE IF NOT EXISTS `order_items` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `order_id` bigint UNSIGNED NOT NULL,
  `item_id` bigint NOT NULL,
  `item_name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_type` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `price` decimal(10,0) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `order_items_order_id_foreign` (`order_id`)
) ENGINE=MyISAM AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `order_items`
--

INSERT INTO `order_items` (`id`, `order_id`, `item_id`, `item_name`, `item_type`, `price`, `created_at`, `updated_at`) VALUES
(1, 1, 7, 'HLV Lê Văn A', 'trainer', 280000, NULL, NULL),
(2, 2, 7, 'HLV Lê Văn A', 'trainer', 280000, NULL, NULL),
(3, 3, 1, 'Boxing', 'class', 100000, NULL, NULL),
(4, 4, 2, 'Yoga', 'class', 80000, NULL, NULL),
(5, 5, 3, 'Strength Training', 'class', 150000, NULL, NULL),
(6, 6, 2, 'HLV Nguyễn Thị B', 'trainer', 250000, NULL, NULL),
(7, 7, 6, 'Gym & Fitness', 'class', 90000, NULL, NULL),
(8, 8, 7, 'HLV Lê Văn A', 'trainer', 280000, NULL, NULL),
(9, 9, 7, 'HLV Lê Văn A', 'trainer', 280000, NULL, NULL),
(10, 10, 5, 'Wrestling & MMA', 'class', 180000, NULL, NULL),
(11, 11, 7, 'HLV Lê Văn A', 'trainer', 280000, NULL, NULL),
(12, 12, 7, 'HLV Lê Văn A', 'trainer', 280000, NULL, NULL),
(13, 13, 7, 'HLV Lê Văn A', 'trainer', 280000, NULL, NULL),
(14, 14, 7, 'HLV Lê Văn A', 'trainer', 280000, NULL, NULL),
(15, 15, 2, 'HLV Nguyễn Thị B', 'trainer', 250000, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `packages`
--

DROP TABLE IF EXISTS `packages`;
CREATE TABLE IF NOT EXISTS `packages` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `duration` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `price` decimal(10,0) NOT NULL,
  `old_price` decimal(10,0) DEFAULT NULL,
  `benefits` int DEFAULT '0',
  `benefits_text` text COLLATE utf8mb4_unicode_ci,
  `color` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'blue',
  `is_popular` tinyint(1) DEFAULT '0',
  `status` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `packages`
--

INSERT INTO `packages` (`id`, `name`, `duration`, `price`, `old_price`, `benefits`, `benefits_text`, `color`, `is_popular`, `status`, `created_at`, `updated_at`) VALUES
(2, 'Standard', '3', 1200000, 1500000, 1, 'Tập 4 buổi/tuần, Tư vấn chi tiết, 2 lần check-up', 'green', 1, 'active', '2026-01-22 08:38:17', '2026-01-22 08:38:17'),
(3, 'Premium', '6', 2200000, 2700000, 1, 'Tập không giới hạn, Tư vấn toàn diện, 4 lần check-up, Cấp bằng', 'purple', 1, 'active', '2026-01-22 08:38:17', '2026-01-22 08:38:17'),
(4, 'VIP', '12', 3800000, 4500000, 1, 'Tất cả, Huấn luyện viên riêng, Lịch tập cá nhân, Hỗ trợ 24/7', 'purple', 0, 'active', '2026-01-22 08:38:17', '2026-01-22 08:38:17'),
(7, 'a', '2', 1, NULL, 4, '1\n1\n1\n1', 'green', 0, 'active', '2026-01-22 02:49:10', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `pending_registrations`
--

DROP TABLE IF EXISTS `pending_registrations`;
CREATE TABLE IF NOT EXISTS `pending_registrations` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `verification_code` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `code_expires_at` timestamp NOT NULL,
  `verified_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pending_registrations_email_unique` (`email`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `personal_access_tokens`
--

DROP TABLE IF EXISTS `personal_access_tokens`;
CREATE TABLE IF NOT EXISTS `personal_access_tokens` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`)
) ENGINE=InnoDB AUTO_INCREMENT=59 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `personal_access_tokens`
--

INSERT INTO `personal_access_tokens` (`id`, `tokenable_type`, `tokenable_id`, `name`, `token`, `abilities`, `last_used_at`, `expires_at`, `created_at`, `updated_at`) VALUES
(1, 'App\\Models\\User', 1, 'auth_token', '75419db3c93ef6d89ba49e074fd7aed865a2e82dac1a1079e791526cb962f40c', '[\"*\"]', '2026-01-22 01:40:03', NULL, '2026-01-22 01:38:43', '2026-01-22 01:40:03'),
(2, 'App\\Models\\User', 1, 'auth_token', 'f3ab42d2d4c66fe218ad71b71b48cc718ec37f98279744986c2df17b761ad878', '[\"*\"]', '2026-01-22 02:52:44', NULL, '2026-01-22 01:41:57', '2026-01-22 02:52:44'),
(3, 'App\\Models\\User', 8, 'auth_token', '68f9c32d1f1338bb14c9fffe8746ef097e5799fc38dac374704f8080de08b9d0', '[\"*\"]', '2026-01-22 03:23:40', NULL, '2026-01-22 02:55:38', '2026-01-22 03:23:40'),
(4, 'App\\Models\\User', 16, 'auth_token', 'c0339aad222605a496dd6ddceae5937904fb47d555b4f1ccf5b375f0bbe82800', '[\"*\"]', '2026-01-22 03:24:53', NULL, '2026-01-22 03:24:50', '2026-01-22 03:24:53'),
(5, 'App\\Models\\User', 3, 'auth_token', '1a4c21833294ea329b147dcf940f226cb3dfe78a0c327afc2c87316a1807fc3a', '[\"*\"]', '2026-01-22 03:30:10', NULL, '2026-01-22 03:25:22', '2026-01-22 03:30:10'),
(6, 'App\\Models\\User', 16, 'auth_token', '308d44e9798c946916454ba46d716c6a21cbc2460b6ad870fca467bc04c2025d', '[\"*\"]', '2026-01-22 03:51:52', NULL, '2026-01-22 03:30:21', '2026-01-22 03:51:52'),
(7, 'App\\Models\\User', 8, 'auth_token', '2caa94ea2a2fbe29c8a72a87298a8f3c067a8975868b71541241ff7b4d19b859', '[\"*\"]', '2026-01-22 04:16:16', NULL, '2026-01-22 03:52:25', '2026-01-22 04:16:16'),
(8, 'App\\Models\\User', 1, 'auth_token', '14e929ff89d91e84f4733e153ad0e1e4f082e60d7bce7352af2b17d5ac796c63', '[\"*\"]', '2026-01-22 04:04:58', NULL, '2026-01-22 03:54:16', '2026-01-22 04:04:58'),
(9, 'App\\Models\\User', 8, 'auth_token', '18741d41f97121a14fec5b36dd79890e4c6143737ef3af122c9af77d1fdf4dad', '[\"*\"]', '2026-01-22 04:22:49', NULL, '2026-01-22 04:15:32', '2026-01-22 04:22:49'),
(10, 'App\\Models\\User', 8, 'auth_token', '9574040dfe8367db0d3e5363728101e3cd59c7590ee1c0f3544b54f6dcf82110', '[\"*\"]', '2026-01-22 04:16:38', NULL, '2026-01-22 04:16:36', '2026-01-22 04:16:38'),
(11, 'App\\Models\\User', 3, 'auth_token', '1368088c2ba6feca32bd5396f13c1a105a0b0c5b3f26622d41849e4e81d02910', '[\"*\"]', '2026-01-22 04:22:04', NULL, '2026-01-22 04:17:06', '2026-01-22 04:22:04'),
(12, 'App\\Models\\User', 8, 'auth_token', 'edbdabafd2f3d21209050a90e12a762eeac1795e74e8058898402265a60f70b1', '[\"*\"]', '2026-01-22 04:31:43', NULL, '2026-01-22 04:23:06', '2026-01-22 04:31:43'),
(13, 'App\\Models\\User', 8, 'auth_token', '6d01d5afd88c0b31eb712ce8e00f943852c7ef1cbe986cbd31a6d961b5d3000f', '[\"*\"]', '2026-01-22 04:32:23', NULL, '2026-01-22 04:32:09', '2026-01-22 04:32:23'),
(14, 'App\\Models\\User', 8, 'auth_token', '149610f6210c25fb445682cb3872e1c923bf35674ef38c965ff01cda34dc83c9', '[\"*\"]', '2026-01-22 04:41:16', NULL, '2026-01-22 04:37:17', '2026-01-22 04:41:16'),
(15, 'App\\Models\\User', 8, 'auth_token', '67074930bc04586ea3a02ea40368e9d557c3c1fd71c6333a56241673b52772ad', '[\"*\"]', '2026-01-22 04:45:23', NULL, '2026-01-22 04:37:53', '2026-01-22 04:45:23'),
(16, 'App\\Models\\User', 8, 'auth_token', 'a4364b8024e3c391ba9f08ed75c282e62d7bb0e4b131c1ea43a8d68d483e9abc', '[\"*\"]', '2026-01-22 04:46:48', NULL, '2026-01-22 04:41:30', '2026-01-22 04:46:48'),
(17, 'App\\Models\\User', 8, 'auth_token', '8224de488084b9be472cf2e010075e9686af7bd88ff98f8943e981576910a06d', '[\"*\"]', '2026-01-22 04:51:19', NULL, '2026-01-22 04:47:13', '2026-01-22 04:51:19'),
(18, 'App\\Models\\User', 8, 'auth_token', 'f2740678f86ded05328df5e36a2b128644ee58b8541abc1e5cc23a7dde711519', '[\"*\"]', '2026-01-22 05:03:33', NULL, '2026-01-22 04:51:19', '2026-01-22 05:03:33'),
(19, 'App\\Models\\User', 16, 'auth_token', '96a2dadf40672dfc5c2db6952c2854dd513a96e99880df03a2e7e5dbf7492bb0', '[\"*\"]', '2026-01-22 05:01:15', NULL, '2026-01-22 04:52:41', '2026-01-22 05:01:15'),
(20, 'App\\Models\\User', 16, 'auth_token', '49c3163a6dac0a052293a1c896fe6bb366681cf712012c3e357af3b944348de1', '[\"*\"]', '2026-01-22 05:01:31', NULL, '2026-01-22 05:01:30', '2026-01-22 05:01:31'),
(21, 'App\\Models\\User', 8, 'auth_token', 'eb4227ca9b08f9e74a2fe08f9f4f5438e603910d4242e923e8f90237a32cf915', '[\"*\"]', '2026-01-22 05:05:19', NULL, '2026-01-22 05:01:46', '2026-01-22 05:05:19'),
(22, 'App\\Models\\User', 8, 'auth_token', '4c8274a45e082914ea6dc791f0313bf7abf10b5ee3ebc28a865531dcf7d36173', '[\"*\"]', '2026-01-22 05:08:27', NULL, '2026-01-22 05:04:24', '2026-01-22 05:08:27'),
(23, 'App\\Models\\User', 16, 'auth_token', '9505d66acee5d26980488c1e97f4e8ee24d4db18e196dcb38a0bb35e8c961412', '[\"*\"]', '2026-01-22 05:40:29', NULL, '2026-01-22 05:05:36', '2026-01-22 05:40:29'),
(24, 'App\\Models\\User', 8, 'auth_token', '1ee3edd026a0ca9f838fa8bc8c31f269cb5104fedb371c6821d0e5c0f4a57794', '[\"*\"]', '2026-01-22 05:08:39', NULL, '2026-01-22 05:08:27', '2026-01-22 05:08:39'),
(25, 'App\\Models\\User', 9, 'auth_token', 'b56014b2e1b7940cad71e1e4bce108ac7244249affe77e7bd0bbb2faaa6f414a', '[\"*\"]', '2026-01-22 05:09:03', NULL, '2026-01-22 05:08:53', '2026-01-22 05:09:03'),
(26, 'App\\Models\\User', 8, 'auth_token', '0ad14509e192cfeeba24c10f06000726bda287849b22350784354d00d5a569be', '[\"*\"]', '2026-01-22 05:12:17', NULL, '2026-01-22 05:09:08', '2026-01-22 05:12:17'),
(27, 'App\\Models\\User', 8, 'auth_token', '0239d0bb7953f22899ad6f633a6fbf598106f2da73d1bfe3b77173cc767e6470', '[\"*\"]', '2026-01-22 05:12:32', NULL, '2026-01-22 05:12:23', '2026-01-22 05:12:32'),
(28, 'App\\Models\\User', 8, 'auth_token', 'f7801630cf4c758224cf50935eb1b736cf2d4f77730f14ce0b37527763e978eb', '[\"*\"]', '2026-01-22 05:31:08', NULL, '2026-01-22 05:12:55', '2026-01-22 05:31:08'),
(29, 'App\\Models\\User', 8, 'auth_token', '242e00a18ddb617514222ae739f03f715976531828dca1002b6e9c03a94498d2', '[\"*\"]', '2026-01-22 05:36:20', NULL, '2026-01-22 05:31:07', '2026-01-22 05:36:20'),
(30, 'App\\Models\\User', 8, 'auth_token', '6d77bca8fab352c19b2fad0dd110eeb1435684864e1a28129276489fe023ef3a', '[\"*\"]', '2026-01-22 05:38:38', NULL, '2026-01-22 05:36:20', '2026-01-22 05:38:38'),
(31, 'App\\Models\\User', 8, 'auth_token', '52a7533bc7c7c8ace32ef2a9165bc333da85cc165411925bd17b7719da169f3a', '[\"*\"]', '2026-01-22 05:41:38', NULL, '2026-01-22 05:38:38', '2026-01-22 05:41:38'),
(32, 'App\\Models\\User', 3, 'auth_token', '51c87ef2daee432b9143ad0adc077dcc507e11a9e0309d1ad1df01fefa1f5c72', '[\"*\"]', '2026-01-22 05:41:04', NULL, '2026-01-22 05:40:53', '2026-01-22 05:41:04'),
(33, 'App\\Models\\User', 9, 'auth_token', 'e32c9fdeac52686b7ab5e7a040480face4bbd6ff0f1f8781dd32e3ec1bdc9bbc', '[\"*\"]', '2026-01-22 09:48:33', NULL, '2026-01-22 05:41:13', '2026-01-22 09:48:33'),
(34, 'App\\Models\\User', 8, 'auth_token', '4c639bed1bd8a1516b84893073627d9f4b9e1610b3fd8d02fc5d69f3ccfbafc2', '[\"*\"]', '2026-01-22 09:49:09', NULL, '2026-01-22 09:47:01', '2026-01-22 09:49:09'),
(35, 'App\\Models\\User', 1, 'auth_token', '483e63a306ce377fd3da8f46b908b7cb9fde5979a9973fab2e363af29935d63d', '[\"*\"]', '2026-01-22 09:49:44', NULL, '2026-01-22 09:48:54', '2026-01-22 09:49:44'),
(36, 'App\\Models\\User', 17, 'auth_token', 'cfb134ca4f54d70e2b267f60d23e17bf2c927c15b07f45c8ad4348285f7bbdd5', '[\"*\"]', NULL, NULL, '2026-01-22 10:11:19', '2026-01-22 10:11:19'),
(37, 'App\\Models\\User', 18, 'auth_token', '746f7f53ad5a0effde9bf824c756667f128d4be4eaf3e7c0d3d302dcb8ceba2f', '[\"*\"]', NULL, NULL, '2026-01-22 10:32:43', '2026-01-22 10:32:43'),
(38, 'App\\Models\\User', 18, 'auth_token', '2063f45c02fa179e5db7c0bd2e56d597eab9787a96f256351bee571cdac0d389', '[\"*\"]', '2026-01-22 10:33:14', NULL, '2026-01-22 10:33:02', '2026-01-22 10:33:14'),
(39, 'App\\Models\\User', 16, 'auth_token', '3d6df4ad9f134fbb92dbe07e479fe4fabbbe654c93f167c048520bc59221b143', '[\"*\"]', '2026-01-22 10:33:41', NULL, '2026-01-22 10:33:34', '2026-01-22 10:33:41'),
(40, 'App\\Models\\User', 1, 'auth_token', '7e5754a544eae2ebad02f81b66f46fd41b773d4429293eee423d3a0c1749d1f5', '[\"*\"]', '2026-01-22 10:34:51', NULL, '2026-01-22 10:34:01', '2026-01-22 10:34:51'),
(41, 'App\\Models\\User', 18, 'auth_token', '8d92f38809366e2a697f550c58659ff7b90c3749903db3f79677dd2dfdb81bed', '[\"*\"]', '2026-01-22 12:07:21', NULL, '2026-01-22 10:35:00', '2026-01-22 12:07:21'),
(42, 'App\\Models\\User', 1, 'auth_token', '5b182b2fd60329202683d506d70f2e7cebe54546f62b4e42d59d2ad15fc5e93f', '[\"*\"]', '2026-01-22 12:09:28', NULL, '2026-01-22 12:07:38', '2026-01-22 12:09:28'),
(43, 'App\\Models\\User', 8, 'auth_token', 'ac87d2e24fbaee06916b3cd8e6be1ed260c61fa407edfbb98e218fcc1602687d', '[\"*\"]', '2026-01-22 12:27:30', NULL, '2026-01-22 12:26:46', '2026-01-22 12:27:30'),
(44, 'App\\Models\\User', 18, 'auth_token', 'b113acb8fe72c5912c77e749d904958349f7d5eaa65c0e647cbe8c26146286d6', '[\"*\"]', '2026-01-22 12:27:39', NULL, '2026-01-22 12:26:59', '2026-01-22 12:27:39'),
(45, 'App\\Models\\User', 1, 'auth_token', 'd30c803baef6528014053e592f9eaa21d7011e9877edd59b41f9b8041853f20d', '[\"*\"]', '2026-01-22 13:03:24', NULL, '2026-01-22 12:27:48', '2026-01-22 13:03:24'),
(46, 'App\\Models\\User', 1, 'auth_token', '10e023b3e823180c500e43534fd3ab48d827eac47fe665960488307bdae21587', '[\"*\"]', '2026-01-22 13:14:23', NULL, '2026-01-22 13:04:56', '2026-01-22 13:14:23'),
(47, 'App\\Models\\User', 1, 'auth_token', 'd1428aad0698cf8a77e0932fdeb5aeeed74bd3e8c2089ff7b6eb55b38596d60f', '[\"*\"]', '2026-01-22 13:22:29', NULL, '2026-01-22 13:14:43', '2026-01-22 13:22:29'),
(48, 'App\\Models\\User', 1, 'auth_token', '88005f750bf956a5fac58229343e12263d0e1d6a8638b518e73cd5b9aac956e7', '[\"*\"]', '2026-01-22 14:24:19', NULL, '2026-01-22 13:22:40', '2026-01-22 14:24:19'),
(49, 'App\\Models\\User', 1, 'auth_token', '04090f446996ad2f31a652844e220a9a37c557482113ecc4c14c10135b3278d1', '[\"*\"]', '2026-01-22 14:54:51', NULL, '2026-01-22 14:25:14', '2026-01-22 14:54:51'),
(50, 'App\\Models\\User', 1, 'auth_token', '8e84c5847893468e65c2b9189c104fad35814f42b36f2479b44a1325042a6211', '[\"*\"]', '2026-01-22 14:31:23', NULL, '2026-01-22 14:26:12', '2026-01-22 14:31:23'),
(51, 'App\\Models\\User', 1, 'auth_token', '8bd1a48a7ab81f908e3d6f723db5f850a845ce0b7d206b42c855b55b4920f053', '[\"*\"]', '2026-01-22 14:53:56', NULL, '2026-01-22 14:31:23', '2026-01-22 14:53:56'),
(52, 'App\\Models\\User', 1, 'auth_token', '2b421db43ff245ee05566d8990c8bbe0d6c70294e88b08e778ffc0e0762cd0be', '[\"*\"]', '2026-01-22 15:02:10', NULL, '2026-01-22 14:53:56', '2026-01-22 15:02:10'),
(53, 'App\\Models\\User', 1, 'auth_token', 'd0706e293b11fcb6b0e59fe366806d825c298418201434656f8110c7e4f111d2', '[\"*\"]', '2026-01-22 15:08:25', NULL, '2026-01-22 15:02:10', '2026-01-22 15:08:25'),
(54, 'App\\Models\\User', 1, 'auth_token', '6f6fceb3e86b1f0cd093e9c97024f97d04043678e27cc533bdf7adc0f609b466', '[\"*\"]', '2026-01-22 15:18:44', NULL, '2026-01-22 15:08:25', '2026-01-22 15:18:44'),
(55, 'App\\Models\\User', 1, 'auth_token', 'fde142045e0b9706fbdf59da9e50330ab48aacc61518dc7a60f8e52cd1b73583', '[\"*\"]', '2026-01-22 15:21:03', NULL, '2026-01-22 15:18:44', '2026-01-22 15:21:03'),
(56, 'App\\Models\\User', 1, 'auth_token', '9c1d56deb46968a625978e8babb5be6059cffc038ed2f5512eae5887d7ab2bc4', '[\"*\"]', '2026-01-22 15:23:09', NULL, '2026-01-22 15:21:03', '2026-01-22 15:23:09'),
(57, 'App\\Models\\User', 1, 'auth_token', '22ebc3174071e8e4239a29c8c9ee1fcd14e6c1bc1fa4f255652c80ec11db96bb', '[\"*\"]', '2026-01-22 15:28:09', NULL, '2026-01-22 15:23:09', '2026-01-22 15:28:09'),
(58, 'App\\Models\\User', 1, 'auth_token', 'dfb1471e4a13e80658344e184e8091bb8f940b1c5e07ead93a3feacbf99dc901', '[\"*\"]', '2026-01-22 15:29:09', NULL, '2026-01-22 15:28:09', '2026-01-22 15:29:09');

-- --------------------------------------------------------

--
-- Table structure for table `trainers`
--

DROP TABLE IF EXISTS `trainers`;
CREATE TABLE IF NOT EXISTS `trainers` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `image` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `spec` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `exp` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `rating` decimal(2,1) DEFAULT '5.0',
  `availability` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `price` decimal(10,0) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `trainers`
--

INSERT INTO `trainers` (`id`, `name`, `email`, `phone`, `image`, `spec`, `exp`, `rating`, `availability`, `price`, `created_at`, `updated_at`) VALUES
(2, 'Nguyễn Thị B', 'trainer2@gmail.com', NULL, 'http://192.168.1.5:8000/storage/trainers/trainer_1769108878.jpg', 'Yoga & Pilates', '6 năm', 4.8, 'Sáng, Chiều, Tối', 250000, '2026-01-22 08:38:17', '2026-01-22 08:38:17'),
(7, 'Lê Văn A', 'trainer1@gmail.com', '', '/storage/trainers/trainer_1769120905.jpeg', 'Gym & Fitness', '7 năm', 5.0, 'Sáng, Chiều, Tối', 280000, '2026-01-22 02:42:12', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `avatar` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'user',
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `email_verified_at`, `password`, `avatar`, `role`, `phone`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 'Quản Trị Viên', 'admin@gmail.com', '2026-01-22 08:38:17', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', NULL, 'admin', NULL, NULL, '2026-01-22 08:38:17', '2026-01-22 08:38:17'),
(3, 'Nguyễn Thị B', 'trainer2@gmail.com', '2026-01-22 08:38:17', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', NULL, 'trainer', NULL, NULL, '2026-01-22 08:38:17', '2026-01-22 08:38:17'),
(8, 'Thành viên 1', 'member1@gmail.com', '2026-01-22 08:38:17', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', NULL, 'user', NULL, NULL, '2026-01-22 08:38:17', '2026-01-22 08:38:17'),
(9, 'Thành viên 2', 'member2@gmail.com', '2026-01-22 08:38:17', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', NULL, 'user', NULL, NULL, '2026-01-22 08:38:17', '2026-01-22 08:38:17'),
(14, 'a', 'member10@gmail.com', NULL, '$2y$12$U3QwXJiysVJSV2RDfY334.h88dZSbg4.2CR1jxz1/JciMP2Wuhp06', NULL, 'member', NULL, NULL, '2026-01-22 01:47:36', '2026-01-22 01:50:13'),
(15, 'abc', 'abc@gmail.com', NULL, '$2y$12$lUJTtE65DXjm/kMZ0JG6E.REfFSZVj8jzh.sTk1YU7zyw0pCN3/P2', NULL, 'member', '0123456789', NULL, '2026-01-22 02:02:36', '2026-01-22 02:21:16'),
(16, 'Lê Văn A', 'trainer1@gmail.com', NULL, '$2y$12$H2Q1sc21ZRVrQ6N1nnyZCOeomq/1jmlIsYYzQiRtW4E4UOIJy3l2C', NULL, 'trainer', '', NULL, '2026-01-22 02:42:12', '2026-01-22 02:42:12'),
(18, 'dat', 'levandat100603@gmail.com', NULL, '$2y$12$vTeA1vQu8FbnYc9hx2kLTuxHLZQUJMfQc5fw0ZayTQ9XCBVQMNKQ.', NULL, 'user', NULL, NULL, '2026-01-22 10:32:43', '2026-01-22 10:32:43');

-- --------------------------------------------------------

--
-- Table structure for table `workout_schedules`
--

DROP TABLE IF EXISTS `workout_schedules`;
CREATE TABLE IF NOT EXISTS `workout_schedules` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `date` date NOT NULL,
  `time` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `duration` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
