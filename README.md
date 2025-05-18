# Salon Management System

A comprehensive database project for managing and analyzing salon operations, built using PostgreSQL. This system demonstrates advanced SQL capabilities including decision-support queries, indexing strategies, triggers & functions, stored procedures, transaction management, and query optimization.

## Table of Contents

- [Project Overview](#project-overview)  
- [Key Modules](#key-modules)  
- [Database Schema](#database-schema)  
- [Setup & Installation](#setup--installation)  
- [Usage](#usage)  
- [Directory Structure](#directory-structure)  
- [Technologies](#technologies)  
- [Contributors](#contributors)  
- [License](#license)  

## Project Overview

This project models a **Salon Management System**, focusing on the automation and analysis of appointments, services, employees, and customers. It includes:

- **Decision-Support Queries** for daily, weekly, and monthly performance metrics.  
- **Indexing** strategies (functional, partial, composite) to boost query performance.  
- **Triggers & Functions** to automate end-time calculation, payment record creation/update, and employee availability.  
- **Stored Procedures** to encapsulate business logic (scheduling, status updates, customer management).  
- **Transaction Management** demonstrating ACID properties and multi-step procedures.  
- **Query Optimization** via relational algebra transformations and planner hints.  

## Key Modules

1. **Decision-Support Queries**  
   - Daily/weekly appointment performance  
   - Employee revenue & service-count analysis  
   - Customer demographics & visit frequency  
   - Peak-hour and popular-service analysis  

2. **Indexing**  
   - Functional indexes on date-extraction expressions  
   - Partial indexes for upcoming appointments  
   - Composite indexes for multi-column filters  

3. **Triggers & Functions**  
   - **Before INSERT**: auto-calculate appointment end time  
   - **After INSERT**: create pending payment records  
   - **After UPDATE**: update payment status and employee availability  

4. **Stored Procedures**  
   - `schedule_appointment`: validates and inserts appointments  
   - `update_appointment_status`: enforces valid status transitions  
   - `add_customer`: ensures unique customer entries  

5. **Transactions**  
   - `set_employee_off_duty`: atomic off-duty updates with rollback on pending work  
   - `transfer_services`: reassign services between employees within a transaction  

6. **Query Optimization**  
   - Relational-algebra rewrite rules (selection pushdown, join reordering)  
   - Example multilevel and composite index performance tests  

## Database Schema

The core tables include:

- `customer` (`customer_id`, `first_name`, `last_name`, `gender`, `phone_number`, `email`)  
- `employee` (`employee_id`, `first_name`, `last_name`, `gender`, `role`, `current_status`)  
- `service` (`service_id`, `service_name`, `duration_min`, `price`)  
- `employee_service` (linking employees to services)  
- `appointment` (`appointment_id`, `customer_id`, `employee_service_id`, `appointment_date`, `appointment_time`, `end_time`, `status`)  
- `payment` (`payment_id`, `appointment_id`, `amount`, `status`, `payment_time`) :contentReference[oaicite:2]{index=2}:contentReference[oaicite:3]{index=3}

## Setup & Installation

1. **Prerequisites**  
   - PostgreSQL 14+  
   - psql or pgAdmin  

2. **Clone Repository**  
   ```bash
   git clone https://github.com/yourusername/salon-management-system.git
   cd salon-management-system
