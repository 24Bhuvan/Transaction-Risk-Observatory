-- ============================================================
-- Transaction Risk Observatory
-- Initial Database Schema Setup
-- ============================================================
-- Purpose:
-- Create the core PostgreSQL schemas used by the project.
----------------------------------------------------------

-- Database creation is intentionally handled separately.
-- This script must be executed while connected to:
-- transaction_risk_observatory
-- ============================================================

CREATE SCHEMA IF NOT EXISTS staging;

CREATE SCHEMA IF NOT EXISTS analytics;

CREATE SCHEMA IF NOT EXISTS monitoring;
