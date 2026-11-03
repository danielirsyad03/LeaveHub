-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 03, 2026 at 01:39 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `leavehub`
--

-- --------------------------------------------------------

--
-- Table structure for table `activity_logs`
--

CREATE TABLE `activity_logs` (
  `id` bigint(20) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `user_name` varchar(150) NOT NULL,
  `user_role` varchar(50) NOT NULL,
  `action` varchar(100) NOT NULL,
  `description` text NOT NULL,
  `reference_type` varchar(50) DEFAULT NULL,
  `reference_id` varchar(100) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `announcements`
--

CREATE TABLE `announcements` (
  `id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `category` varchar(100) DEFAULT NULL,
  `audience_type` varchar(40) NOT NULL DEFAULT 'ALL_STAFF',
  `target_department` varchar(120) DEFAULT NULL,
  `status` varchar(30) NOT NULL DEFAULT 'DRAFT',
  `published_at` datetime DEFAULT NULL,
  `expires_at` datetime DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `announcement_recipients`
--

CREATE TABLE `announcement_recipients` (
  `id` int(11) NOT NULL,
  `announcement_id` int(11) NOT NULL,
  `staff_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `attendance`
--

CREATE TABLE `attendance` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `attendance_date` date NOT NULL,
  `check_in` datetime DEFAULT NULL,
  `check_out` datetime DEFAULT NULL,
  `check_in_latitude` decimal(10,7) DEFAULT NULL,
  `check_in_longitude` decimal(10,7) DEFAULT NULL,
  `check_out_latitude` decimal(10,7) DEFAULT NULL,
  `check_out_longitude` decimal(10,7) DEFAULT NULL,
  `check_in_distance` decimal(10,2) DEFAULT NULL,
  `check_out_distance` decimal(10,2) DEFAULT NULL,
  `late_reason` text DEFAULT NULL,
  `early_checkout_reason` text DEFAULT NULL,
  `status` varchar(40) NOT NULL DEFAULT 'BELUM_HADIR',
  `admin_remarks` text DEFAULT NULL,
  `modified_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `admin_note` text DEFAULT NULL,
  `admin_modified_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `company_events`
--

CREATE TABLE `company_events` (
  `id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `event_date` date NOT NULL,
  `start_time` time DEFAULT NULL,
  `end_time` time DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `status` varchar(30) NOT NULL DEFAULT 'PUBLISHED',
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `departments`
--

CREATE TABLE `departments` (
  `department_id` int(11) NOT NULL,
  `department_name` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inventory_categories`
--

CREATE TABLE `inventory_categories` (
  `id` int(11) NOT NULL,
  `category_name` varchar(100) NOT NULL,
  `code_prefix` varchar(20) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inventory_items`
--

CREATE TABLE `inventory_items` (
  `id` int(11) NOT NULL,
  `item_code` varchar(50) NOT NULL,
  `item_name` varchar(150) NOT NULL,
  `brand` varchar(100) DEFAULT NULL,
  `size` varchar(100) DEFAULT NULL,
  `color` varchar(100) DEFAULT NULL,
  `category` varchar(100) NOT NULL,
  `item_type` enum('ASSET','CONSUMABLE') NOT NULL DEFAULT 'CONSUMABLE',
  `quantity` int(11) NOT NULL DEFAULT 0,
  `available_quantity` int(11) NOT NULL DEFAULT 0,
  `unit` varchar(20) NOT NULL DEFAULT 'Unit',
  `item_condition` varchar(50) NOT NULL DEFAULT 'Good',
  `location` varchar(150) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `status` enum('AVAILABLE','LOW_STOCK','OUT_OF_STOCK','INACTIVE') NOT NULL DEFAULT 'AVAILABLE',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `is_active` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inventory_requests`
--

CREATE TABLE `inventory_requests` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `returned_quantity` int(11) NOT NULL DEFAULT 0,
  `purpose` text NOT NULL,
  `status` enum('PENDING','APPROVED','REJECTED','CANCELLED','RETURNED') NOT NULL DEFAULT 'PENDING',
  `remarks` text DEFAULT NULL,
  `requested_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `reviewed_by` int(11) DEFAULT NULL,
  `returned_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inventory_returns`
--

CREATE TABLE `inventory_returns` (
  `id` int(11) NOT NULL,
  `request_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `remarks` text DEFAULT NULL,
  `status` enum('PENDING','APPROVED','REJECTED') NOT NULL DEFAULT 'PENDING',
  `requested_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `reviewed_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inventory_transactions`
--

CREATE TABLE `inventory_transactions` (
  `id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `request_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `transaction_type` enum('STOCK_IN','STOCK_OUT','RETURN','ADJUSTMENT') NOT NULL,
  `quantity` int(11) NOT NULL,
  `stock_before` int(11) NOT NULL,
  `stock_after` int(11) NOT NULL,
  `remarks` text DEFAULT NULL,
  `performed_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `leave_applications`
--

CREATE TABLE `leave_applications` (
  `id` int(11) NOT NULL,
  `application_no` varchar(50) DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  `leave_type_id` int(11) DEFAULT NULL,
  `leave_type` varchar(60) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `duration` int(11) NOT NULL,
  `balance_before` int(11) DEFAULT NULL,
  `balance_after` int(11) DEFAULT NULL,
  `balance_verified_by` varchar(150) DEFAULT NULL,
  `balance_verified_date` date DEFAULT NULL,
  `reason` text NOT NULL,
  `contact_address` text DEFAULT NULL,
  `contact_phone` varchar(30) DEFAULT NULL,
  `handover_staff_id` int(11) DEFAULT NULL,
  `handover_staff_name` varchar(150) DEFAULT NULL,
  `annual_balance_before` int(11) DEFAULT NULL,
  `annual_leave_deducted` int(11) DEFAULT NULL,
  `annual_balance_after` int(11) DEFAULT NULL,
  `annual_balance_verified_by` varchar(150) DEFAULT NULL,
  `annual_balance_verified_date` date DEFAULT NULL,
  `other_leave_type` varchar(150) DEFAULT NULL,
  `attachment` varchar(255) DEFAULT NULL,
  `status` enum('PENDING','PENDING_HEAD','PENDING_ADMIN','PENDING_MANAGEMENT','APPROVED','REJECTED','CANCELLED') NOT NULL DEFAULT 'PENDING_MANAGEMENT',
  `remarks` text DEFAULT NULL,
  `submitted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `reviewed_by` int(11) DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `carry_forward_days_used` int(11) NOT NULL DEFAULT 0,
  `current_year_days_used` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `leave_approvals`
--

CREATE TABLE `leave_approvals` (
  `approval_id` int(11) NOT NULL,
  `leave_id` int(11) NOT NULL,
  `approver_id` int(11) DEFAULT NULL,
  `approval_level` enum('HEAD_OF_UNIT','ADMINISTRATION','MANAGEMENT') NOT NULL,
  `decision` enum('PENDING','SUPPORTED','NOT_SUPPORTED','VERIFIED','APPROVED','REJECTED','CANCELLED') NOT NULL DEFAULT 'PENDING',
  `remarks` text DEFAULT NULL,
  `decision_date` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `leave_attachments`
--

CREATE TABLE `leave_attachments` (
  `attachment_id` int(11) NOT NULL,
  `leave_id` int(11) NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `file_type` varchar(100) DEFAULT NULL,
  `uploaded_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `leave_balances`
--

CREATE TABLE `leave_balances` (
  `balance_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `leave_type_id` int(11) NOT NULL,
  `leave_year` year(4) NOT NULL,
  `entitlement` int(11) NOT NULL DEFAULT 0,
  `carry_forward_days` int(11) NOT NULL DEFAULT 0,
  `carry_forward_used` int(11) NOT NULL DEFAULT 0,
  `used_days` int(11) NOT NULL DEFAULT 0,
  `remaining_days` int(11) NOT NULL DEFAULT 0,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `leave_types`
--

CREATE TABLE `leave_types` (
  `leave_type_id` int(11) NOT NULL,
  `leave_type_name` varchar(100) NOT NULL,
  `requires_document` tinyint(1) DEFAULT 0,
  `is_active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `medical_dental_allocation_audit`
--

CREATE TABLE `medical_dental_allocation_audit` (
  `id` bigint(20) NOT NULL,
  `user_id` int(11) NOT NULL,
  `old_medical_allocation` decimal(10,2) NOT NULL,
  `new_medical_allocation` decimal(10,2) NOT NULL,
  `old_dental_allocation` decimal(10,2) NOT NULL,
  `new_dental_allocation` decimal(10,2) NOT NULL,
  `reason` varchar(1000) NOT NULL,
  `changed_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `medical_dental_allocation_settings`
--

CREATE TABLE `medical_dental_allocation_settings` (
  `user_id` int(11) NOT NULL,
  `medical_allocation` decimal(10,2) NOT NULL DEFAULT 1500.00,
  `dental_allocation` decimal(10,2) NOT NULL DEFAULT 200.00,
  `updated_by` int(11) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `medical_dental_benefits`
--

CREATE TABLE `medical_dental_benefits` (
  `id` bigint(20) NOT NULL,
  `user_id` int(11) NOT NULL,
  `benefit_year` int(11) NOT NULL,
  `medical_allocation` decimal(10,2) NOT NULL DEFAULT 1500.00,
  `medical_used` decimal(10,2) NOT NULL DEFAULT 0.00,
  `dental_allocation` decimal(10,2) NOT NULL DEFAULT 200.00,
  `dental_used` decimal(10,2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `medical_dental_claims`
--

CREATE TABLE `medical_dental_claims` (
  `id` bigint(20) NOT NULL,
  `user_id` int(11) NOT NULL,
  `benefit_year` int(11) NOT NULL,
  `claim_type` enum('MEDICAL','DENTAL') NOT NULL,
  `treatment_date` date NOT NULL,
  `description` varchar(1000) NOT NULL,
  `bill_amount` decimal(10,2) NOT NULL,
  `pkb_amount` decimal(10,2) NOT NULL,
  `staff_amount` decimal(10,2) NOT NULL,
  `document_path` varchar(500) DEFAULT NULL,
  `recorded_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `medical_dental_transactions`
--

CREATE TABLE `medical_dental_transactions` (
  `id` bigint(20) NOT NULL,
  `user_id` int(11) NOT NULL,
  `benefit_year` int(11) NOT NULL,
  `claim_id` bigint(20) DEFAULT NULL,
  `benefit_type` enum('MEDICAL','DENTAL') NOT NULL,
  `transaction_type` enum('CLAIM','ALLOCATION_ADJUSTMENT','REVERSAL') NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `balance_before` decimal(10,2) NOT NULL,
  `balance_after` decimal(10,2) NOT NULL,
  `remarks` varchar(1000) NOT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `notification_type` varchar(50) NOT NULL,
  `title` varchar(150) NOT NULL,
  `message` varchar(500) NOT NULL,
  `reference_type` varchar(50) DEFAULT NULL,
  `reference_id` int(11) DEFAULT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `public_holidays`
--

CREATE TABLE `public_holidays` (
  `id` int(11) NOT NULL,
  `holiday_name` varchar(150) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `holiday_date` date NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(120) NOT NULL,
  `position` varchar(150) DEFAULT NULL,
  `email` varchar(160) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('STAFF','HOD','HR','MANAGEMENT') NOT NULL DEFAULT 'STAFF',
  `department` enum('PENTADBIRAN_KORPORAT','KEWANGAN','PEMBANGUNAN_PERNIAGAAN_OPERASI') DEFAULT NULL,
  `hod_id` int(11) DEFAULT NULL,
  `annual_leave` int(11) NOT NULL DEFAULT 12,
  `medical_leave` int(11) NOT NULL DEFAULT 14,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `force_password_change` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `vehicles`
--

CREATE TABLE `vehicles` (
  `id` int(11) NOT NULL,
  `plate_number` varchar(30) NOT NULL,
  `vehicle_name` varchar(100) NOT NULL,
  `status` enum('ACTIVE','MAINTENANCE','INACTIVE') NOT NULL DEFAULT 'ACTIVE',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `vehicle_applications`
--

CREATE TABLE `vehicle_applications` (
  `id` int(11) NOT NULL,
  `application_no` varchar(50) NOT NULL,
  `user_id` int(11) NOT NULL,
  `vehicle_id` int(11) NOT NULL,
  `use_date` date NOT NULL,
  `start_time` time NOT NULL,
  `expected_return_time` time NOT NULL,
  `driver_name` varchar(150) NOT NULL,
  `destination` text NOT NULL,
  `purpose` text NOT NULL,
  `status` enum('PENDING','APPROVED','REJECTED','CANCELLED') NOT NULL DEFAULT 'PENDING',
  `approval_remark` text DEFAULT NULL,
  `approved_by` int(11) DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `expected_return_date` date DEFAULT NULL,
  `actual_return_date` date DEFAULT NULL,
  `actual_return_time` time DEFAULT NULL,
  `cancellation_reason` text DEFAULT NULL,
  `cancelled_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `vehicle_application_changes`
--

CREATE TABLE `vehicle_application_changes` (
  `id` int(11) NOT NULL,
  `application_id` int(11) NOT NULL,
  `requested_by` int(11) NOT NULL,
  `old_use_date` date DEFAULT NULL,
  `old_start_time` time DEFAULT NULL,
  `old_return_date` date DEFAULT NULL,
  `old_return_time` time DEFAULT NULL,
  `new_use_date` date NOT NULL,
  `new_start_time` time NOT NULL,
  `new_return_date` date NOT NULL,
  `new_return_time` time NOT NULL,
  `reason` text NOT NULL,
  `status` varchar(30) NOT NULL DEFAULT 'PENDING',
  `reviewed_by` int(11) DEFAULT NULL,
  `review_remark` text DEFAULT NULL,
  `reviewed_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `activity_logs`
--
ALTER TABLE `activity_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_activity_user` (`user_id`),
  ADD KEY `idx_activity_action` (`action`),
  ADD KEY `idx_activity_reference` (`reference_type`,`reference_id`),
  ADD KEY `idx_activity_created_at` (`created_at`);

--
-- Indexes for table `announcements`
--
ALTER TABLE `announcements`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_announcements_status_dates` (`status`,`published_at`,`expires_at`),
  ADD KEY `idx_announcements_created_by` (`created_by`);

--
-- Indexes for table `announcement_recipients`
--
ALTER TABLE `announcement_recipients`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_announcement_recipient` (`announcement_id`,`staff_id`),
  ADD KEY `idx_announcement_recipients_staff` (`staff_id`);

--
-- Indexes for table `attendance`
--
ALTER TABLE `attendance`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_attendance_user_date` (`user_id`,`attendance_date`),
  ADD KEY `idx_attendance_date_status` (`attendance_date`,`status`),
  ADD KEY `idx_attendance_modified_by` (`modified_by`);

--
-- Indexes for table `company_events`
--
ALTER TABLE `company_events`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_company_events_date_status` (`event_date`,`status`),
  ADD KEY `idx_company_events_creator` (`created_by`);

--
-- Indexes for table `departments`
--
ALTER TABLE `departments`
  ADD PRIMARY KEY (`department_id`);

--
-- Indexes for table `inventory_categories`
--
ALTER TABLE `inventory_categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `category_name` (`category_name`),
  ADD UNIQUE KEY `code_prefix` (`code_prefix`);

--
-- Indexes for table `inventory_items`
--
ALTER TABLE `inventory_items`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `item_code` (`item_code`);

--
-- Indexes for table `inventory_requests`
--
ALTER TABLE `inventory_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_inventory_user` (`user_id`),
  ADD KEY `fk_inventory_item` (`item_id`),
  ADD KEY `fk_inventory_reviewer` (`reviewed_by`);

--
-- Indexes for table `inventory_returns`
--
ALTER TABLE `inventory_returns`
  ADD PRIMARY KEY (`id`),
  ADD KEY `request_id` (`request_id`),
  ADD KEY `item_id` (`item_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `reviewed_by` (`reviewed_by`);

--
-- Indexes for table `inventory_transactions`
--
ALTER TABLE `inventory_transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_transaction_item` (`item_id`),
  ADD KEY `idx_transaction_request` (`request_id`),
  ADD KEY `idx_transaction_user` (`user_id`),
  ADD KEY `idx_transaction_performed_by` (`performed_by`),
  ADD KEY `idx_transaction_type` (`transaction_type`),
  ADD KEY `idx_transaction_created_at` (`created_at`);

--
-- Indexes for table `leave_applications`
--
ALTER TABLE `leave_applications`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `application_no` (`application_no`),
  ADD KEY `fk_leave_user` (`user_id`),
  ADD KEY `fk_leave_reviewer` (`reviewed_by`),
  ADD KEY `fk_leave_handover_staff` (`handover_staff_id`),
  ADD KEY `fk_application_leave_type` (`leave_type_id`);

--
-- Indexes for table `leave_approvals`
--
ALTER TABLE `leave_approvals`
  ADD PRIMARY KEY (`approval_id`),
  ADD KEY `fk_approval_leave` (`leave_id`),
  ADD KEY `fk_approval_user` (`approver_id`);

--
-- Indexes for table `leave_attachments`
--
ALTER TABLE `leave_attachments`
  ADD PRIMARY KEY (`attachment_id`),
  ADD KEY `fk_attachment_leave` (`leave_id`);

--
-- Indexes for table `leave_balances`
--
ALTER TABLE `leave_balances`
  ADD PRIMARY KEY (`balance_id`),
  ADD UNIQUE KEY `unique_staff_leave_year` (`user_id`,`leave_type_id`,`leave_year`),
  ADD UNIQUE KEY `uq_leave_balance` (`user_id`,`leave_type_id`,`leave_year`),
  ADD KEY `fk_balance_type` (`leave_type_id`);

--
-- Indexes for table `leave_types`
--
ALTER TABLE `leave_types`
  ADD PRIMARY KEY (`leave_type_id`);

--
-- Indexes for table `medical_dental_allocation_audit`
--
ALTER TABLE `medical_dental_allocation_audit`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_md_audit_user` (`user_id`),
  ADD KEY `fk_md_audit_admin` (`changed_by`);

--
-- Indexes for table `medical_dental_allocation_settings`
--
ALTER TABLE `medical_dental_allocation_settings`
  ADD PRIMARY KEY (`user_id`),
  ADD KEY `fk_md_setting_admin` (`updated_by`);

--
-- Indexes for table `medical_dental_benefits`
--
ALTER TABLE `medical_dental_benefits`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_medical_dental_user_year` (`user_id`,`benefit_year`);

--
-- Indexes for table `medical_dental_claims`
--
ALTER TABLE `medical_dental_claims`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_md_claim_user_year` (`user_id`,`benefit_year`),
  ADD KEY `idx_md_claim_recorder` (`recorded_by`);

--
-- Indexes for table `medical_dental_transactions`
--
ALTER TABLE `medical_dental_transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_md_tx_user_year` (`user_id`,`benefit_year`),
  ADD KEY `idx_md_tx_claim` (`claim_id`),
  ADD KEY `idx_md_tx_creator` (`created_by`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_notification_user` (`user_id`),
  ADD KEY `idx_notification_unread` (`user_id`,`is_read`);

--
-- Indexes for table `public_holidays`
--
ALTER TABLE `public_holidays`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_public_holiday_period` (`holiday_name`,`start_date`,`end_date`),
  ADD KEY `idx_public_holiday_dates` (`start_date`,`end_date`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `fk_users_hod` (`hod_id`);

--
-- Indexes for table `vehicles`
--
ALTER TABLE `vehicles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `plate_number` (`plate_number`);

--
-- Indexes for table `vehicle_applications`
--
ALTER TABLE `vehicle_applications`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `application_no` (`application_no`),
  ADD KEY `fk_vehicle_application_user` (`user_id`),
  ADD KEY `fk_vehicle_application_approver` (`approved_by`),
  ADD KEY `idx_vehicle_use_date` (`use_date`),
  ADD KEY `idx_vehicle_status` (`status`),
  ADD KEY `idx_vehicle_booking` (`vehicle_id`,`use_date`,`start_time`);

--
-- Indexes for table `vehicle_application_changes`
--
ALTER TABLE `vehicle_application_changes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_vac_application` (`application_id`),
  ADD KEY `idx_vac_requester` (`requested_by`),
  ADD KEY `idx_vac_status` (`status`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `activity_logs`
--
ALTER TABLE `activity_logs`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `announcements`
--
ALTER TABLE `announcements`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `announcement_recipients`
--
ALTER TABLE `announcement_recipients`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `attendance`
--
ALTER TABLE `attendance`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `company_events`
--
ALTER TABLE `company_events`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `departments`
--
ALTER TABLE `departments`
  MODIFY `department_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inventory_categories`
--
ALTER TABLE `inventory_categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inventory_items`
--
ALTER TABLE `inventory_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inventory_requests`
--
ALTER TABLE `inventory_requests`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inventory_returns`
--
ALTER TABLE `inventory_returns`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inventory_transactions`
--
ALTER TABLE `inventory_transactions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `leave_applications`
--
ALTER TABLE `leave_applications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `leave_approvals`
--
ALTER TABLE `leave_approvals`
  MODIFY `approval_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `leave_attachments`
--
ALTER TABLE `leave_attachments`
  MODIFY `attachment_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `leave_balances`
--
ALTER TABLE `leave_balances`
  MODIFY `balance_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `leave_types`
--
ALTER TABLE `leave_types`
  MODIFY `leave_type_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `medical_dental_allocation_audit`
--
ALTER TABLE `medical_dental_allocation_audit`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `medical_dental_benefits`
--
ALTER TABLE `medical_dental_benefits`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `medical_dental_claims`
--
ALTER TABLE `medical_dental_claims`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `medical_dental_transactions`
--
ALTER TABLE `medical_dental_transactions`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `public_holidays`
--
ALTER TABLE `public_holidays`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `vehicles`
--
ALTER TABLE `vehicles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `vehicle_applications`
--
ALTER TABLE `vehicle_applications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `vehicle_application_changes`
--
ALTER TABLE `vehicle_application_changes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `activity_logs`
--
ALTER TABLE `activity_logs`
  ADD CONSTRAINT `fk_activity_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `announcements`
--
ALTER TABLE `announcements`
  ADD CONSTRAINT `fk_announcements_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `announcement_recipients`
--
ALTER TABLE `announcement_recipients`
  ADD CONSTRAINT `fk_announcement_recipient_announcement` FOREIGN KEY (`announcement_id`) REFERENCES `announcements` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_announcement_recipient_staff` FOREIGN KEY (`staff_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `attendance`
--
ALTER TABLE `attendance`
  ADD CONSTRAINT `fk_attendance_modifier` FOREIGN KEY (`modified_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_attendance_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `company_events`
--
ALTER TABLE `company_events`
  ADD CONSTRAINT `fk_company_events_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `inventory_requests`
--
ALTER TABLE `inventory_requests`
  ADD CONSTRAINT `fk_inventory_item` FOREIGN KEY (`item_id`) REFERENCES `inventory_items` (`id`),
  ADD CONSTRAINT `fk_inventory_reviewer` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_inventory_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `inventory_returns`
--
ALTER TABLE `inventory_returns`
  ADD CONSTRAINT `inventory_returns_ibfk_1` FOREIGN KEY (`request_id`) REFERENCES `inventory_requests` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `inventory_returns_ibfk_2` FOREIGN KEY (`item_id`) REFERENCES `inventory_items` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `inventory_returns_ibfk_3` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `inventory_returns_ibfk_4` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `inventory_transactions`
--
ALTER TABLE `inventory_transactions`
  ADD CONSTRAINT `fk_transaction_item` FOREIGN KEY (`item_id`) REFERENCES `inventory_items` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_transaction_performed_by` FOREIGN KEY (`performed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_transaction_request` FOREIGN KEY (`request_id`) REFERENCES `inventory_requests` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_transaction_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `leave_applications`
--
ALTER TABLE `leave_applications`
  ADD CONSTRAINT `fk_application_leave_type` FOREIGN KEY (`leave_type_id`) REFERENCES `leave_types` (`leave_type_id`),
  ADD CONSTRAINT `fk_leave_handover_staff` FOREIGN KEY (`handover_staff_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_leave_reviewer` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_leave_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `leave_approvals`
--
ALTER TABLE `leave_approvals`
  ADD CONSTRAINT `fk_approval_leave` FOREIGN KEY (`leave_id`) REFERENCES `leave_applications` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_approval_user` FOREIGN KEY (`approver_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `leave_attachments`
--
ALTER TABLE `leave_attachments`
  ADD CONSTRAINT `fk_attachment_leave` FOREIGN KEY (`leave_id`) REFERENCES `leave_applications` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `leave_balances`
--
ALTER TABLE `leave_balances`
  ADD CONSTRAINT `fk_balance_type` FOREIGN KEY (`leave_type_id`) REFERENCES `leave_types` (`leave_type_id`),
  ADD CONSTRAINT `fk_balance_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `medical_dental_allocation_audit`
--
ALTER TABLE `medical_dental_allocation_audit`
  ADD CONSTRAINT `fk_md_audit_admin` FOREIGN KEY (`changed_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_md_audit_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `medical_dental_allocation_settings`
--
ALTER TABLE `medical_dental_allocation_settings`
  ADD CONSTRAINT `fk_md_setting_admin` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_md_setting_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `medical_dental_benefits`
--
ALTER TABLE `medical_dental_benefits`
  ADD CONSTRAINT `fk_md_benefit_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `medical_dental_claims`
--
ALTER TABLE `medical_dental_claims`
  ADD CONSTRAINT `fk_md_claim_recorder` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_md_claim_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `medical_dental_transactions`
--
ALTER TABLE `medical_dental_transactions`
  ADD CONSTRAINT `fk_md_tx_claim` FOREIGN KEY (`claim_id`) REFERENCES `medical_dental_claims` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_md_tx_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_md_tx_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `fk_notification_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `fk_users_hod` FOREIGN KEY (`hod_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `vehicle_applications`
--
ALTER TABLE `vehicle_applications`
  ADD CONSTRAINT `fk_vehicle_application_approver` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_vehicle_application_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_vehicle_application_vehicle` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
