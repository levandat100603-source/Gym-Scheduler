-- MySQL dump 10.13  Distrib 8.0.19, for Win64 (x86_64)
--
-- Host: webquanlyphongtro-levandat100603-f917.j.aivencloud.com    Database: gymflutter
-- ------------------------------------------------------
-- Server version	8.0.45

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ '525d81bf-3054-11f1-9a22-121e8c365290:1-346,
9267ba10-344c-11f1-bf66-be9e3d0a9a3a:1-4175,
b94cc064-14c7-11f1-b3be-02c0756ab157:1-45,
e0efd54b-18a6-11f1-8368-c6cff3b95b24:1-163';

--
-- Table structure for table `booking_cancellations`
--

DROP TABLE IF EXISTS `booking_cancellations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `booking_cancellations` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `booking_id` bigint unsigned NOT NULL,
  `member_id` bigint unsigned NOT NULL,
  `reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `cancelled_at` timestamp NOT NULL,
  `penalty` decimal(10,2) DEFAULT NULL,
  `refund_amount` decimal(10,2) DEFAULT NULL,
  `status` enum('pending','approved','rejected','processed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `booking_cancellations`
--

LOCK TABLES `booking_cancellations` WRITE;
/*!40000 ALTER TABLE `booking_cancellations` DISABLE KEYS */;
/*!40000 ALTER TABLE `booking_cancellations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `booking_classes`
--

DROP TABLE IF EXISTS `booking_classes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `booking_classes` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned DEFAULT NULL,
  `class_id` bigint unsigned DEFAULT NULL,
  `schedule` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `booking_classes_user_class_schedule_unique` (`user_id`,`class_id`,`schedule`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `booking_classes`
--

LOCK TABLES `booking_classes` WRITE;
/*!40000 ALTER TABLE `booking_classes` DISABLE KEYS */;
INSERT INTO `booking_classes` VALUES (1,8,1,'thứ 2 | 06:00','confirmed','2026-01-22 03:16:49',NULL),(2,8,2,'thứ 2 | 07:00','confirmed','2026-01-22 03:23:38','2026-01-22 03:23:38'),(3,8,2,'thứ 3 | 07:00','confirmed','2026-01-22 03:23:38','2026-01-22 03:23:38'),(4,8,2,'thứ 5 | 07:00','confirmed','2026-01-22 03:23:38','2026-01-22 03:23:38'),(5,8,3,'thứ 3 | 18:00','confirmed','2026-01-22 04:15:09','2026-01-22 04:15:09'),(6,8,3,'thứ 5 | 18:00','confirmed','2026-01-22 04:15:09','2026-01-22 04:15:09'),(7,8,3,'thứ 7 | 18:00','confirmed','2026-01-22 04:15:09','2026-01-22 04:15:09'),(8,8,6,'thứ 2-7 | 09:00','confirmed','2026-01-22 04:52:01','2026-01-22 04:52:01'),(9,8,5,'thứ 7 | 19:00','confirmed','2026-01-22 04:57:25','2026-01-22 04:57:25'),(10,1,8,'thứ 2,6,7 | 06:00 AM','confirmed','2026-04-27 04:55:34','2026-04-27 04:55:34'),(11,9,6,'Thứ 2-7 | 09:00','confirmed','2026-05-09 08:53:45','2026-05-09 08:53:45');
/*!40000 ALTER TABLE `booking_classes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `booking_trainers`
--

DROP TABLE IF EXISTS `booking_trainers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `booking_trainers` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned DEFAULT NULL,
  `trainer_id` bigint unsigned DEFAULT NULL,
  `schedule_info` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `booking_trainers`
--

LOCK TABLES `booking_trainers` WRITE;
/*!40000 ALTER TABLE `booking_trainers` DISABLE KEYS */;
INSERT INTO `booking_trainers` VALUES (1,8,7,'22/01/2026 | 21:00 (Tối)','rejected','2026-01-22 03:04:24','2026-01-22 03:51:51'),(2,8,7,'22/01/2026 | 19:30 (Tối)','confirmed','2026-01-22 03:10:51','2026-01-22 03:51:41'),(3,8,2,'22/01/2026 | 21:00 (Tối)','confirmed','2026-01-22 04:17:19','2026-01-22 04:17:35'),(4,8,7,'28/01/2026 | 09:00 (Sáng)','confirmed','2026-01-22 04:52:58','2026-01-22 04:53:09'),(5,8,7,'31/01/2026 | 19:30 (Tối)','confirmed','2026-01-22 04:55:16','2026-01-22 04:55:37'),(6,8,7,'30/01/2026 | 15:00 (Chiều)','confirmed','2026-01-22 04:57:57','2026-01-22 04:58:08'),(7,8,7,'28/01/2026 | 16:30 (Chiều)','confirmed','2026-01-22 05:01:09','2026-01-22 05:01:14'),(8,8,7,'28/01/2026 | 13:30 (Chiều)','confirmed','2026-01-22 05:04:42','2026-01-22 05:05:39'),(9,8,7,'28/01/2026 | 21:00 (Tối)','rejected','2026-01-22 05:13:23','2026-05-26 17:37:45'),(10,8,2,'31/01/2026 | 21:00 (Tối)','confirmed','2026-01-22 05:39:56','2026-01-22 05:40:59'),(11,8,7,'30/04/2026 | 06:00','confirmed','2026-04-27 08:00:05','2026-04-27 08:00:26'),(12,8,7,'28/05/2026 | 06:00','pending','2026-05-24 18:30:35',NULL),(13,8,2,'27/05/2026 | 06:00','pending','2026-05-26 15:33:14',NULL);
/*!40000 ALTER TABLE `booking_trainers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dashboard_settings`
--

DROP TABLE IF EXISTS `dashboard_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dashboard_settings` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `monthly_revenue_target` decimal(14,0) NOT NULL DEFAULT '50000000',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dashboard_settings`
--

LOCK TABLES `dashboard_settings` WRITE;
/*!40000 ALTER TABLE `dashboard_settings` DISABLE KEYS */;
INSERT INTO `dashboard_settings` VALUES (1,50000000,'2026-05-26 15:52:50','2026-05-26 15:52:50');
/*!40000 ALTER TABLE `dashboard_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gym_classes`
--

DROP TABLE IF EXISTS `gym_classes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gym_classes` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gym_classes`
--

LOCK TABLES `gym_classes` WRITE;
/*!40000 ALTER TABLE `gym_classes` DISABLE KEYS */;
INSERT INTO `gym_classes` VALUES (1,'Boxing','Nguyễn Văn A','06:00','60 phút','Thứ 2, 4, 6','Phòng 1',20,13,100000,'2026-01-22 08:38:17','2026-01-22 08:38:17'),(2,'Yoga','Nguyễn Thị B','07:00','75 phút','Thứ 2, 3, 5','Phòng 2',25,21,80000,'2026-01-22 08:38:17','2026-01-22 08:38:17'),(3,'Strength Training','Trần Văn C','18:00','90 phút','Thứ 3, 5, 7','Phòng 3',15,11,150000,'2026-01-22 08:38:17','2026-01-22 08:38:17'),(5,'Wrestling & MMA','Hoàng Văn E','19:00','90 phút','Thứ 4, 6, 7','Phòng 5',12,6,180000,'2026-01-22 08:38:17','2026-01-22 08:38:17'),(6,'Gym & Fitness','Võ Thị F','09:00','60 phút','Thứ 2-7','Phòng 1',40,37,90000,'2026-01-22 08:38:17','2026-01-22 08:38:17'),(7,'a','a','06:00 AM','1','2','a',3,1,2,'2026-01-22 02:49:42',NULL),(9,'a','Lê Văn A','06:00','1','T2, T3, T4','a',22,0,1,'2026-05-23 23:52:57',NULL),(10,'bbb','Nguyễn Thị B','14:00','90','CN','b',20,0,3333,'2026-05-23 23:59:43',NULL),(11,'cc','Lê Văn A','06:00','22','CN','c',22,0,1,'2026-05-24 00:29:57',NULL);
/*!40000 ALTER TABLE `gym_classes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `member_cards`
--

DROP TABLE IF EXISTS `member_cards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `member_cards` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `member_id` bigint unsigned NOT NULL,
  `card_number` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `qr_code` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `member_cards_member_unique` (`member_id`),
  UNIQUE KEY `member_cards_number_unique` (`card_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `member_cards`
--

LOCK TABLES `member_cards` WRITE;
/*!40000 ALTER TABLE `member_cards` DISABLE KEYS */;
/*!40000 ALTER TABLE `member_cards` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `members`
--

DROP TABLE IF EXISTS `members`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `members` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `members`
--

LOCK TABLES `members` WRITE;
/*!40000 ALTER TABLE `members` DISABLE KEYS */;
INSERT INTO `members` VALUES (11,'Thành viên 2','member2@gmail.com','0999999999','Standard','3','2026-04-27','2026-07-27',1200000,'inactive','2026-04-27 07:25:40','2026-04-27 07:27:24'),(12,'Thành viên 1','member1@gmail.com','000009999','a','2','2026-04-27','2026-06-27',1,'inactive','2026-04-27 07:26:41','2026-04-27 07:27:19');
/*!40000 ALTER TABLE `members` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `membership_freezes`
--

DROP TABLE IF EXISTS `membership_freezes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `membership_freezes` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `member_id` bigint unsigned NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `reason` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('pending','approved','active','expired') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `approved_by` bigint unsigned DEFAULT NULL,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `membership_freezes`
--

LOCK TABLES `membership_freezes` WRITE;
/*!40000 ALTER TABLE `membership_freezes` DISABLE KEYS */;
/*!40000 ALTER TABLE `membership_freezes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES (1,'0001_01_01_000000_create_users_table',1),(2,'0001_01_01_000001_create_cache_table',1),(3,'0001_01_01_000002_create_jobs_table',1),(4,'2025_11_16_124504_create_personal_access_tokens_table',1),(5,'2025_11_16_125248_add_role_and_phone_to_users_table',1),(6,'2025_11_16_130913_create_workout_schedules_table',1),(7,'2026_01_07_211708_add_role_to_users_table',1),(8,'2026_01_08_001923_create_gym_tables',1),(9,'2026_01_21_000001_create_booking_classes_table',1),(10,'2026_01_22_000000_add_email_verification_to_users',1),(11,'2026_01_22_000001_create_pending_registrations_table',1),(12,'2026_01_22_095957_add_schedule_info_to_booking_trainers_table',1),(13,'2026_01_22_100303_create_orders_and_order_items_tables',1),(14,'2026_01_22_101432_add_schedule_to_booking_classes_table',1),(15,'2026_01_22_101900_update_booking_classes_unique',1),(16,'2026_01_22_104444_add_email_phone_to_trainers_table',1),(17,'2026_01_22_104921_create_notifications_table',1),(18,'2026_04_13_120000_add_membership_columns_to_users_table',1),(19,'2026_04_13_120100_backfill_membership_from_members_to_users',1),(20,'2026_04_13_230000_create_password_reset_tokens_if_missing',1),(21,'2026_04_26_000001_create_working_hours_table',1),(22,'2026_04_26_000002_create_time_offs_table',1),(23,'2026_04_26_000003_create_session_notes_table',1),(24,'2026_04_26_000004_create_workout_plans_table',1),(25,'2026_04_26_000005_create_trainer_earnings_table',1),(26,'2026_04_26_000006_create_waitlist_entries_table',1),(27,'2026_04_26_000007_create_membership_freezes_table',1),(28,'2026_04_26_000008_create_member_cards_table',1),(29,'2026_04_26_000009_create_booking_cancellations_table',1),(30,'2026_04_26_000010_create_vouchers_table',1),(31,'2026_04_26_000011_create_push_campaigns_table',1),(32,'2026_04_26_000012_create_refund_requests_table',1),(33,'2026_04_26_000013_create_transaction_reports_table',1),(34,'2026_04_27_000014_create_booking_trainers_table_if_missing',1),(35,'2026_05_09_000001_add_avatar_to_users_table',2),(36,'2026_05_24_000001_add_meta_to_order_items_table',3),(37,'2026_05_26_000000_create_user_carts_table',4),(38,'2026_05_26_000001_create_dashboard_settings_table',5);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (1,8,'Đặt lịch được xác nhận','Huấn luyện viên Lê Văn A đã xác nhận lịch hẹn của bạn. Lịch: 22/01/2026 | 19:30 (Tối)','booking','trainer',2,1,'2026-01-22 03:51:41','2026-01-22 05:41:29'),(2,8,'Đặt lịch bị từ chối','Huấn luyện viên Lê Văn A đã từ chối lịch hẹn của bạn. Lịch: 22/01/2026 | 21:00 (Tối)','booking','trainer',1,1,'2026-01-22 03:51:51','2026-01-22 05:41:29'),(3,8,'Đặt lịch được xác nhận','Huấn luyện viên Nguyễn Thị B đã xác nhận lịch hẹn của bạn. Lịch: 22/01/2026 | 21:00 (Tối)','booking','trainer',3,1,'2026-01-22 04:17:35','2026-01-22 05:41:29'),(4,8,'Đặt lớp thành công','Boxing • thứ 2 | 06:00','success','class',1,1,'2026-01-22 04:28:57','2026-01-22 05:41:29'),(5,8,'Đặt lớp thành công','Yoga • thứ 2 | 07:00','success','class',2,1,'2026-01-22 04:28:57','2026-01-22 05:41:29'),(6,8,'Đặt lớp thành công','Yoga • thứ 3 | 07:00','success','class',2,1,'2026-01-22 04:28:57','2026-01-22 05:41:29'),(7,8,'Đặt lớp thành công','Yoga • thứ 5 | 07:00','success','class',2,1,'2026-01-22 04:28:57','2026-01-22 05:41:29'),(8,8,'Đặt lớp thành công','Strength Training • thứ 3 | 18:00','success','class',3,1,'2026-01-22 04:28:57','2026-01-22 05:41:29'),(9,8,'Đặt lớp thành công','Strength Training • thứ 5 | 18:00','success','class',3,1,'2026-01-22 04:28:57','2026-01-22 05:41:29'),(10,8,'Đặt lớp thành công','Strength Training • thứ 7 | 18:00','success','class',3,1,'2026-01-22 04:28:57','2026-01-22 05:41:29'),(11,8,'Đặt lớp thành công','Gym & Fitness • thứ 2-7 | 09:00','success','class',6,1,'2026-01-22 04:52:01','2026-01-22 05:41:29'),(12,8,'Yêu cầu thuê HLV đã tạo','HLV Lê Văn A • 28/01/2026 | 09:00 (Sáng)','booking','trainer',7,1,'2026-01-22 04:52:58','2026-01-22 05:41:29'),(13,8,'Đặt lịch được xác nhận','Huấn luyện viên Lê Văn A đã xác nhận lịch hẹn của bạn. Lịch: 28/01/2026 | 09:00 (Sáng)','booking','trainer',4,1,'2026-01-22 04:53:09','2026-01-22 05:41:29'),(14,8,'Yêu cầu thuê HLV đã tạo','HLV Lê Văn A • 31/01/2026 | 19:30 (Tối)','booking','trainer',7,1,'2026-01-22 04:55:16','2026-01-22 05:41:29'),(15,8,'Đặt lịch được xác nhận','Huấn luyện viên Lê Văn A đã xác nhận lịch hẹn của bạn. Lịch: 31/01/2026 | 19:30 (Tối)','booking','trainer',5,1,'2026-01-22 04:55:37','2026-01-22 05:41:29'),(16,8,'Đặt lớp thành công','Wrestling & MMA • thứ 7 | 19:00','success','class',5,1,'2026-01-22 04:57:25','2026-01-22 05:41:29'),(17,8,'Yêu cầu thuê HLV đã tạo','HLV Lê Văn A • 30/01/2026 | 15:00 (Chiều)','booking','trainer',7,1,'2026-01-22 04:57:57','2026-01-22 05:41:29'),(18,8,'Đặt lịch được xác nhận','Huấn luyện viên Lê Văn A đã xác nhận lịch hẹn của bạn. Lịch: 30/01/2026 | 15:00 (Chiều)','booking','trainer',6,1,'2026-01-22 04:58:08','2026-01-22 05:41:29'),(19,8,'Yêu cầu thuê HLV đã tạo','HLV Lê Văn A • 28/01/2026 | 16:30 (Chiều)','booking','trainer',7,1,'2026-01-22 05:01:09','2026-01-22 05:41:29'),(20,8,'Đặt lịch được xác nhận','Huấn luyện viên Lê Văn A đã xác nhận lịch hẹn của bạn. Lịch: 28/01/2026 | 16:30 (Chiều)','booking','trainer',7,1,'2026-01-22 05:01:14','2026-01-22 05:41:29'),(21,8,'Yêu cầu thuê HLV đã tạo','HLV Lê Văn A • 28/01/2026 | 13:30 (Chiều)','booking','trainer',7,1,'2026-01-22 05:04:42','2026-01-22 05:41:29'),(22,8,'Đặt lịch được xác nhận','Huấn luyện viên Lê Văn A đã xác nhận lịch hẹn của bạn. Lịch: 28/01/2026 | 13:30 (Chiều)','booking','trainer',8,1,'2026-01-22 05:05:39','2026-01-22 05:41:29'),(23,8,'Yêu cầu thuê HLV đã tạo','HLV Lê Văn A • 28/01/2026 | 21:00 (Tối)','booking','trainer',7,1,'2026-01-22 05:13:23','2026-01-22 05:41:29'),(24,8,'Yêu cầu thuê HLV đã tạo','HLV Nguyễn Thị B • 31/01/2026 | 21:00 (Tối)','booking','trainer',2,1,'2026-01-22 05:39:56','2026-01-22 05:41:29'),(25,8,'Đặt lịch được xác nhận','Huấn luyện viên Nguyễn Thị B đã xác nhận lịch hẹn của bạn. Lịch: 31/01/2026 | 21:00 (Tối)','booking','trainer',10,1,'2026-01-22 05:40:59','2026-01-22 05:41:29'),(26,1,'Đặt lớp thành công','abc • thứ 2,6,7 | 06:00 AM','success','class',8,0,'2026-04-27 04:55:34','2026-04-27 04:55:34'),(27,8,'Yêu cầu thuê HLV đã tạo','HLV Lê Văn A • 30/04/2026 | 06:00','booking','trainer',7,0,'2026-04-27 08:00:05','2026-04-27 08:00:05'),(28,8,'Đặt lịch được xác nhận','Huấn luyện viên Lê Văn A đã xác nhận lịch hẹn của bạn. Lịch: 30/04/2026 | 06:00','booking','trainer',11,0,'2026-04-27 08:00:26','2026-04-27 08:00:26'),(29,9,'Đặt lớp thành công','Gym & Fitness • Thứ 2-7 | 09:00','success','class',6,0,'2026-05-09 08:53:45','2026-05-09 08:53:45'),(30,8,'Yêu cầu thuê HLV đã tạo','HLV Lê Văn A • 28/05/2026 | 06:00','booking','trainer',7,0,'2026-05-24 18:30:35','2026-05-24 18:30:35'),(31,8,'Yêu cầu thuê HLV đã tạo','HLV Nguyễn Thị B • 27/05/2026 | 06:00','booking','trainer',2,0,'2026-05-26 15:33:14','2026-05-26 15:33:14'),(32,8,'Đặt lịch bị từ chối','Huấn luyện viên Lê Văn A đã từ chối lịch hẹn của bạn. Lịch: 28/01/2026 | 21:00 (Tối)','booking','trainer',9,0,'2026-05-26 17:37:46','2026-05-26 17:37:46');
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_items`
--

DROP TABLE IF EXISTS `order_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_items` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `order_id` bigint unsigned NOT NULL,
  `item_id` bigint NOT NULL,
  `item_name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `price` decimal(10,0) NOT NULL,
  `meta` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `order_items_order_id_foreign` (`order_id`)
) ENGINE=InnoDB AUTO_INCREMENT=50 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_items`
--

LOCK TABLES `order_items` WRITE;
/*!40000 ALTER TABLE `order_items` DISABLE KEYS */;
INSERT INTO `order_items` VALUES (1,1,7,'HLV Lê Văn A','trainer',280000,NULL,NULL,NULL),(2,2,7,'HLV Lê Văn A','trainer',280000,NULL,NULL,NULL),(3,3,1,'Boxing','class',100000,NULL,NULL,NULL),(4,4,2,'Yoga','class',80000,NULL,NULL,NULL),(5,5,3,'Strength Training','class',150000,NULL,NULL,NULL),(6,6,2,'HLV Nguyễn Thị B','trainer',250000,NULL,NULL,NULL),(7,7,6,'Gym & Fitness','class',90000,NULL,NULL,NULL),(8,8,7,'HLV Lê Văn A','trainer',280000,NULL,NULL,NULL),(9,9,7,'HLV Lê Văn A','trainer',280000,NULL,NULL,NULL),(10,10,5,'Wrestling & MMA','class',180000,NULL,NULL,NULL),(11,11,7,'HLV Lê Văn A','trainer',280000,NULL,NULL,NULL),(12,12,7,'HLV Lê Văn A','trainer',280000,NULL,NULL,NULL),(13,13,7,'HLV Lê Văn A','trainer',280000,NULL,NULL,NULL),(14,14,7,'HLV Lê Văn A','trainer',280000,NULL,NULL,NULL),(15,15,2,'HLV Nguyễn Thị B','trainer',250000,NULL,NULL,NULL),(16,16,8,'abc','class',99999,NULL,NULL,NULL),(17,17,7,'HLV Lê Văn A','trainer',280000,NULL,NULL,NULL),(18,18,6,'Gym & Fitness','class',90000,NULL,NULL,NULL),(19,19,9,'a','class',1,NULL,'2026-05-24 04:27:30','2026-05-24 04:27:30'),(20,20,9,'a','class',1,NULL,'2026-05-24 04:27:38','2026-05-24 04:27:38'),(21,21,9,'a','class',1,NULL,'2026-05-24 04:28:30','2026-05-24 04:28:30'),(22,22,9,'a','class',1,NULL,'2026-05-24 04:28:33','2026-05-24 04:28:33'),(23,23,9,'a','class',1,NULL,'2026-05-24 04:28:34','2026-05-24 04:28:34'),(24,24,2,'HLV Nguyễn Thị B','trainer',250000,'{\"id\": 2, \"name\": \"HLV Nguyễn Thị B\", \"type\": \"trainer\", \"price\": 250000, \"memberId\": null, \"quantity\": null, \"schedule\": \"30/05/2026 | 09:00\", \"schedules\": null, \"memberName\": null, \"memberEmail\": null, \"bookedForMember\": false}','2026-05-24 05:52:51','2026-05-24 05:52:51'),(25,25,2,'HLV Nguyễn Thị B','trainer',250000,'{\"id\": 2, \"name\": \"HLV Nguyễn Thị B\", \"type\": \"trainer\", \"price\": 250000, \"memberId\": null, \"quantity\": null, \"schedule\": \"30/05/2026 | 09:00\", \"schedules\": null, \"memberName\": null, \"memberEmail\": null, \"bookedForMember\": false}','2026-05-24 05:53:18','2026-05-24 05:53:18'),(26,26,2,'HLV Nguyễn Thị B','trainer',250000,'{\"id\": 2, \"name\": \"HLV Nguyễn Thị B\", \"type\": \"trainer\", \"price\": 250000, \"memberId\": null, \"quantity\": null, \"schedule\": \"30/05/2026 | 09:00\", \"schedules\": null, \"memberName\": null, \"memberEmail\": null, \"bookedForMember\": false}','2026-05-24 05:53:31','2026-05-24 05:53:31'),(27,27,2,'HLV Nguyễn Thị B','trainer',250000,'{\"id\": 2, \"name\": \"HLV Nguyễn Thị B\", \"type\": \"trainer\", \"price\": 250000, \"memberId\": null, \"quantity\": null, \"schedule\": \"30/05/2026 | 09:00\", \"schedules\": null, \"memberName\": null, \"memberEmail\": null, \"bookedForMember\": false}','2026-05-24 05:55:22','2026-05-24 05:55:22'),(28,28,2,'HLV Nguyễn Thị B','trainer',250000,'{\"id\": 2, \"name\": \"HLV Nguyễn Thị B\", \"type\": \"trainer\", \"price\": 250000, \"memberId\": null, \"quantity\": null, \"schedule\": \"30/05/2026 | 09:00\", \"schedules\": null, \"memberName\": null, \"memberEmail\": null, \"bookedForMember\": false}','2026-05-24 06:42:39','2026-05-24 06:42:39'),(29,29,2,'HLV Nguyễn Thị B','trainer',250000,'{\"id\": 2, \"name\": \"HLV Nguyễn Thị B\", \"type\": \"trainer\", \"price\": 250000, \"memberId\": null, \"quantity\": null, \"schedule\": \"30/05/2026 | 09:00\", \"schedules\": null, \"memberName\": null, \"memberEmail\": null, \"bookedForMember\": false}','2026-05-24 06:43:50','2026-05-24 06:43:50'),(30,30,2,'HLV Nguyễn Thị B','trainer',250000,'{\"id\": 2, \"name\": \"HLV Nguyễn Thị B\", \"type\": \"trainer\", \"price\": 250000, \"memberId\": null, \"quantity\": null, \"schedule\": \"30/05/2026 | 09:00\", \"schedules\": null, \"memberName\": null, \"memberEmail\": null, \"bookedForMember\": false}','2026-05-24 06:46:53','2026-05-24 06:46:53'),(31,31,2,'HLV Nguyễn Thị B','trainer',250000,'{\"id\": 2, \"name\": \"HLV Nguyễn Thị B\", \"type\": \"trainer\", \"price\": 250000, \"memberId\": null, \"quantity\": null, \"schedule\": \"28/05/2026 | 18:00\", \"schedules\": null, \"memberName\": null, \"memberEmail\": null, \"bookedForMember\": false}','2026-05-24 16:38:21','2026-05-24 16:38:21'),(32,32,2,'HLV Nguyễn Thị B','trainer',250000,'{\"id\": 2, \"name\": \"HLV Nguyễn Thị B\", \"type\": \"trainer\", \"price\": 250000, \"memberId\": null, \"quantity\": null, \"schedule\": \"28/05/2026 | 18:00\", \"schedules\": null, \"memberName\": null, \"memberEmail\": null, \"bookedForMember\": false}','2026-05-24 16:51:35','2026-05-24 16:51:35'),(33,33,2,'HLV Nguyễn Thị B','trainer',250000,'{\"id\": 2, \"name\": \"HLV Nguyễn Thị B\", \"type\": \"trainer\", \"price\": 250000, \"memberId\": null, \"quantity\": null, \"schedule\": \"28/05/2026 | 18:00\", \"schedules\": null, \"memberName\": null, \"memberEmail\": null, \"bookedForMember\": false}','2026-05-24 16:51:59','2026-05-24 16:51:59'),(34,34,2,'HLV Nguyễn Thị B','trainer',250000,'{\"id\": 2, \"name\": \"HLV Nguyễn Thị B\", \"type\": \"trainer\", \"price\": 250000, \"memberId\": null, \"quantity\": null, \"schedule\": \"28/05/2026 | 18:00\", \"schedules\": null, \"memberName\": null, \"memberEmail\": null, \"bookedForMember\": false}','2026-05-24 16:52:21','2026-05-24 16:52:21'),(35,35,2,'HLV Nguyễn Thị B','trainer',250000,'{\"id\": 2, \"name\": \"HLV Nguyễn Thị B\", \"type\": \"trainer\", \"price\": 250000, \"memberId\": null, \"quantity\": null, \"schedule\": \"28/05/2026 | 18:00\", \"schedules\": null, \"memberName\": null, \"memberEmail\": null, \"bookedForMember\": false}','2026-05-24 16:57:30','2026-05-24 16:57:30'),(36,36,2,'HLV Nguyễn Thị B','trainer',250000,'{\"id\": 2, \"name\": \"HLV Nguyễn Thị B\", \"type\": \"trainer\", \"price\": 250000, \"memberId\": null, \"quantity\": null, \"schedule\": \"28/05/2026 | 18:00\", \"schedules\": null, \"memberName\": null, \"memberEmail\": null, \"bookedForMember\": false}','2026-05-24 17:04:31','2026-05-24 17:04:31'),(37,37,2,'HLV Nguyễn Thị B','trainer',250000,'{\"id\": 2, \"name\": \"HLV Nguyễn Thị B\", \"type\": \"trainer\", \"price\": 250000, \"memberId\": null, \"quantity\": null, \"schedule\": \"28/05/2026 | 18:00\", \"schedules\": null, \"memberName\": null, \"memberEmail\": null, \"bookedForMember\": false}','2026-05-24 17:04:50','2026-05-24 17:04:50'),(38,38,2,'HLV Nguyễn Thị B','trainer',250000,'{\"id\": 2, \"name\": \"HLV Nguyễn Thị B\", \"type\": \"trainer\", \"price\": 250000, \"memberId\": null, \"quantity\": null, \"schedule\": \"28/05/2026 | 18:00\", \"schedules\": null, \"memberName\": null, \"memberEmail\": null, \"bookedForMember\": false}','2026-05-24 17:11:35','2026-05-24 17:11:35'),(39,39,2,'HLV Nguyễn Thị B','trainer',250000,'{\"id\": 2, \"name\": \"HLV Nguyễn Thị B\", \"type\": \"trainer\", \"price\": 250000, \"memberId\": null, \"quantity\": null, \"schedule\": \"28/05/2026 | 18:00\", \"schedules\": null, \"memberName\": null, \"memberEmail\": null, \"bookedForMember\": false}','2026-05-24 17:11:54','2026-05-24 17:11:54'),(40,40,2,'HLV Nguyễn Thị B','trainer',250000,'{\"id\": 2, \"name\": \"HLV Nguyễn Thị B\", \"type\": \"trainer\", \"price\": 250000, \"memberId\": null, \"quantity\": null, \"schedule\": \"28/05/2026 | 18:00\", \"schedules\": null, \"memberName\": null, \"memberEmail\": null, \"bookedForMember\": false}','2026-05-24 18:12:02','2026-05-24 18:12:02'),(41,41,7,'HLV Lê Văn A','trainer',280000,'{\"id\": 7, \"name\": \"HLV Lê Văn A\", \"type\": \"trainer\", \"price\": 280000, \"memberId\": null, \"quantity\": null, \"schedule\": \"28/05/2026 | 06:00\", \"schedules\": null, \"memberName\": null, \"memberEmail\": null, \"bookedForMember\": false}','2026-05-24 18:20:09','2026-05-24 18:20:09'),(42,42,7,'HLV Lê Văn A','trainer',280000,'{\"id\": 7, \"name\": \"HLV Lê Văn A\", \"type\": \"trainer\", \"price\": 280000, \"memberId\": null, \"quantity\": null, \"schedule\": \"28/05/2026 | 06:00\", \"schedules\": null, \"memberName\": null, \"memberEmail\": null, \"bookedForMember\": false}','2026-05-24 18:28:46','2026-05-24 18:28:46'),(43,43,2,'HLV Nguyễn Thị B','trainer',250000,'{\"id\": 2, \"name\": \"HLV Nguyễn Thị B\", \"type\": \"trainer\", \"price\": 250000, \"memberId\": null, \"quantity\": null, \"schedule\": \"30/05/2026 | 10:30\", \"schedules\": null, \"memberName\": null, \"memberEmail\": null, \"bookedForMember\": false}','2026-05-25 18:18:26','2026-05-25 18:18:26'),(44,44,2,'HLV Nguyễn Thị B','trainer',250000,'{\"id\": 2, \"name\": \"HLV Nguyễn Thị B\", \"type\": \"trainer\", \"price\": 250000, \"memberId\": null, \"quantity\": null, \"schedule\": \"29/05/2026 | 09:00\", \"schedules\": null, \"memberName\": null, \"memberEmail\": null, \"bookedForMember\": false}','2026-05-26 14:22:44','2026-05-26 14:22:44'),(45,45,2,'HLV Nguyễn Thị B','trainer',250000,'{\"id\": 2, \"name\": \"HLV Nguyễn Thị B\", \"type\": \"trainer\", \"price\": 250000, \"memberId\": null, \"quantity\": null, \"schedule\": \"29/05/2026 | 09:00\", \"schedules\": null, \"memberName\": null, \"memberEmail\": null, \"bookedForMember\": false}','2026-05-26 14:23:00','2026-05-26 14:23:00'),(46,46,2,'HLV Nguyễn Thị B','trainer',250000,'{\"id\": 2, \"name\": \"HLV Nguyễn Thị B\", \"type\": \"trainer\", \"price\": 250000, \"memberId\": null, \"quantity\": null, \"schedule\": \"29/05/2026 | 09:00\", \"schedules\": null, \"memberName\": null, \"memberEmail\": null, \"bookedForMember\": false}','2026-05-26 14:41:34','2026-05-26 14:41:34'),(47,47,2,'HLV Nguyễn Thị B','trainer',250000,'{\"id\": 2, \"name\": \"HLV Nguyễn Thị B\", \"type\": \"trainer\", \"price\": 250000, \"memberId\": null, \"quantity\": null, \"schedule\": \"29/05/2026 | 06:00\", \"schedules\": null, \"memberName\": null, \"memberEmail\": null, \"bookedForMember\": false}','2026-05-26 15:05:19','2026-05-26 15:05:19'),(48,48,2,'HLV Nguyễn Thị B','trainer',250000,'{\"id\": 2, \"name\": \"HLV Nguyễn Thị B\", \"type\": \"trainer\", \"price\": 250000, \"memberId\": null, \"quantity\": null, \"schedule\": \"27/05/2026 | 06:00\", \"schedules\": null, \"memberName\": null, \"memberEmail\": null, \"bookedForMember\": false}','2026-05-26 15:32:17','2026-05-26 15:32:17'),(49,49,7,'HLV Lê Văn A','trainer',280000,'{\"id\": 7, \"name\": \"HLV Lê Văn A\", \"type\": \"trainer\", \"price\": 280000, \"memberId\": null, \"quantity\": null, \"schedule\": \"31/05/2026 | 06:00\", \"schedules\": null, \"memberName\": null, \"memberEmail\": null, \"bookedForMember\": false}','2026-05-26 15:53:16','2026-05-26 15:53:16');
/*!40000 ALTER TABLE `order_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `total_amount` decimal(10,0) NOT NULL,
  `payment_method` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('pending','completed','cancelled') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `orders_user_id_foreign` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=50 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (1,8,308000,'bank_transfer','completed','2026-01-22 03:04:24','2026-01-22 03:04:24'),(2,8,308000,'bank_transfer','completed','2026-01-22 03:10:51','2026-01-22 03:10:51'),(3,8,330000,'bank_transfer','completed','2026-01-22 03:16:49','2026-01-22 03:16:49'),(4,8,264000,'bank_transfer','completed','2026-01-22 03:23:38','2026-01-22 03:23:38'),(5,8,495000,'bank_transfer','completed','2026-01-22 04:15:09','2026-01-22 04:15:09'),(6,8,275000,'credit_card','completed','2026-01-22 04:17:19','2026-01-22 04:17:19'),(7,8,99000,'bank_transfer','completed','2026-01-22 04:52:01','2026-01-22 04:52:01'),(8,8,308000,'bank_transfer','completed','2026-01-22 04:52:58','2026-01-22 04:52:58'),(9,8,308000,'bank_transfer','completed','2026-01-22 04:55:16','2026-01-22 04:55:16'),(10,8,198000,'bank_transfer','completed','2026-01-22 04:57:25','2026-01-22 04:57:25'),(11,8,308000,'bank_transfer','completed','2026-01-22 04:57:57','2026-01-22 04:57:57'),(12,8,308000,'bank_transfer','completed','2026-01-22 05:01:09','2026-01-22 05:01:09'),(13,8,308000,'bank_transfer','completed','2026-01-22 05:04:42','2026-01-22 05:04:42'),(14,8,308000,'bank_transfer','completed','2026-01-22 05:13:23','2026-01-22 05:13:23'),(15,8,275000,'bank_transfer','completed','2026-01-22 05:39:56','2026-01-22 05:39:56'),(16,1,109999,'bank_transfer','completed','2026-04-27 04:55:34','2026-04-27 04:55:34'),(17,1,308000,'bank_transfer','completed','2026-04-27 08:00:05','2026-04-27 08:00:05'),(18,1,99000,'bank_transfer','completed','2026-05-09 08:53:45','2026-05-09 08:53:45'),(19,8,1,'vnpay_sandbox','pending','2026-05-24 04:27:30','2026-05-24 04:27:30'),(20,8,1,'vnpay_sandbox','pending','2026-05-24 04:27:38','2026-05-24 04:27:38'),(21,8,1,'vnpay_sandbox','pending','2026-05-24 04:28:30','2026-05-24 04:28:30'),(22,8,1,'vnpay_sandbox','pending','2026-05-24 04:28:33','2026-05-24 04:28:33'),(23,8,1,'vnpay_sandbox','pending','2026-05-24 04:28:34','2026-05-24 04:28:34'),(24,8,275000,'vnpay_sandbox','pending','2026-05-24 05:52:51','2026-05-24 05:52:51'),(25,8,275000,'vnpay_sandbox','pending','2026-05-24 05:53:18','2026-05-24 05:53:18'),(26,8,275000,'vnpay_sandbox','pending','2026-05-24 05:53:31','2026-05-24 05:53:31'),(27,8,275000,'vnpay_sandbox','pending','2026-05-24 05:55:22','2026-05-24 05:55:22'),(28,8,275000,'vnpay_sandbox','pending','2026-05-24 06:42:39','2026-05-24 06:42:39'),(29,8,275000,'vnpay_sandbox','pending','2026-05-24 06:43:50','2026-05-24 06:43:50'),(30,8,275000,'vnpay_sandbox','pending','2026-05-24 06:46:53','2026-05-24 06:46:53'),(31,8,275000,'vnpay_sandbox','pending','2026-05-24 16:38:21','2026-05-24 16:38:21'),(32,8,275000,'vnpay_sandbox','pending','2026-05-24 16:51:34','2026-05-24 16:51:34'),(33,8,275000,'vnpay_sandbox','pending','2026-05-24 16:51:59','2026-05-24 16:51:59'),(34,8,275000,'vnpay_sandbox','pending','2026-05-24 16:52:21','2026-05-24 16:52:21'),(35,8,275000,'vnpay_sandbox','pending','2026-05-24 16:57:30','2026-05-24 16:57:30'),(36,8,275000,'vnpay_sandbox','pending','2026-05-24 17:04:31','2026-05-24 17:04:31'),(37,8,275000,'vnpay_sandbox','pending','2026-05-24 17:04:50','2026-05-24 17:04:50'),(38,8,275000,'vnpay_sandbox','pending','2026-05-24 17:11:35','2026-05-24 17:11:35'),(39,8,275000,'vnpay_sandbox','pending','2026-05-24 17:11:54','2026-05-24 17:11:54'),(40,8,275000,'vnpay_sandbox','pending','2026-05-24 18:12:01','2026-05-24 18:12:01'),(41,8,308000,'vnpay_sandbox','pending','2026-05-24 18:20:09','2026-05-24 18:20:09'),(42,8,308000,'vnpay_sandbox','completed','2026-05-24 18:28:46','2026-05-24 18:30:35'),(43,8,275000,'vnpay_sandbox','pending','2026-05-25 18:18:26','2026-05-25 18:18:26'),(44,8,275000,'vnpay_sandbox','pending','2026-05-26 14:22:44','2026-05-26 14:22:44'),(45,8,275000,'vnpay_sandbox','pending','2026-05-26 14:23:00','2026-05-26 14:23:00'),(46,8,275000,'vnpay_sandbox','pending','2026-05-26 14:41:34','2026-05-26 14:41:34'),(47,8,275000,'vnpay_sandbox','pending','2026-05-26 15:05:19','2026-05-26 15:05:19'),(48,8,275000,'vnpay_sandbox','completed','2026-05-26 15:32:17','2026-05-26 15:33:14'),(49,8,308000,'vnpay_sandbox','pending','2026-05-26 15:53:16','2026-05-26 15:53:16');
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `packages`
--

DROP TABLE IF EXISTS `packages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `packages` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `packages`
--

LOCK TABLES `packages` WRITE;
/*!40000 ALTER TABLE `packages` DISABLE KEYS */;
INSERT INTO `packages` VALUES (2,'Standard','3',1200000,1500000,1,'Tập 4 buổi/tuần, Tư vấn chi tiết, 2 lần check-up','green',1,'active','2026-01-22 08:38:17','2026-01-22 08:38:17'),(3,'Premium','6',2200000,2700000,1,'Tập không giới hạn, Tư vấn toàn diện, 4 lần check-up, Cấp bằng','purple',1,'active','2026-01-22 08:38:17','2026-01-22 08:38:17'),(4,'VIP','12',3800000,4500000,1,'Tất cả, Huấn luyện viên riêng, Lịch tập cá nhân, Hỗ trợ 24/7','purple',0,'active','2026-01-22 08:38:17','2026-01-22 08:38:17'),(7,'a','2',1,NULL,4,'1\n1\n1\n1','green',0,'active','2026-01-22 02:49:10',NULL);
/*!40000 ALTER TABLE `packages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset_tokens` (
  `email` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset_tokens`
--

LOCK TABLES `password_reset_tokens` WRITE;
/*!40000 ALTER TABLE `password_reset_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_reset_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pending_registrations`
--

DROP TABLE IF EXISTS `pending_registrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pending_registrations` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
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
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pending_registrations`
--

LOCK TABLES `pending_registrations` WRITE;
/*!40000 ALTER TABLE `pending_registrations` DISABLE KEYS */;
/*!40000 ALTER TABLE `pending_registrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `personal_access_tokens`
--

DROP TABLE IF EXISTS `personal_access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `personal_access_tokens` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint unsigned NOT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=127 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `personal_access_tokens`
--

LOCK TABLES `personal_access_tokens` WRITE;
/*!40000 ALTER TABLE `personal_access_tokens` DISABLE KEYS */;
INSERT INTO `personal_access_tokens` VALUES (1,'App\\Models\\User',1,'auth_token','75419db3c93ef6d89ba49e074fd7aed865a2e82dac1a1079e791526cb962f40c','[\"*\"]','2026-01-22 01:40:03',NULL,'2026-01-22 01:38:43','2026-01-22 01:40:03'),(59,'App\\Models\\User',1,'auth_token','aa908d28e96fb4f580b8aa6b397e1deb0310ff99a7573905913e8697c949c2b1','[\"*\"]','2026-04-27 04:49:13',NULL,'2026-04-27 04:33:47','2026-04-27 04:49:13'),(60,'App\\Models\\User',8,'auth_token','3634d16d31a82a22ed16ec4b12a6f4805f80b6143ec08d696577b5e6587c4260','[\"*\"]',NULL,NULL,'2026-04-27 04:52:03','2026-04-27 04:52:03'),(61,'App\\Models\\User',8,'auth_token','8b057ed124b9c4d8273f2ca98a05fcbef535aa698d74f2abf5920748b3eb554d','[\"*\"]',NULL,NULL,'2026-04-27 04:52:06','2026-04-27 04:52:06'),(62,'App\\Models\\User',8,'auth_token','80b8ac35fa077471c52b63b9a7ed8aba1f379f501f937ee4dea0c260cb2b0808','[\"*\"]',NULL,NULL,'2026-04-27 04:52:13','2026-04-27 04:52:13'),(63,'App\\Models\\User',3,'auth_token','05c6b8d0456e4bb195209a7efafaeea6eab61929c6972f2387f25c98709202b3','[\"*\"]','2026-04-27 04:53:00',NULL,'2026-04-27 04:52:44','2026-04-27 04:53:00'),(64,'App\\Models\\User',1,'auth_token','ebe157cce7d77ef0c3556a81bf7e81bf897aef0086b8580f9305ccf7071707cc','[\"*\"]','2026-04-27 05:14:52',NULL,'2026-04-27 04:54:36','2026-04-27 05:14:52'),(65,'App\\Models\\User',1,'auth_token','b09c7d951b0b31b9e80ed5dd592234ca7d8c12a3c8ba572df6cb19252ed2598d','[\"*\"]','2026-04-27 06:09:08',NULL,'2026-04-27 05:16:19','2026-04-27 06:09:08'),(66,'App\\Models\\User',1,'auth_token','e77aceecc84593b5e391c123a90c4fac7bfa5d5af25ecfedce299517a2598c69','[\"*\"]','2026-04-27 07:28:20',NULL,'2026-04-27 06:10:54','2026-04-27 07:28:20'),(67,'App\\Models\\User',1,'auth_token','844c95136afd9fb7c511d00ce05c33399c1d682f26e9eb07042f156c2a953ed2','[\"*\"]','2026-04-27 07:38:26',NULL,'2026-04-27 07:31:33','2026-04-27 07:38:26'),(68,'App\\Models\\User',3,'auth_token','c6e3b4ca66c5a65c9d2648af7857ba5dc1977b000375e218e0016d89b959a17e','[\"*\"]','2026-04-27 07:50:15',NULL,'2026-04-27 07:39:04','2026-04-27 07:50:15'),(69,'App\\Models\\User',1,'auth_token','afa2bfceabdad876bc056128785164ebf141507c08d787ea40417748db896fca','[\"*\"]','2026-04-27 07:50:55',NULL,'2026-04-27 07:50:47','2026-04-27 07:50:55'),(70,'App\\Models\\User',3,'auth_token','c8a528d2698c0e0ef5d1e8a696e942c0602876893fc5863616364370d6286445','[\"*\"]','2026-04-27 07:51:15',NULL,'2026-04-27 07:51:14','2026-04-27 07:51:15'),(71,'App\\Models\\User',16,'auth_token','bf1d31fef515c300a4676834145c598fb04b406b71e2052733af798eaa00f96a','[\"*\"]','2026-04-27 07:51:51',NULL,'2026-04-27 07:51:34','2026-04-27 07:51:51'),(72,'App\\Models\\User',1,'auth_token','89aa03f2be41f83e5305e4f24d67efbc45692da1debf1e4abafc949a938f647e','[\"*\"]','2026-04-27 07:55:19',NULL,'2026-04-27 07:52:01','2026-04-27 07:55:19'),(73,'App\\Models\\User',1,'auth_token','91d71146752a043123e08a27b9fbe4c1e2326934c8f7731ba6ed620c500000a2','[\"*\"]','2026-04-27 07:56:23',NULL,'2026-04-27 07:56:17','2026-04-27 07:56:23'),(74,'App\\Models\\User',3,'auth_token','0354b7101970def9fed5b8e6459d10cf3832eb4f5bcdc6c6af89932bd4529df7','[\"*\"]','2026-04-27 07:57:08',NULL,'2026-04-27 07:56:46','2026-04-27 07:57:08'),(75,'App\\Models\\User',1,'auth_token','89140e5ef7a22e317d60bd6e5d7072554d966c270d0b0b68b27398b83f9df5d2','[\"*\"]','2026-04-27 08:31:14',NULL,'2026-04-27 07:57:18','2026-04-27 08:31:14'),(76,'App\\Models\\User',3,'auth_token','7d16a5f1e5166a98dac2ad3112aa1f63eea24c223e7d29aa3205d2a2ae1dd189','[\"*\"]','2026-04-27 08:31:50',NULL,'2026-04-27 08:31:40','2026-04-27 08:31:50'),(77,'App\\Models\\User',1,'auth_token','5511fdac18baf7aba974db54c7062893d02e877e28fe44605ccd64797a361792','[\"*\"]','2026-04-27 09:03:59',NULL,'2026-04-27 08:32:07','2026-04-27 09:03:59'),(78,'App\\Models\\User',1,'auth_token','9b5d37b888b04b66a75c07f714e1f21c7ef3be7ee63711bc6e8e1e779e1ee54b','[\"*\"]','2026-05-09 04:53:13',NULL,'2026-04-27 09:04:27','2026-05-09 04:53:13'),(79,'App\\Models\\User',1,'debug_token','51eec12b89284d6c76ae7d9f37a60c0639a8bcbca272dabd67bac780a38f2e1a','[\"*\"]','2026-05-09 06:13:37',NULL,'2026-05-09 04:57:31','2026-05-09 06:13:37'),(80,'App\\Models\\User',1,'auth_token','27f49fb33fec9d06433746767107939fc9e9efb94a5cc5c1dc65e918a5a48076','[\"*\"]','2026-05-09 05:29:28',NULL,'2026-05-09 05:09:14','2026-05-09 05:29:28'),(81,'App\\Models\\User',1,'auth_token','c18b04ad037bb1511bbc3aecfc86eb70ceddc696c8a219b814e72eeee72a962b','[\"*\"]','2026-05-09 05:34:58',NULL,'2026-05-09 05:32:58','2026-05-09 05:34:58'),(82,'App\\Models\\User',3,'auth_token','fbc9bbf82147414b1b12ddc56eecbd924a74dcf3176997f209d887b15c2f7ddb','[\"*\"]','2026-05-09 05:52:10',NULL,'2026-05-09 05:36:35','2026-05-09 05:52:10'),(83,'App\\Models\\User',3,'auth_token','403d55741c11445e394cf58389efabbaee2aec205c0ad9f78307c05ba0c114fd','[\"*\"]','2026-05-09 06:16:18',NULL,'2026-05-09 05:55:26','2026-05-09 06:16:18'),(84,'App\\Models\\User',3,'auth_token','6a202dce14215a3ef03c5ed5b352db1ce8995636c0b78faf24d37b855eb9d484','[\"*\"]','2026-05-09 06:37:03',NULL,'2026-05-09 06:17:20','2026-05-09 06:37:03'),(85,'App\\Models\\User',3,'auth_token','6083e17b51e9b8e00a0ddfcca61559c61fd62ff9d6e7e8e8f6610a3eaa86fa42','[\"*\"]','2026-05-09 06:38:37',NULL,'2026-05-09 06:38:31','2026-05-09 06:38:37'),(86,'App\\Models\\User',3,'auth_token','c28e3e44bd99cfb68f5ccec5bf04913ef8b61e8aeb2d3beee0bf3e56f3f95098','[\"*\"]',NULL,NULL,'2026-05-09 06:41:37','2026-05-09 06:41:37'),(87,'App\\Models\\User',3,'auth_token','4ddb196d266864539d36b2feadfb38549b744d5a787aecbb813b66eec01a38ec','[\"*\"]','2026-05-09 06:47:41',NULL,'2026-05-09 06:44:09','2026-05-09 06:47:41'),(88,'App\\Models\\User',3,'auth_token','515e39a4245d9046f374d75ec2b20a6219bed5e7071d44bc45ff7f2802bcbc7f','[\"*\"]',NULL,NULL,'2026-05-09 06:44:45','2026-05-09 06:44:45'),(89,'App\\Models\\User',3,'auth_token','ff3b843b20355e0c19fc6f19e822ae6d6a8e97dd8de2dfd3678497eb49ec84dc','[\"*\"]','2026-05-09 07:29:08',NULL,'2026-05-09 06:50:30','2026-05-09 07:29:08'),(90,'App\\Models\\User',3,'auth_token','0a7a11f8746762901c5242d0c0b3032e5a9a7bed77bee98999ee15cae5aebbb6','[\"*\"]','2026-05-09 07:45:42',NULL,'2026-05-09 07:31:08','2026-05-09 07:45:42'),(91,'App\\Models\\User',3,'auth_token','1bcbadeef0a4ca55552aa4364c7703876ab1f19618d8dee13db78373a2ab370f','[\"*\"]','2026-05-09 08:20:46',NULL,'2026-05-09 07:50:13','2026-05-09 08:20:46'),(92,'App\\Models\\User',1,'auth_token','75486cf458fc653f6c1140daaec85f9938037bbc167e1a0ceb9bbddf5a75ea48','[\"*\"]','2026-05-09 08:21:47',NULL,'2026-05-09 08:21:00','2026-05-09 08:21:47'),(93,'App\\Models\\User',3,'auth_token','ae34fd5d86a3d646d83efbfd3e06cca22a461fcd5921e7f6976cb11fbcf6a87a','[\"*\"]','2026-05-09 08:22:05',NULL,'2026-05-09 08:21:59','2026-05-09 08:22:05'),(94,'App\\Models\\User',1,'auth_token','e40a2753083a52435591e4e3a5d50ce253a94d9222c13e05c5dc7b1f05026b58','[\"*\"]','2026-05-09 08:22:27',NULL,'2026-05-09 08:22:23','2026-05-09 08:22:27'),(95,'App\\Models\\User',3,'auth_token','c7daaffa04e080a8b99030cf8f506a7a94e1e4771f30048cf54e2706e4179276','[\"*\"]','2026-05-09 08:30:05',NULL,'2026-05-09 08:22:50','2026-05-09 08:30:05'),(96,'App\\Models\\User',1,'auth_token','25514f1428feced18b9d1443c658ada1388ffa7b4a0ac4056f04ddad9b31ee78','[\"*\"]','2026-05-09 11:12:12',NULL,'2026-05-09 08:30:23','2026-05-09 11:12:12'),(97,'App\\Models\\User',3,'auth_token','a16cbf03b4066d5027bc5412338f12fb375c73cbf35ed98f9b0938ee1cc26c81','[\"*\"]','2026-05-09 11:12:49',NULL,'2026-05-09 11:12:37','2026-05-09 11:12:49'),(98,'App\\Models\\User',1,'auth_token','f899e72024fb8383db6a2fb0b3f7eb2f1161da9d983299abae08a772fd4d9ed3','[\"*\"]','2026-05-09 11:15:54',NULL,'2026-05-09 11:13:06','2026-05-09 11:15:54'),(99,'App\\Models\\User',1,'auth_token','08be8764cfc76b855276f02d8fd48f00749717598e3c9ae65822c294b85325ce','[\"*\"]','2026-05-09 11:46:20',NULL,'2026-05-09 11:18:16','2026-05-09 11:46:20'),(100,'App\\Models\\User',16,'auth_token','9de66986f9940be7f46936ce6a304eccee119152eb99f63e003dd8bc5dd3c0c3','[\"*\"]','2026-05-09 11:48:29',NULL,'2026-05-09 11:47:06','2026-05-09 11:48:29'),(101,'App\\Models\\User',1,'auth_token','4a0c490ec4eead9949fa7aaccf02dac1d74483dee9450482fdf66c9ba0ea9e80','[\"*\"]','2026-05-24 03:06:04',NULL,'2026-05-09 11:48:54','2026-05-24 03:06:04'),(102,'App\\Models\\User',3,'auth_token','0e45a6f88df0f46def0be51d2f2f13f53abc50be621a381404db766cbf376e4e','[\"*\"]','2026-05-24 03:06:53',NULL,'2026-05-24 03:06:23','2026-05-24 03:06:53'),(103,'App\\Models\\User',16,'auth_token','b48532bde0c61cf4354e58e7855ea842acd48110ab8cef0d66864b6949fa92c6','[\"*\"]','2026-05-24 03:09:49',NULL,'2026-05-24 03:07:14','2026-05-24 03:09:49'),(104,'App\\Models\\User',16,'auth_token','b73aa0851c84f2e6427ba40d0e9c0d4ac0cb23e2f9c80d0c430787bda6a548bf','[\"*\"]','2026-05-24 03:15:56',NULL,'2026-05-24 03:15:47','2026-05-24 03:15:56'),(105,'App\\Models\\User',8,'auth_token','a44c7ff9aa7b04245a6f4219dd8ff3051307ac4137a97e1e5c64549326f7bc33','[\"*\"]','2026-05-24 03:54:05',NULL,'2026-05-24 03:16:33','2026-05-24 03:54:05'),(106,'App\\Models\\User',8,'auth_token','059ad8c3e1f3e60af2279238dc1f4252d4784559a5c1a6285dd09940fdfcaf95','[\"*\"]','2026-05-24 06:46:53',NULL,'2026-05-24 04:27:15','2026-05-24 06:46:53'),(107,'App\\Models\\User',1,'debug_token','fc366deaf6fe96aec109907fcf311b295b4b0680a45efcf8c4aceb3af76a5301','[\"*\"]',NULL,NULL,'2026-05-24 15:45:06','2026-05-24 15:45:06'),(108,'App\\Models\\User',1,'auth_token','1542c27f46f4e4ad518e08ede57d2d947322738e68d9cf9b97850fa805c17ecc','[\"*\"]','2026-05-24 16:37:40',NULL,'2026-05-24 15:52:38','2026-05-24 16:37:40'),(109,'App\\Models\\User',8,'auth_token','3c7fca6b8d0d195e3179d2c126a187ed2fd5e47c1041c5e68c5cebe07987a580','[\"*\"]','2026-05-26 15:52:09',NULL,'2026-05-24 16:37:53','2026-05-26 15:52:09'),(110,'App\\Models\\User',1,'auth_token','f44cc68300a3362d8957dab1b4ec573c421947a493d10292b8098ed4159f5fda','[\"*\"]','2026-05-26 14:42:35',NULL,'2026-05-26 14:41:55','2026-05-26 14:42:35'),(111,'App\\Models\\User',8,'auth_token','865789c68d0a105bc2c99cb9fdefa83c741066273bed3aab8adf7ace2d1fa7dc','[\"*\"]','2026-05-26 14:43:11',NULL,'2026-05-26 14:43:07','2026-05-26 14:43:11'),(112,'App\\Models\\User',9,'auth_token','e00c9848ecfb0fbaa8a3e36e19e7ac1c7016f28f33cf9dc3feb986dda9b52e7e','[\"*\"]','2026-05-26 14:47:36',NULL,'2026-05-26 14:43:45','2026-05-26 14:47:36'),(113,'App\\Models\\User',1,'auth_token','e7c95b4a283a461af741da8fe39e722cd3617a825b8f68671b7e781e652cfff2','[\"*\"]','2026-05-26 15:05:59',NULL,'2026-05-26 15:05:40','2026-05-26 15:05:59'),(114,'App\\Models\\User',8,'auth_token','32fd10ce91a246e902ceb05fa6ed6fb5e1bad2fe3d3bf5e1840a68c076dbb2ab','[\"*\"]','2026-05-26 15:06:16',NULL,'2026-05-26 15:06:13','2026-05-26 15:06:16'),(115,'App\\Models\\User',9,'auth_token','b6d3bbe507a535e3a072e9072350ddeab72eed6fa3bce7a2bd4e90becde44016','[\"*\"]','2026-05-26 15:07:18',NULL,'2026-05-26 15:07:02','2026-05-26 15:07:18'),(116,'App\\Models\\User',1,'auth_token','4f5a4003d9036e5a27f8e622519d299758a3f0f7c4d8d1aa4e4bd330fc822946','[\"*\"]','2026-05-26 15:14:08',NULL,'2026-05-26 15:13:46','2026-05-26 15:14:08'),(117,'App\\Models\\User',8,'auth_token','30b86f1c56d47aaf2084c9fde4451c4e25fef6a643f406813d531e2c89e09b21','[\"*\"]','2026-05-26 15:33:25',NULL,'2026-05-26 15:29:51','2026-05-26 15:33:25'),(118,'App\\Models\\User',1,'auth_token','e6d1d6e9a32add5f9968e23b7cdaa8e16aa42970167a3b89db583424cc7d3c47','[\"*\"]','2026-05-26 15:33:53',NULL,'2026-05-26 15:33:44','2026-05-26 15:33:53'),(119,'App\\Models\\User',8,'auth_token','89d80c98c3660d3092283aace275b9e2f762ed6a94d4677406317f264ba4fe46','[\"*\"]','2026-05-26 15:35:01',NULL,'2026-05-26 15:34:51','2026-05-26 15:35:01'),(120,'App\\Models\\User',9,'auth_token','62a6b43cff3a9cbdd22f00c97c41b826899e52776c93388113df2d41919e88a5','[\"*\"]','2026-05-26 15:35:17',NULL,'2026-05-26 15:35:14','2026-05-26 15:35:17'),(121,'App\\Models\\User',9,'auth_token','9afbfcaa5c4168ed9417d1deaaf1929ab42f928e5e5214238a99915aa5f53774','[\"*\"]','2026-05-26 15:52:27',NULL,'2026-05-26 15:52:24','2026-05-26 15:52:27'),(122,'App\\Models\\User',1,'auth_token','96ead10cbeb35f016f807fb43ab336670d5d4ded15ca636a760dfdb90c534fc8','[\"*\"]','2026-05-26 15:52:49',NULL,'2026-05-26 15:52:44','2026-05-26 15:52:49'),(123,'App\\Models\\User',8,'auth_token','3f68a11d716482a7ae90fd7e11d86ba3219c2fa0fdad7fcbb4ced924dc30c1f9','[\"*\"]','2026-05-26 15:53:22',NULL,'2026-05-26 15:53:10','2026-05-26 15:53:22'),(124,'App\\Models\\User',1,'auth_token','4502cd52158403726bd2fcd0eee19067db640130cf9e31ddf2397f10d7084bd0','[\"*\"]','2026-05-26 15:56:15',NULL,'2026-05-26 15:56:01','2026-05-26 15:56:15'),(125,'App\\Models\\User',16,'auth_token','8b5c3b55ac47886b645dc01720d70acb549c16ecba99d39062e83ff32d896481','[\"*\"]','2026-05-26 15:57:56',NULL,'2026-05-26 15:57:52','2026-05-26 15:57:56'),(126,'App\\Models\\User',1,'auth_token','d7f3b823ca22dfdf671a802ea83c894efbe3049ff1f22b7426b6177b7af48c7d','[\"*\"]','2026-05-26 17:38:10',NULL,'2026-05-26 17:37:29','2026-05-26 17:38:10');
/*!40000 ALTER TABLE `personal_access_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `push_campaigns`
--

DROP TABLE IF EXISTS `push_campaigns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `push_campaigns` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `push_campaigns`
--

LOCK TABLES `push_campaigns` WRITE;
/*!40000 ALTER TABLE `push_campaigns` DISABLE KEYS */;
/*!40000 ALTER TABLE `push_campaigns` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `refund_requests`
--

DROP TABLE IF EXISTS `refund_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `refund_requests` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `booking_id` bigint unsigned NOT NULL,
  `member_id` bigint unsigned NOT NULL,
  `reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `requested_amount` decimal(10,2) NOT NULL,
  `approved_amount` decimal(10,2) DEFAULT NULL,
  `status` enum('pending','approved','rejected','processed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `approved_by` bigint unsigned DEFAULT NULL,
  `refund_method` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `processed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `refund_requests`
--

LOCK TABLES `refund_requests` WRITE;
/*!40000 ALTER TABLE `refund_requests` DISABLE KEYS */;
/*!40000 ALTER TABLE `refund_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `session_notes`
--

DROP TABLE IF EXISTS `session_notes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `session_notes` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `booking_id` bigint unsigned NOT NULL,
  `trainer_id` bigint unsigned NOT NULL,
  `member_id` bigint unsigned NOT NULL,
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `session_notes`
--

LOCK TABLES `session_notes` WRITE;
/*!40000 ALTER TABLE `session_notes` DISABLE KEYS */;
/*!40000 ALTER TABLE `session_notes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `time_offs`
--

DROP TABLE IF EXISTS `time_offs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `time_offs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `trainer_id` bigint unsigned NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `reason` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('pending','approved','rejected','cancelled') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `approved_by` bigint unsigned DEFAULT NULL,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `approved_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `time_offs`
--

LOCK TABLES `time_offs` WRITE;
/*!40000 ALTER TABLE `time_offs` DISABLE KEYS */;
/*!40000 ALTER TABLE `time_offs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `trainer_earnings`
--

DROP TABLE IF EXISTS `trainer_earnings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `trainer_earnings` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `trainer_id` bigint unsigned NOT NULL,
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trainer_earnings`
--

LOCK TABLES `trainer_earnings` WRITE;
/*!40000 ALTER TABLE `trainer_earnings` DISABLE KEYS */;
INSERT INTO `trainer_earnings` VALUES (1,16,0.00,0,0,0,0.00,20.00,'2026-04-27 11:33:03','2026-04-27 11:33:03'),(2,3,0.00,0,0,0,0.00,20.00,'2026-04-27 11:33:03','2026-04-27 11:33:03');
/*!40000 ALTER TABLE `trainer_earnings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `trainers`
--

DROP TABLE IF EXISTS `trainers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `trainers` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trainers`
--

LOCK TABLES `trainers` WRITE;
/*!40000 ALTER TABLE `trainers` DISABLE KEYS */;
INSERT INTO `trainers` VALUES (2,'Nguyễn Thị B','trainer2@gmail.com',NULL,NULL,'Yoga & Pilates','6 năm',4.8,'Sáng, Chiều, Tối',250000,'2026-01-22 08:38:17','2026-01-22 08:38:17'),(7,'Lê Văn A','trainer1@gmail.com','',NULL,'Gym & Fitness','7 năm',5.0,'Sáng, Chiều, Tối',280000,'2026-01-22 02:42:12',NULL);
/*!40000 ALTER TABLE `trainers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transaction_reports`
--

DROP TABLE IF EXISTS `transaction_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transaction_reports` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `date` date NOT NULL,
  `member_id` bigint unsigned DEFAULT NULL,
  `trainer_id` bigint unsigned DEFAULT NULL,
  `type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `details` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `transaction_reports_date_type_idx` (`date`,`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transaction_reports`
--

LOCK TABLES `transaction_reports` WRITE;
/*!40000 ALTER TABLE `transaction_reports` DISABLE KEYS */;
/*!40000 ALTER TABLE `transaction_reports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_carts`
--

DROP TABLE IF EXISTS `user_carts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_carts` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `items` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_carts_user_id_unique` (`user_id`),
  CONSTRAINT `user_carts_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_carts`
--

LOCK TABLES `user_carts` WRITE;
/*!40000 ALTER TABLE `user_carts` DISABLE KEYS */;
INSERT INTO `user_carts` VALUES (1,8,'[{\"id\": 7, \"name\": \"HLV Lê Văn A\", \"type\": \"trainer\", \"price\": 280000, \"memberId\": null, \"quantity\": null, \"schedule\": \"31/05/2026 | 06:00\", \"schedules\": null, \"memberName\": null, \"memberEmail\": null, \"bookedForMember\": false}]','2026-05-26 15:52:09','2026-05-26 15:52:09');
/*!40000 ALTER TABLE `user_carts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Quản Trị Viên','admin@gmail.com','2026-01-22 08:38:17','$2y$12$vTDCwgp3A8dTtJ8i3FYrKeR.YGkGLhyydXEmy9xd.6QYrcmBd8CeW','/storage/avatars/pke6eAkPPoeES1uu9QX8027cAVNwbdxJV7dFCoFg.jpg','admin',NULL,NULL,'2026-01-22 08:38:17','2026-05-09 08:21:48'),(3,'Nguyễn Thị B','trainer2@gmail.com','2026-01-22 08:38:17','$2y$12$i1Fi6JTtCNd/olJDC5NQ5.HN.oA9LPQl7fn96NYFPv0q0Yktd9Jvy','/storage/avatars/TukpcW0hSAGyvKhoWCuLHpHqqjMGZym2MJaDvjik.jpg','trainer',NULL,NULL,'2026-01-22 08:38:17','2026-05-09 07:50:41'),(8,'Thành viên 1','member1@gmail.com','2026-01-22 08:38:17','$2y$12$w4ppZRv2mTsDG/TR5I9QKu5ARtvgdOedU2ABLABdsTbWqE81g9vmm',NULL,'member','000009999',NULL,'2026-01-22 08:38:17','2026-05-24 03:16:48'),(9,'Thành viên 2','member2@gmail.com','2026-01-22 08:38:17','$2y$12$/sA4M3rz1ODryJvk9/EcVOinbSwMMBPf7o4Bh913HMSKPUvnWmi9m',NULL,'member','0999999999',NULL,'2026-01-22 08:38:17','2026-05-26 15:07:20'),(16,'Lê Văn A','trainer1@gmail.com',NULL,'$2y$12$H2Q1sc21ZRVrQ6N1nnyZCOeomq/1jmlIsYYzQiRtW4E4UOIJy3l2C','/storage/avatars/zpI79QlBaIQaUgOlxSJUw1cLsiDGEORYMEEFS7SL.jpg','trainer','',NULL,'2026-01-22 02:42:12','2026-05-09 11:47:17');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vouchers`
--

DROP TABLE IF EXISTS `vouchers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vouchers` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vouchers`
--

LOCK TABLES `vouchers` WRITE;
/*!40000 ALTER TABLE `vouchers` DISABLE KEYS */;
/*!40000 ALTER TABLE `vouchers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `waitlist_entries`
--

DROP TABLE IF EXISTS `waitlist_entries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `waitlist_entries` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `member_id` bigint unsigned NOT NULL,
  `item_type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_id` bigint NOT NULL,
  `position` int NOT NULL DEFAULT '1',
  `notified_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `waitlist_entries_unique` (`member_id`,`item_type`,`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `waitlist_entries`
--

LOCK TABLES `waitlist_entries` WRITE;
/*!40000 ALTER TABLE `waitlist_entries` DISABLE KEYS */;
/*!40000 ALTER TABLE `waitlist_entries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `working_hours`
--

DROP TABLE IF EXISTS `working_hours`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `working_hours` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `trainer_id` bigint unsigned NOT NULL,
  `day_of_week` int NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `working_hours_trainer_day_unique` (`trainer_id`,`day_of_week`)
) ENGINE=InnoDB AUTO_INCREMENT=50 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `working_hours`
--

LOCK TABLES `working_hours` WRITE;
/*!40000 ALTER TABLE `working_hours` DISABLE KEYS */;
INSERT INTO `working_hours` VALUES (36,16,0,'09:00:00','17:00:00',0,'2026-04-27 07:51:51','2026-04-27 07:51:51'),(37,16,1,'06:00:00','20:00:00',0,'2026-04-27 07:51:51','2026-04-27 07:51:51'),(38,16,2,'06:00:00','20:00:00',0,'2026-04-27 07:51:51','2026-04-27 07:51:51'),(39,16,3,'06:00:00','20:00:00',0,'2026-04-27 07:51:51','2026-04-27 07:51:51'),(40,16,4,'06:00:00','20:00:00',0,'2026-04-27 07:51:51','2026-04-27 07:51:51'),(41,16,5,'06:00:00','20:00:00',0,'2026-04-27 07:51:51','2026-04-27 07:51:51'),(42,16,6,'06:00:00','20:00:00',0,'2026-04-27 07:51:51','2026-04-27 07:51:51'),(43,3,0,'15:30:00','22:00:00',1,'2026-04-27 07:57:05','2026-04-27 07:57:05'),(44,3,1,'06:00:00','20:00:00',1,'2026-04-27 07:57:05','2026-04-27 07:57:05'),(45,3,2,'06:00:00','20:00:00',1,'2026-04-27 07:57:05','2026-04-27 07:57:05'),(46,3,3,'06:00:00','20:00:00',1,'2026-04-27 07:57:05','2026-04-27 07:57:05'),(47,3,4,'06:00:00','20:00:00',0,'2026-04-27 07:57:05','2026-04-27 07:57:05'),(48,3,5,'06:00:00','20:00:00',1,'2026-04-27 07:57:05','2026-04-27 07:57:05'),(49,3,6,'06:00:00','20:00:00',1,'2026-04-27 07:57:05','2026-04-27 07:57:05');
/*!40000 ALTER TABLE `working_hours` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `workout_plans`
--

DROP TABLE IF EXISTS `workout_plans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `workout_plans` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `trainer_id` bigint unsigned NOT NULL,
  `member_id` bigint unsigned NOT NULL,
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `workout_plans`
--

LOCK TABLES `workout_plans` WRITE;
/*!40000 ALTER TABLE `workout_plans` DISABLE KEYS */;
/*!40000 ALTER TABLE `workout_plans` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `workout_schedules`
--

DROP TABLE IF EXISTS `workout_schedules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `workout_schedules` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned DEFAULT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `date` date NOT NULL,
  `time` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `duration` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `workout_schedules`
--

LOCK TABLES `workout_schedules` WRITE;
/*!40000 ALTER TABLE `workout_schedules` DISABLE KEYS */;
/*!40000 ALTER TABLE `workout_schedules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'gymflutter'
--
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-27  1:13:43




DELIMITER $$

CREATE FUNCTION fn_get_member_total_spent(p_user_id BIGINT UNSIGNED)
RETURNS DECIMAL(10,0)
DETERMINISTIC
BEGIN
    DECLARE v_total_spent DECIMAL(10,0) DEFAULT 0;
    SELECT IFNULL(SUM(total_amount), 0) INTO v_total_spent
    FROM orders
    WHERE user_id = p_user_id AND status = 'completed';

    RETURN v_total_spent;
END$$

DELIMITER ;



