-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: May 24, 2026 at 02:30 PM
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
-- Database: `gym`
--

-- --------------------------------------------------------

--
-- Table structure for table `booking_cancellations`
--

DROP TABLE IF EXISTS `booking_cancellations`;
CREATE TABLE IF NOT EXISTS `booking_cancellations` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `booking_id` bigint UNSIGNED NOT NULL,
  `member_id` bigint UNSIGNED NOT NULL,
  `reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `cancelled_at` timestamp NOT NULL,
  `penalty` decimal(10,2) DEFAULT NULL,
  `refund_amount` decimal(10,2) DEFAULT NULL,
  `status` enum('pending','approved','rejected','processed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `booking_classes`
--

DROP TABLE IF EXISTS `booking_classes`;
CREATE TABLE IF NOT EXISTS `booking_classes` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `class_id` bigint UNSIGNED DEFAULT NULL,
  `schedule` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `booking_classes_user_class_schedule_unique` (`user_id`,`class_id`,`schedule`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
(9, 8, 5, 'thứ 7 | 19:00', 'confirmed', '2026-01-22 04:57:25', '2026-01-22 04:57:25'),
(10, 1, 8, 'thứ 2,6,7 | 06:00 AM', 'confirmed', '2026-04-27 04:55:34', '2026-04-27 04:55:34'),
(11, 9, 6, 'Thứ 2-7 | 09:00', 'confirmed', '2026-05-09 08:53:45', '2026-05-09 08:53:45');

-- --------------------------------------------------------

--
-- Table structure for table `booking_trainers`
--

DROP TABLE IF EXISTS `booking_trainers`;
CREATE TABLE IF NOT EXISTS `booking_trainers` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `trainer_id` bigint UNSIGNED DEFAULT NULL,
  `schedule_info` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
(10, 8, 2, '31/01/2026 | 21:00 (Tối)', 'confirmed', '2026-01-22 05:39:56', '2026-01-22 05:40:59'),
(11, 8, 7, '30/04/2026 | 06:00', 'confirmed', '2026-04-27 08:00:05', '2026-04-27 08:00:26');

-- --------------------------------------------------------

--
-- Table structure for table `gym_classes`
--

DROP TABLE IF EXISTS `gym_classes`;
CREATE TABLE IF NOT EXISTS `gym_classes` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `trainer_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `time` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `duration` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `days` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `capacity` int NOT NULL,
  `registered` int DEFAULT '0',
  `price` decimal(10,0) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `gym_classes`
--

INSERT INTO `gym_classes` (`id`, `name`, `trainer_name`, `time`, `duration`, `days`, `location`, `capacity`, `registered`, `price`, `created_at`, `updated_at`) VALUES
(1, 'Boxing', 'Nguyễn Văn A', '06:00', '60 phút', 'Thứ 2, 4, 6', 'Phòng 1', 20, 13, 100000, '2026-01-22 08:38:17', '2026-01-22 08:38:17'),
(2, 'Yoga', 'Nguyễn Thị B', '07:00', '75 phút', 'Thứ 2, 3, 5', 'Phòng 2', 25, 21, 80000, '2026-01-22 08:38:17', '2026-01-22 08:38:17'),
(3, 'Strength Training', 'Trần Văn C', '18:00', '90 phút', 'Thứ 3, 5, 7', 'Phòng 3', 15, 11, 150000, '2026-01-22 08:38:17', '2026-01-22 08:38:17'),
(5, 'Wrestling & MMA', 'Hoàng Văn E', '19:00', '90 phút', 'Thứ 4, 6, 7', 'Phòng 5', 12, 6, 180000, '2026-01-22 08:38:17', '2026-01-22 08:38:17'),
(6, 'Gym & Fitness', 'Võ Thị F', '09:00', '60 phút', 'Thứ 2-7', 'Phòng 1', 40, 37, 90000, '2026-01-22 08:38:17', '2026-01-22 08:38:17'),
(7, 'a', 'a', '06:00 AM', '1', '2', 'a', 3, 1, 2, '2026-01-22 02:49:42', NULL),
(9, 'a', 'Lê Văn A', '06:00', '1', 'T2, T3, T4', 'a', 22, 0, 1, '2026-05-23 23:52:57', NULL),
(10, 'bbb', 'Nguyễn Thị B', '14:00', '90', 'CN', 'b', 20, 0, 3333, '2026-05-23 23:59:43', NULL),
(11, 'cc', 'Lê Văn A', '06:00', '22', 'CN', 'c', 22, 0, 1, '2026-05-24 00:29:57', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `members`
--

DROP TABLE IF EXISTS `members`;
CREATE TABLE IF NOT EXISTS `members` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pack` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `duration` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `start` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `end` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `price` decimal(10,0) DEFAULT NULL,
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `members`
--

INSERT INTO `members` (`id`, `name`, `email`, `phone`, `pack`, `duration`, `start`, `end`, `price`, `status`, `created_at`, `updated_at`) VALUES
(11, 'Thành viên 2', 'member2@gmail.com', '0999999999', 'Standard', '3', '2026-04-27', '2026-07-27', 1200000, 'inactive', '2026-04-27 07:25:40', '2026-04-27 07:27:24'),
(12, 'Thành viên 1', 'member1@gmail.com', '000009999', 'a', '2', '2026-04-27', '2026-06-27', 1, 'inactive', '2026-04-27 07:26:41', '2026-04-27 07:27:19');

-- --------------------------------------------------------

--
-- Table structure for table `membership_freezes`
--

DROP TABLE IF EXISTS `membership_freezes`;
CREATE TABLE IF NOT EXISTS `membership_freezes` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `member_id` bigint UNSIGNED NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `reason` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('pending','approved','active','expired') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `approved_by` bigint UNSIGNED DEFAULT NULL,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `member_cards`
--

DROP TABLE IF EXISTS `member_cards`;
CREATE TABLE IF NOT EXISTS `member_cards` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `member_id` bigint UNSIGNED NOT NULL,
  `card_number` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `qr_code` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `member_cards_member_unique` (`member_id`),
  UNIQUE KEY `member_cards_number_unique` (`card_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
CREATE TABLE IF NOT EXISTS `migrations` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `migration` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_users_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1),
(3, '0001_01_01_000002_create_jobs_table', 1),
(4, '2025_11_16_124504_create_personal_access_tokens_table', 1),
(5, '2025_11_16_125248_add_role_and_phone_to_users_table', 1),
(6, '2025_11_16_130913_create_workout_schedules_table', 1),
(7, '2026_01_07_211708_add_role_to_users_table', 1),
(8, '2026_01_08_001923_create_gym_tables', 1),
(9, '2026_01_21_000001_create_booking_classes_table', 1),
(10, '2026_01_22_000000_add_email_verification_to_users', 1),
(11, '2026_01_22_000001_create_pending_registrations_table', 1),
(12, '2026_01_22_095957_add_schedule_info_to_booking_trainers_table', 1),
(13, '2026_01_22_100303_create_orders_and_order_items_tables', 1),
(14, '2026_01_22_101432_add_schedule_to_booking_classes_table', 1),
(15, '2026_01_22_101900_update_booking_classes_unique', 1),
(16, '2026_01_22_104444_add_email_phone_to_trainers_table', 1),
(17, '2026_01_22_104921_create_notifications_table', 1),
(18, '2026_04_13_120000_add_membership_columns_to_users_table', 1),
(19, '2026_04_13_120100_backfill_membership_from_members_to_users', 1),
(20, '2026_04_13_230000_create_password_reset_tokens_if_missing', 1),
(21, '2026_04_26_000001_create_working_hours_table', 1),
(22, '2026_04_26_000002_create_time_offs_table', 1),
(23, '2026_04_26_000003_create_session_notes_table', 1),
(24, '2026_04_26_000004_create_workout_plans_table', 1),
(25, '2026_04_26_000005_create_trainer_earnings_table', 1),
(26, '2026_04_26_000006_create_waitlist_entries_table', 1),
(27, '2026_04_26_000007_create_membership_freezes_table', 1),
(28, '2026_04_26_000008_create_member_cards_table', 1),
(29, '2026_04_26_000009_create_booking_cancellations_table', 1),
(30, '2026_04_26_000010_create_vouchers_table', 1),
(31, '2026_04_26_000011_create_push_campaigns_table', 1),
(32, '2026_04_26_000012_create_refund_requests_table', 1),
(33, '2026_04_26_000013_create_transaction_reports_table', 1),
(34, '2026_04_27_000014_create_booking_trainers_table_if_missing', 1),
(35, '2026_05_09_000001_add_avatar_to_users_table', 2),
(36, '2026_05_24_000001_add_meta_to_order_items_table', 3);

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
CREATE TABLE IF NOT EXISTS `notifications` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NOT NULL,
  `title` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'info',
  `related_type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `related_id` bigint DEFAULT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `notifications_user_id_foreign` (`user_id`)
) ENGINE=MyISAM AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
(25, 8, 'Đặt lịch được xác nhận', 'Huấn luyện viên Nguyễn Thị B đã xác nhận lịch hẹn của bạn. Lịch: 31/01/2026 | 21:00 (Tối)', 'booking', 'trainer', 10, 1, '2026-01-22 05:40:59', '2026-01-22 05:41:29'),
(26, 1, 'Đặt lớp thành công', 'abc • thứ 2,6,7 | 06:00 AM', 'success', 'class', 8, 0, '2026-04-27 04:55:34', '2026-04-27 04:55:34'),
(27, 8, 'Yêu cầu thuê HLV đã tạo', 'HLV Lê Văn A • 30/04/2026 | 06:00', 'booking', 'trainer', 7, 0, '2026-04-27 08:00:05', '2026-04-27 08:00:05'),
(28, 8, 'Đặt lịch được xác nhận', 'Huấn luyện viên Lê Văn A đã xác nhận lịch hẹn của bạn. Lịch: 30/04/2026 | 06:00', 'booking', 'trainer', 11, 0, '2026-04-27 08:00:26', '2026-04-27 08:00:26'),
(29, 9, 'Đặt lớp thành công', 'Gym & Fitness • Thứ 2-7 | 09:00', 'success', 'class', 6, 0, '2026-05-09 08:53:45', '2026-05-09 08:53:45');

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
CREATE TABLE IF NOT EXISTS `orders` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NOT NULL,
  `total_amount` decimal(10,0) NOT NULL,
  `payment_method` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('pending','completed','cancelled') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `orders_user_id_foreign` (`user_id`)
) ENGINE=MyISAM AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
(15, 8, 275000, 'bank_transfer', 'completed', '2026-01-22 05:39:56', '2026-01-22 05:39:56'),
(16, 1, 109999, 'bank_transfer', 'completed', '2026-04-27 04:55:34', '2026-04-27 04:55:34'),
(17, 1, 308000, 'bank_transfer', 'completed', '2026-04-27 08:00:05', '2026-04-27 08:00:05'),
(18, 1, 99000, 'bank_transfer', 'completed', '2026-05-09 08:53:45', '2026-05-09 08:53:45'),
(19, 8, 1, 'vnpay_sandbox', 'pending', '2026-05-24 04:27:30', '2026-05-24 04:27:30'),
(20, 8, 1, 'vnpay_sandbox', 'pending', '2026-05-24 04:27:38', '2026-05-24 04:27:38'),
(21, 8, 1, 'vnpay_sandbox', 'pending', '2026-05-24 04:28:30', '2026-05-24 04:28:30'),
(22, 8, 1, 'vnpay_sandbox', 'pending', '2026-05-24 04:28:33', '2026-05-24 04:28:33'),
(23, 8, 1, 'vnpay_sandbox', 'pending', '2026-05-24 04:28:34', '2026-05-24 04:28:34'),
(24, 8, 275000, 'vnpay_sandbox', 'pending', '2026-05-24 05:52:51', '2026-05-24 05:52:51'),
(25, 8, 275000, 'vnpay_sandbox', 'pending', '2026-05-24 05:53:18', '2026-05-24 05:53:18'),
(26, 8, 275000, 'vnpay_sandbox', 'pending', '2026-05-24 05:53:31', '2026-05-24 05:53:31'),
(27, 8, 275000, 'vnpay_sandbox', 'pending', '2026-05-24 05:55:22', '2026-05-24 05:55:22'),
(28, 8, 275000, 'vnpay_sandbox', 'pending', '2026-05-24 06:42:39', '2026-05-24 06:42:39'),
(29, 8, 275000, 'vnpay_sandbox', 'pending', '2026-05-24 06:43:50', '2026-05-24 06:43:50'),
(30, 8, 275000, 'vnpay_sandbox', 'pending', '2026-05-24 06:46:53', '2026-05-24 06:46:53');

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

DROP TABLE IF EXISTS `order_items`;
CREATE TABLE IF NOT EXISTS `order_items` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `order_id` bigint UNSIGNED NOT NULL,
  `item_id` bigint NOT NULL,
  `item_name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `price` decimal(10,0) NOT NULL,
  `meta` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `order_items_order_id_foreign` (`order_id`)
) ENGINE=MyISAM AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `order_items`
--

INSERT INTO `order_items` (`id`, `order_id`, `item_id`, `item_name`, `item_type`, `price`, `meta`, `created_at`, `updated_at`) VALUES
(1, 1, 7, 'HLV Lê Văn A', 'trainer', 280000, NULL, NULL, NULL),
(2, 2, 7, 'HLV Lê Văn A', 'trainer', 280000, NULL, NULL, NULL),
(3, 3, 1, 'Boxing', 'class', 100000, NULL, NULL, NULL),
(4, 4, 2, 'Yoga', 'class', 80000, NULL, NULL, NULL),
(5, 5, 3, 'Strength Training', 'class', 150000, NULL, NULL, NULL),
(6, 6, 2, 'HLV Nguyễn Thị B', 'trainer', 250000, NULL, NULL, NULL),
(7, 7, 6, 'Gym & Fitness', 'class', 90000, NULL, NULL, NULL),
(8, 8, 7, 'HLV Lê Văn A', 'trainer', 280000, NULL, NULL, NULL),
(9, 9, 7, 'HLV Lê Văn A', 'trainer', 280000, NULL, NULL, NULL),
(10, 10, 5, 'Wrestling & MMA', 'class', 180000, NULL, NULL, NULL),
(11, 11, 7, 'HLV Lê Văn A', 'trainer', 280000, NULL, NULL, NULL),
(12, 12, 7, 'HLV Lê Văn A', 'trainer', 280000, NULL, NULL, NULL),
(13, 13, 7, 'HLV Lê Văn A', 'trainer', 280000, NULL, NULL, NULL),
(14, 14, 7, 'HLV Lê Văn A', 'trainer', 280000, NULL, NULL, NULL),
(15, 15, 2, 'HLV Nguyễn Thị B', 'trainer', 250000, NULL, NULL, NULL),
(16, 16, 8, 'abc', 'class', 99999, NULL, NULL, NULL),
(17, 17, 7, 'HLV Lê Văn A', 'trainer', 280000, NULL, NULL, NULL),
(18, 18, 6, 'Gym & Fitness', 'class', 90000, NULL, NULL, NULL),
(19, 19, 9, 'a', 'class', 1, NULL, '2026-05-24 04:27:30', '2026-05-24 04:27:30'),
(20, 20, 9, 'a', 'class', 1, NULL, '2026-05-24 04:27:38', '2026-05-24 04:27:38'),
(21, 21, 9, 'a', 'class', 1, NULL, '2026-05-24 04:28:30', '2026-05-24 04:28:30'),
(22, 22, 9, 'a', 'class', 1, NULL, '2026-05-24 04:28:33', '2026-05-24 04:28:33'),
(23, 23, 9, 'a', 'class', 1, NULL, '2026-05-24 04:28:34', '2026-05-24 04:28:34'),
(24, 24, 2, 'HLV Nguyễn Thị B', 'trainer', 250000, '{\"id\": 2, \"name\": \"HLV Nguyễn Thị B\", \"type\": \"trainer\", \"price\": 250000, \"memberId\": null, \"quantity\": null, \"schedule\": \"30/05/2026 | 09:00\", \"schedules\": null, \"memberName\": null, \"memberEmail\": null, \"bookedForMember\": false}', '2026-05-24 05:52:51', '2026-05-24 05:52:51'),
(25, 25, 2, 'HLV Nguyễn Thị B', 'trainer', 250000, '{\"id\": 2, \"name\": \"HLV Nguyễn Thị B\", \"type\": \"trainer\", \"price\": 250000, \"memberId\": null, \"quantity\": null, \"schedule\": \"30/05/2026 | 09:00\", \"schedules\": null, \"memberName\": null, \"memberEmail\": null, \"bookedForMember\": false}', '2026-05-24 05:53:18', '2026-05-24 05:53:18'),
(26, 26, 2, 'HLV Nguyễn Thị B', 'trainer', 250000, '{\"id\": 2, \"name\": \"HLV Nguyễn Thị B\", \"type\": \"trainer\", \"price\": 250000, \"memberId\": null, \"quantity\": null, \"schedule\": \"30/05/2026 | 09:00\", \"schedules\": null, \"memberName\": null, \"memberEmail\": null, \"bookedForMember\": false}', '2026-05-24 05:53:31', '2026-05-24 05:53:31'),
(27, 27, 2, 'HLV Nguyễn Thị B', 'trainer', 250000, '{\"id\": 2, \"name\": \"HLV Nguyễn Thị B\", \"type\": \"trainer\", \"price\": 250000, \"memberId\": null, \"quantity\": null, \"schedule\": \"30/05/2026 | 09:00\", \"schedules\": null, \"memberName\": null, \"memberEmail\": null, \"bookedForMember\": false}', '2026-05-24 05:55:22', '2026-05-24 05:55:22'),
(28, 28, 2, 'HLV Nguyễn Thị B', 'trainer', 250000, '{\"id\": 2, \"name\": \"HLV Nguyễn Thị B\", \"type\": \"trainer\", \"price\": 250000, \"memberId\": null, \"quantity\": null, \"schedule\": \"30/05/2026 | 09:00\", \"schedules\": null, \"memberName\": null, \"memberEmail\": null, \"bookedForMember\": false}', '2026-05-24 06:42:39', '2026-05-24 06:42:39'),
(29, 29, 2, 'HLV Nguyễn Thị B', 'trainer', 250000, '{\"id\": 2, \"name\": \"HLV Nguyễn Thị B\", \"type\": \"trainer\", \"price\": 250000, \"memberId\": null, \"quantity\": null, \"schedule\": \"30/05/2026 | 09:00\", \"schedules\": null, \"memberName\": null, \"memberEmail\": null, \"bookedForMember\": false}', '2026-05-24 06:43:50', '2026-05-24 06:43:50'),
(30, 30, 2, 'HLV Nguyễn Thị B', 'trainer', 250000, '{\"id\": 2, \"name\": \"HLV Nguyễn Thị B\", \"type\": \"trainer\", \"price\": 250000, \"memberId\": null, \"quantity\": null, \"schedule\": \"30/05/2026 | 09:00\", \"schedules\": null, \"memberName\": null, \"memberEmail\": null, \"bookedForMember\": false}', '2026-05-24 06:46:53', '2026-05-24 06:46:53');

-- --------------------------------------------------------

--
-- Table structure for table `packages`
--

DROP TABLE IF EXISTS `packages`;
CREATE TABLE IF NOT EXISTS `packages` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `duration` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `price` decimal(10,0) NOT NULL,
  `old_price` decimal(10,0) DEFAULT NULL,
  `benefits` int DEFAULT '0',
  `benefits_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `color` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'blue',
  `is_popular` tinyint(1) DEFAULT '0',
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
CREATE TABLE IF NOT EXISTS `password_reset_tokens` (
  `email` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pending_registrations`
--

DROP TABLE IF EXISTS `pending_registrations`;
CREATE TABLE IF NOT EXISTS `pending_registrations` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `verification_code` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
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
  `tokenable_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`)
) ENGINE=InnoDB AUTO_INCREMENT=107 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `personal_access_tokens`
--

INSERT INTO `personal_access_tokens` (`id`, `tokenable_type`, `tokenable_id`, `name`, `token`, `abilities`, `last_used_at`, `expires_at`, `created_at`, `updated_at`) VALUES
(1, 'App\\Models\\User', 1, 'auth_token', '75419db3c93ef6d89ba49e074fd7aed865a2e82dac1a1079e791526cb962f40c', '[\"*\"]', '2026-01-22 01:40:03', NULL, '2026-01-22 01:38:43', '2026-01-22 01:40:03'),
(59, 'App\\Models\\User', 1, 'auth_token', 'aa908d28e96fb4f580b8aa6b397e1deb0310ff99a7573905913e8697c949c2b1', '[\"*\"]', '2026-04-27 04:49:13', NULL, '2026-04-27 04:33:47', '2026-04-27 04:49:13'),
(60, 'App\\Models\\User', 8, 'auth_token', '3634d16d31a82a22ed16ec4b12a6f4805f80b6143ec08d696577b5e6587c4260', '[\"*\"]', NULL, NULL, '2026-04-27 04:52:03', '2026-04-27 04:52:03'),
(61, 'App\\Models\\User', 8, 'auth_token', '8b057ed124b9c4d8273f2ca98a05fcbef535aa698d74f2abf5920748b3eb554d', '[\"*\"]', NULL, NULL, '2026-04-27 04:52:06', '2026-04-27 04:52:06'),
(62, 'App\\Models\\User', 8, 'auth_token', '80b8ac35fa077471c52b63b9a7ed8aba1f379f501f937ee4dea0c260cb2b0808', '[\"*\"]', NULL, NULL, '2026-04-27 04:52:13', '2026-04-27 04:52:13'),
(63, 'App\\Models\\User', 3, 'auth_token', '05c6b8d0456e4bb195209a7efafaeea6eab61929c6972f2387f25c98709202b3', '[\"*\"]', '2026-04-27 04:53:00', NULL, '2026-04-27 04:52:44', '2026-04-27 04:53:00'),
(64, 'App\\Models\\User', 1, 'auth_token', 'ebe157cce7d77ef0c3556a81bf7e81bf897aef0086b8580f9305ccf7071707cc', '[\"*\"]', '2026-04-27 05:14:52', NULL, '2026-04-27 04:54:36', '2026-04-27 05:14:52'),
(65, 'App\\Models\\User', 1, 'auth_token', 'b09c7d951b0b31b9e80ed5dd592234ca7d8c12a3c8ba572df6cb19252ed2598d', '[\"*\"]', '2026-04-27 06:09:08', NULL, '2026-04-27 05:16:19', '2026-04-27 06:09:08'),
(66, 'App\\Models\\User', 1, 'auth_token', 'e77aceecc84593b5e391c123a90c4fac7bfa5d5af25ecfedce299517a2598c69', '[\"*\"]', '2026-04-27 07:28:20', NULL, '2026-04-27 06:10:54', '2026-04-27 07:28:20'),
(67, 'App\\Models\\User', 1, 'auth_token', '844c95136afd9fb7c511d00ce05c33399c1d682f26e9eb07042f156c2a953ed2', '[\"*\"]', '2026-04-27 07:38:26', NULL, '2026-04-27 07:31:33', '2026-04-27 07:38:26'),
(68, 'App\\Models\\User', 3, 'auth_token', 'c6e3b4ca66c5a65c9d2648af7857ba5dc1977b000375e218e0016d89b959a17e', '[\"*\"]', '2026-04-27 07:50:15', NULL, '2026-04-27 07:39:04', '2026-04-27 07:50:15'),
(69, 'App\\Models\\User', 1, 'auth_token', 'afa2bfceabdad876bc056128785164ebf141507c08d787ea40417748db896fca', '[\"*\"]', '2026-04-27 07:50:55', NULL, '2026-04-27 07:50:47', '2026-04-27 07:50:55'),
(70, 'App\\Models\\User', 3, 'auth_token', 'c8a528d2698c0e0ef5d1e8a696e942c0602876893fc5863616364370d6286445', '[\"*\"]', '2026-04-27 07:51:15', NULL, '2026-04-27 07:51:14', '2026-04-27 07:51:15'),
(71, 'App\\Models\\User', 16, 'auth_token', 'bf1d31fef515c300a4676834145c598fb04b406b71e2052733af798eaa00f96a', '[\"*\"]', '2026-04-27 07:51:51', NULL, '2026-04-27 07:51:34', '2026-04-27 07:51:51'),
(72, 'App\\Models\\User', 1, 'auth_token', '89aa03f2be41f83e5305e4f24d67efbc45692da1debf1e4abafc949a938f647e', '[\"*\"]', '2026-04-27 07:55:19', NULL, '2026-04-27 07:52:01', '2026-04-27 07:55:19'),
(73, 'App\\Models\\User', 1, 'auth_token', '91d71146752a043123e08a27b9fbe4c1e2326934c8f7731ba6ed620c500000a2', '[\"*\"]', '2026-04-27 07:56:23', NULL, '2026-04-27 07:56:17', '2026-04-27 07:56:23'),
(74, 'App\\Models\\User', 3, 'auth_token', '0354b7101970def9fed5b8e6459d10cf3832eb4f5bcdc6c6af89932bd4529df7', '[\"*\"]', '2026-04-27 07:57:08', NULL, '2026-04-27 07:56:46', '2026-04-27 07:57:08'),
(75, 'App\\Models\\User', 1, 'auth_token', '89140e5ef7a22e317d60bd6e5d7072554d966c270d0b0b68b27398b83f9df5d2', '[\"*\"]', '2026-04-27 08:31:14', NULL, '2026-04-27 07:57:18', '2026-04-27 08:31:14'),
(76, 'App\\Models\\User', 3, 'auth_token', '7d16a5f1e5166a98dac2ad3112aa1f63eea24c223e7d29aa3205d2a2ae1dd189', '[\"*\"]', '2026-04-27 08:31:50', NULL, '2026-04-27 08:31:40', '2026-04-27 08:31:50'),
(77, 'App\\Models\\User', 1, 'auth_token', '5511fdac18baf7aba974db54c7062893d02e877e28fe44605ccd64797a361792', '[\"*\"]', '2026-04-27 09:03:59', NULL, '2026-04-27 08:32:07', '2026-04-27 09:03:59'),
(78, 'App\\Models\\User', 1, 'auth_token', '9b5d37b888b04b66a75c07f714e1f21c7ef3be7ee63711bc6e8e1e779e1ee54b', '[\"*\"]', '2026-05-09 04:53:13', NULL, '2026-04-27 09:04:27', '2026-05-09 04:53:13'),
(79, 'App\\Models\\User', 1, 'debug_token', '51eec12b89284d6c76ae7d9f37a60c0639a8bcbca272dabd67bac780a38f2e1a', '[\"*\"]', '2026-05-09 06:13:37', NULL, '2026-05-09 04:57:31', '2026-05-09 06:13:37'),
(80, 'App\\Models\\User', 1, 'auth_token', '27f49fb33fec9d06433746767107939fc9e9efb94a5cc5c1dc65e918a5a48076', '[\"*\"]', '2026-05-09 05:29:28', NULL, '2026-05-09 05:09:14', '2026-05-09 05:29:28'),
(81, 'App\\Models\\User', 1, 'auth_token', 'c18b04ad037bb1511bbc3aecfc86eb70ceddc696c8a219b814e72eeee72a962b', '[\"*\"]', '2026-05-09 05:34:58', NULL, '2026-05-09 05:32:58', '2026-05-09 05:34:58'),
(82, 'App\\Models\\User', 3, 'auth_token', 'fbc9bbf82147414b1b12ddc56eecbd924a74dcf3176997f209d887b15c2f7ddb', '[\"*\"]', '2026-05-09 05:52:10', NULL, '2026-05-09 05:36:35', '2026-05-09 05:52:10'),
(83, 'App\\Models\\User', 3, 'auth_token', '403d55741c11445e394cf58389efabbaee2aec205c0ad9f78307c05ba0c114fd', '[\"*\"]', '2026-05-09 06:16:18', NULL, '2026-05-09 05:55:26', '2026-05-09 06:16:18'),
(84, 'App\\Models\\User', 3, 'auth_token', '6a202dce14215a3ef03c5ed5b352db1ce8995636c0b78faf24d37b855eb9d484', '[\"*\"]', '2026-05-09 06:37:03', NULL, '2026-05-09 06:17:20', '2026-05-09 06:37:03'),
(85, 'App\\Models\\User', 3, 'auth_token', '6083e17b51e9b8e00a0ddfcca61559c61fd62ff9d6e7e8e8f6610a3eaa86fa42', '[\"*\"]', '2026-05-09 06:38:37', NULL, '2026-05-09 06:38:31', '2026-05-09 06:38:37'),
(86, 'App\\Models\\User', 3, 'auth_token', 'c28e3e44bd99cfb68f5ccec5bf04913ef8b61e8aeb2d3beee0bf3e56f3f95098', '[\"*\"]', NULL, NULL, '2026-05-09 06:41:37', '2026-05-09 06:41:37'),
(87, 'App\\Models\\User', 3, 'auth_token', '4ddb196d266864539d36b2feadfb38549b744d5a787aecbb813b66eec01a38ec', '[\"*\"]', '2026-05-09 06:47:41', NULL, '2026-05-09 06:44:09', '2026-05-09 06:47:41'),
(88, 'App\\Models\\User', 3, 'auth_token', '515e39a4245d9046f374d75ec2b20a6219bed5e7071d44bc45ff7f2802bcbc7f', '[\"*\"]', NULL, NULL, '2026-05-09 06:44:45', '2026-05-09 06:44:45'),
(89, 'App\\Models\\User', 3, 'auth_token', 'ff3b843b20355e0c19fc6f19e822ae6d6a8e97dd8de2dfd3678497eb49ec84dc', '[\"*\"]', '2026-05-09 07:29:08', NULL, '2026-05-09 06:50:30', '2026-05-09 07:29:08'),
(90, 'App\\Models\\User', 3, 'auth_token', '0a7a11f8746762901c5242d0c0b3032e5a9a7bed77bee98999ee15cae5aebbb6', '[\"*\"]', '2026-05-09 07:45:42', NULL, '2026-05-09 07:31:08', '2026-05-09 07:45:42'),
(91, 'App\\Models\\User', 3, 'auth_token', '1bcbadeef0a4ca55552aa4364c7703876ab1f19618d8dee13db78373a2ab370f', '[\"*\"]', '2026-05-09 08:20:46', NULL, '2026-05-09 07:50:13', '2026-05-09 08:20:46'),
(92, 'App\\Models\\User', 1, 'auth_token', '75486cf458fc653f6c1140daaec85f9938037bbc167e1a0ceb9bbddf5a75ea48', '[\"*\"]', '2026-05-09 08:21:47', NULL, '2026-05-09 08:21:00', '2026-05-09 08:21:47'),
(93, 'App\\Models\\User', 3, 'auth_token', 'ae34fd5d86a3d646d83efbfd3e06cca22a461fcd5921e7f6976cb11fbcf6a87a', '[\"*\"]', '2026-05-09 08:22:05', NULL, '2026-05-09 08:21:59', '2026-05-09 08:22:05'),
(94, 'App\\Models\\User', 1, 'auth_token', 'e40a2753083a52435591e4e3a5d50ce253a94d9222c13e05c5dc7b1f05026b58', '[\"*\"]', '2026-05-09 08:22:27', NULL, '2026-05-09 08:22:23', '2026-05-09 08:22:27'),
(95, 'App\\Models\\User', 3, 'auth_token', 'c7daaffa04e080a8b99030cf8f506a7a94e1e4771f30048cf54e2706e4179276', '[\"*\"]', '2026-05-09 08:30:05', NULL, '2026-05-09 08:22:50', '2026-05-09 08:30:05'),
(96, 'App\\Models\\User', 1, 'auth_token', '25514f1428feced18b9d1443c658ada1388ffa7b4a0ac4056f04ddad9b31ee78', '[\"*\"]', '2026-05-09 11:12:12', NULL, '2026-05-09 08:30:23', '2026-05-09 11:12:12'),
(97, 'App\\Models\\User', 3, 'auth_token', 'a16cbf03b4066d5027bc5412338f12fb375c73cbf35ed98f9b0938ee1cc26c81', '[\"*\"]', '2026-05-09 11:12:49', NULL, '2026-05-09 11:12:37', '2026-05-09 11:12:49'),
(98, 'App\\Models\\User', 1, 'auth_token', 'f899e72024fb8383db6a2fb0b3f7eb2f1161da9d983299abae08a772fd4d9ed3', '[\"*\"]', '2026-05-09 11:15:54', NULL, '2026-05-09 11:13:06', '2026-05-09 11:15:54'),
(99, 'App\\Models\\User', 1, 'auth_token', '08be8764cfc76b855276f02d8fd48f00749717598e3c9ae65822c294b85325ce', '[\"*\"]', '2026-05-09 11:46:20', NULL, '2026-05-09 11:18:16', '2026-05-09 11:46:20'),
(100, 'App\\Models\\User', 16, 'auth_token', '9de66986f9940be7f46936ce6a304eccee119152eb99f63e003dd8bc5dd3c0c3', '[\"*\"]', '2026-05-09 11:48:29', NULL, '2026-05-09 11:47:06', '2026-05-09 11:48:29'),
(101, 'App\\Models\\User', 1, 'auth_token', '4a0c490ec4eead9949fa7aaccf02dac1d74483dee9450482fdf66c9ba0ea9e80', '[\"*\"]', '2026-05-24 03:06:04', NULL, '2026-05-09 11:48:54', '2026-05-24 03:06:04'),
(102, 'App\\Models\\User', 3, 'auth_token', '0e45a6f88df0f46def0be51d2f2f13f53abc50be621a381404db766cbf376e4e', '[\"*\"]', '2026-05-24 03:06:53', NULL, '2026-05-24 03:06:23', '2026-05-24 03:06:53'),
(103, 'App\\Models\\User', 16, 'auth_token', 'b48532bde0c61cf4354e58e7855ea842acd48110ab8cef0d66864b6949fa92c6', '[\"*\"]', '2026-05-24 03:09:49', NULL, '2026-05-24 03:07:14', '2026-05-24 03:09:49'),
(104, 'App\\Models\\User', 16, 'auth_token', 'b73aa0851c84f2e6427ba40d0e9c0d4ac0cb23e2f9c80d0c430787bda6a548bf', '[\"*\"]', '2026-05-24 03:15:56', NULL, '2026-05-24 03:15:47', '2026-05-24 03:15:56'),
(105, 'App\\Models\\User', 8, 'auth_token', 'a44c7ff9aa7b04245a6f4219dd8ff3051307ac4137a97e1e5c64549326f7bc33', '[\"*\"]', '2026-05-24 03:54:05', NULL, '2026-05-24 03:16:33', '2026-05-24 03:54:05'),
(106, 'App\\Models\\User', 8, 'auth_token', '059ad8c3e1f3e60af2279238dc1f4252d4784559a5c1a6285dd09940fdfcaf95', '[\"*\"]', '2026-05-24 06:46:53', NULL, '2026-05-24 04:27:15', '2026-05-24 06:46:53');

-- --------------------------------------------------------

--
-- Table structure for table `push_campaigns`
--

DROP TABLE IF EXISTS `push_campaigns`;
CREATE TABLE IF NOT EXISTS `push_campaigns` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `title` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `target_audience` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'all',
  `send_at` timestamp NULL DEFAULT NULL,
  `sent_at` timestamp NULL DEFAULT NULL,
  `status` enum('draft','scheduled','sent') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'draft',
  `recipient_count` int DEFAULT NULL,
  `success_count` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `refund_requests`
--

DROP TABLE IF EXISTS `refund_requests`;
CREATE TABLE IF NOT EXISTS `refund_requests` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `booking_id` bigint UNSIGNED NOT NULL,
  `member_id` bigint UNSIGNED NOT NULL,
  `reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `requested_amount` decimal(10,2) NOT NULL,
  `approved_amount` decimal(10,2) DEFAULT NULL,
  `status` enum('pending','approved','rejected','processed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `approved_by` bigint UNSIGNED DEFAULT NULL,
  `refund_method` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `processed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `session_notes`
--

DROP TABLE IF EXISTS `session_notes`;
CREATE TABLE IF NOT EXISTS `session_notes` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `booking_id` bigint UNSIGNED NOT NULL,
  `trainer_id` bigint UNSIGNED NOT NULL,
  `member_id` bigint UNSIGNED NOT NULL,
  `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `focus_areas` json DEFAULT NULL,
  `performance` int DEFAULT NULL,
  `next_focus` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `session_notes_booking_idx` (`booking_id`),
  KEY `session_notes_trainer_idx` (`trainer_id`),
  KEY `session_notes_member_idx` (`member_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `time_offs`
--

DROP TABLE IF EXISTS `time_offs`;
CREATE TABLE IF NOT EXISTS `time_offs` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `trainer_id` bigint UNSIGNED NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `reason` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('pending','approved','rejected','cancelled') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `approved_by` bigint UNSIGNED DEFAULT NULL,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `approved_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `trainers`
--

DROP TABLE IF EXISTS `trainers`;
CREATE TABLE IF NOT EXISTS `trainers` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `spec` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `exp` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `rating` decimal(2,1) DEFAULT '5.0',
  `availability` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `price` decimal(10,0) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `trainers`
--

INSERT INTO `trainers` (`id`, `name`, `email`, `phone`, `image`, `spec`, `exp`, `rating`, `availability`, `price`, `created_at`, `updated_at`) VALUES
(2, 'Nguyễn Thị B', 'trainer2@gmail.com', NULL, NULL, 'Yoga & Pilates', '6 năm', 4.8, 'Sáng, Chiều, Tối', 250000, '2026-01-22 08:38:17', '2026-01-22 08:38:17'),
(7, 'Lê Văn A', 'trainer1@gmail.com', '', NULL, 'Gym & Fitness', '7 năm', 5.0, 'Sáng, Chiều, Tối', 280000, '2026-01-22 02:42:12', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `trainer_earnings`
--

DROP TABLE IF EXISTS `trainer_earnings`;
CREATE TABLE IF NOT EXISTS `trainer_earnings` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `trainer_id` bigint UNSIGNED NOT NULL,
  `total_earnings` decimal(15,2) NOT NULL DEFAULT '0.00',
  `completed_sessions` int NOT NULL DEFAULT '0',
  `pending_sessions` int NOT NULL DEFAULT '0',
  `cancelled_sessions` int NOT NULL DEFAULT '0',
  `withdrawal_balance` decimal(15,2) NOT NULL DEFAULT '0.00',
  `commission_rate` decimal(5,2) NOT NULL DEFAULT '20.00',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `trainer_earnings_trainer_unique` (`trainer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `trainer_earnings`
--

INSERT INTO `trainer_earnings` (`id`, `trainer_id`, `total_earnings`, `completed_sessions`, `pending_sessions`, `cancelled_sessions`, `withdrawal_balance`, `commission_rate`, `created_at`, `updated_at`) VALUES
(1, 16, 0.00, 0, 0, 0, 0.00, 20.00, '2026-04-27 11:33:03', '2026-04-27 11:33:03'),
(2, 3, 0.00, 0, 0, 0, 0.00, 20.00, '2026-04-27 11:33:03', '2026-04-27 11:33:03');

-- --------------------------------------------------------

--
-- Table structure for table `transaction_reports`
--

DROP TABLE IF EXISTS `transaction_reports`;
CREATE TABLE IF NOT EXISTS `transaction_reports` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `date` date NOT NULL,
  `member_id` bigint UNSIGNED DEFAULT NULL,
  `trainer_id` bigint UNSIGNED DEFAULT NULL,
  `type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `details` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `transaction_reports_date_type_idx` (`date`,`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `avatar` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'user',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `remember_token` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `email_verified_at`, `password`, `avatar`, `role`, `phone`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 'Quản Trị Viên', 'admin@gmail.com', '2026-01-22 08:38:17', '$2y$12$vTDCwgp3A8dTtJ8i3FYrKeR.YGkGLhyydXEmy9xd.6QYrcmBd8CeW', '/storage/avatars/pke6eAkPPoeES1uu9QX8027cAVNwbdxJV7dFCoFg.jpg', 'admin', NULL, NULL, '2026-01-22 08:38:17', '2026-05-09 08:21:48'),
(3, 'Nguyễn Thị B', 'trainer2@gmail.com', '2026-01-22 08:38:17', '$2y$12$i1Fi6JTtCNd/olJDC5NQ5.HN.oA9LPQl7fn96NYFPv0q0Yktd9Jvy', '/storage/avatars/TukpcW0hSAGyvKhoWCuLHpHqqjMGZym2MJaDvjik.jpg', 'trainer', NULL, NULL, '2026-01-22 08:38:17', '2026-05-09 07:50:41'),
(8, 'Thành viên 1', 'member1@gmail.com', '2026-01-22 08:38:17', '$2y$12$w4ppZRv2mTsDG/TR5I9QKu5ARtvgdOedU2ABLABdsTbWqE81g9vmm', NULL, 'member', '000009999', NULL, '2026-01-22 08:38:17', '2026-05-24 03:16:48'),
(9, 'Thành viên 2', 'member2@gmail.com', '2026-01-22 08:38:17', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', NULL, 'member', '0999999999', NULL, '2026-01-22 08:38:17', '2026-04-27 07:27:24'),
(16, 'Lê Văn A', 'trainer1@gmail.com', NULL, '$2y$12$H2Q1sc21ZRVrQ6N1nnyZCOeomq/1jmlIsYYzQiRtW4E4UOIJy3l2C', '/storage/avatars/zpI79QlBaIQaUgOlxSJUw1cLsiDGEORYMEEFS7SL.jpg', 'trainer', '', NULL, '2026-01-22 02:42:12', '2026-05-09 11:47:17');

-- --------------------------------------------------------

--
-- Table structure for table `vouchers`
--

DROP TABLE IF EXISTS `vouchers`;
CREATE TABLE IF NOT EXISTS `vouchers` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `code` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `discount_type` enum('percentage','fixed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `discount_value` decimal(10,2) NOT NULL,
  `max_uses` int DEFAULT NULL,
  `used_count` int NOT NULL DEFAULT '0',
  `min_order_amount` decimal(10,2) DEFAULT NULL,
  `valid_from` date NOT NULL,
  `valid_until` date NOT NULL,
  `applicable_to` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'all',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `vouchers_code_unique` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `waitlist_entries`
--

DROP TABLE IF EXISTS `waitlist_entries`;
CREATE TABLE IF NOT EXISTS `waitlist_entries` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `member_id` bigint UNSIGNED NOT NULL,
  `item_type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_id` bigint NOT NULL,
  `position` int NOT NULL DEFAULT '1',
  `notified_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `waitlist_entries_unique` (`member_id`,`item_type`,`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `working_hours`
--

DROP TABLE IF EXISTS `working_hours`;
CREATE TABLE IF NOT EXISTS `working_hours` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `trainer_id` bigint UNSIGNED NOT NULL,
  `day_of_week` int NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `working_hours_trainer_day_unique` (`trainer_id`,`day_of_week`)
) ENGINE=InnoDB AUTO_INCREMENT=50 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `working_hours`
--

INSERT INTO `working_hours` (`id`, `trainer_id`, `day_of_week`, `start_time`, `end_time`, `is_active`, `created_at`, `updated_at`) VALUES
(36, 16, 0, '09:00:00', '17:00:00', 0, '2026-04-27 07:51:51', '2026-04-27 07:51:51'),
(37, 16, 1, '06:00:00', '20:00:00', 0, '2026-04-27 07:51:51', '2026-04-27 07:51:51'),
(38, 16, 2, '06:00:00', '20:00:00', 0, '2026-04-27 07:51:51', '2026-04-27 07:51:51'),
(39, 16, 3, '06:00:00', '20:00:00', 0, '2026-04-27 07:51:51', '2026-04-27 07:51:51'),
(40, 16, 4, '06:00:00', '20:00:00', 0, '2026-04-27 07:51:51', '2026-04-27 07:51:51'),
(41, 16, 5, '06:00:00', '20:00:00', 0, '2026-04-27 07:51:51', '2026-04-27 07:51:51'),
(42, 16, 6, '06:00:00', '20:00:00', 0, '2026-04-27 07:51:51', '2026-04-27 07:51:51'),
(43, 3, 0, '15:30:00', '22:00:00', 1, '2026-04-27 07:57:05', '2026-04-27 07:57:05'),
(44, 3, 1, '06:00:00', '20:00:00', 1, '2026-04-27 07:57:05', '2026-04-27 07:57:05'),
(45, 3, 2, '06:00:00', '20:00:00', 1, '2026-04-27 07:57:05', '2026-04-27 07:57:05'),
(46, 3, 3, '06:00:00', '20:00:00', 1, '2026-04-27 07:57:05', '2026-04-27 07:57:05'),
(47, 3, 4, '06:00:00', '20:00:00', 0, '2026-04-27 07:57:05', '2026-04-27 07:57:05'),
(48, 3, 5, '06:00:00', '20:00:00', 1, '2026-04-27 07:57:05', '2026-04-27 07:57:05'),
(49, 3, 6, '06:00:00', '20:00:00', 1, '2026-04-27 07:57:05', '2026-04-27 07:57:05');

-- --------------------------------------------------------

--
-- Table structure for table `workout_plans`
--

DROP TABLE IF EXISTS `workout_plans`;
CREATE TABLE IF NOT EXISTS `workout_plans` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `trainer_id` bigint UNSIGNED NOT NULL,
  `member_id` bigint UNSIGNED NOT NULL,
  `title` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `duration` int DEFAULT NULL,
  `difficulty` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `workout_plans_trainer_idx` (`trainer_id`),
  KEY `workout_plans_member_idx` (`member_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `workout_schedules`
--

DROP TABLE IF EXISTS `workout_schedules`;
CREATE TABLE IF NOT EXISTS `workout_schedules` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `date` date NOT NULL,
  `time` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `duration` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
