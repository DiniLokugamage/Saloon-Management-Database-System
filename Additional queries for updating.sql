SELECT 
    service.service_name AS service_name,
    customer.gender,
    COUNT(DISTINCT customer.id) AS customer_count
FROM 
    appointment
JOIN 
    customer ON appointment.customer_id = customer.id
JOIN 
    service ON appointment.service_id = service.id
GROUP BY 
    service.service_name, customer.gender
ORDER BY 
    service.service_name, customer.gender;

SELECT * FROM employee;

ALTER TABLE employee_service DROP COLUMN created_date;

-- Create the appointment table
CREATE TABLE appointment (
    id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    employee_service_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    end_time TIME,
    status VARCHAR(20) DEFAULT 'SCHEDULED',
    UNIQUE (customer_id, employee_service_id, appointment_date, appointment_time),
    CHECK (appointment_time >= '08:00:00' AND appointment_time <= '18:00:00'),
    CHECK (status IN ('SCHEDULED', 'COMPLETED', 'CANCELLED')),
    FOREIGN KEY (customer_id) REFERENCES customer(id),
    FOREIGN KEY (employee_service_id) REFERENCES employee_service(id)
);

CREATE TYPE payment_status AS ENUM ('PENDING', 'COMPLETED', 'CANCELLED', 'REFUNDED');

CREATE TABLE payment (
    id SERIAL PRIMARY KEY,
    appointment_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_date DATE NOT NULL,
    payment_time TIME NOT NULL,
    status payment_status DEFAULT 'PENDING'
);



-- Add foreign key to payment table after appointment table is created
ALTER TABLE payment 
ADD CONSTRAINT fk_appointment 
FOREIGN KEY (appointment_id) REFERENCES appointment(id);

SELECT * FROM appointment;
SELECT * FROM payment;
SELECT * FROM customer;
SELECT * FROM service;
SELECT * FROM employee;
SELECT * FROM employee_service;

INSERT INTO appointment (
    customer_id,
    employee_service_id,
    appointment_date,
    appointment_time
) VALUES (
    2,
    21,
    '2024-03-20',
    '14:15:00'
);

INSERT INTO appointment (customer_id, employee_service_id, appointment_date, appointment_time, status)
VALUES(3, 2, '2024-08-01', '09:00:00', 'completed');

SELECT t.typname, e.enumlabel
FROM pg_type t 
JOIN pg_enum e ON t.oid = e.enumtypid
ORDER BY t.typname, e.enumsortorder;



-- First, let's look at all constraints on the appointment table
SELECT conname, pg_get_constraintdef(oid)
FROM pg_constraint
WHERE conrelid = 'appointment'::regclass;

-- Drop the problematic check constraint
ALTER TABLE appointment 
DROP CONSTRAINT IF EXISTS appointment_status_check;

-- Now let's recreate the table properly
ALTER TABLE appointment 
    ALTER COLUMN status DROP DEFAULT,
    ALTER COLUMN status TYPE VARCHAR(20);

-- Update existing values
UPDATE appointment 
SET status = CASE 
    WHEN status = 'SCHEDULED' THEN 'in_progress'
    WHEN status = 'COMPLETED' THEN 'completed'
    WHEN status = 'CANCELLED' THEN 'cancelled'
    ELSE status
END;

-- Make sure enum type exists with correct values
DROP TYPE IF EXISTS appointment_status CASCADE;
CREATE TYPE appointment_status AS ENUM ('in_progress', 'completed', 'cancelled');

-- Change column to enum type and set default
ALTER TABLE appointment 
    ALTER COLUMN status TYPE appointment_status USING status::appointment_status,
    ALTER COLUMN status SET DEFAULT 'in_progress'::appointment_status;


SELECT t.typname, e.enumlabel
FROM pg_type t 
JOIN pg_enum e ON t.oid = e.enumtypid
ORDER BY t.typname, e.enumsortorder;


DROP TYPE payment_method;

UPDATE payment 
SET status = 'COMPLETED' 
WHERE id = 3;

TRUNCATE TABLE payment, appointment;

TRUNCATE TABLE payment RESTART IDENTITY;
TRUNCATE TABLE appointment RESTART IDENTITY CASCADE;

SELECT id, first_name, last_name, gender 
FROM customer 
ORDER BY id 
LIMIT 5;

ROLLBACK;

-- First, disable triggers temporarily if they're causing issues
ALTER TABLE payment DISABLE TRIGGER ALL;
ALTER TABLE appointment DISABLE TRIGGER ALL;

DELETE FROM payment
WHERE appointment_id >= 392;

DELETE FROM appointment 
WHERE id >= 392;

-- Re-enable triggers
ALTER TABLE payment ENABLE TRIGGER ALL;
ALTER TABLE appointment ENABLE TRIGGER ALL;

-- Reset the sequence
SELECT setval('public.payment_id_seq', 391);

SELECT nextval('public.appointment_id_seq');

COMMIT;

SELECT pg_get_serial_sequence('payment', 'id');

--Check appointments
SELECT MAX(id) FROM appointment;

-- Check payments
SELECT MAX(id) FROM payment;


UPDATE service 
SET 
    service_name = CASE 
        WHEN service_name = 'Hair Coloring - Men' 
            THEN 'Hair Coloring - Classic'
        WHEN service_name = 'Hair Coloring - Women'
            THEN 'Hair Coloring - Premium'
        WHEN service_name = 'Deep Conditioning Treatment - Men'
            THEN 'Deep Conditioning Treatment - Express'
        WHEN service_name = 'Deep Conditioning Treatment - Women'
            THEN 'Deep Conditioning Treatment - Advanced'
        WHEN service_name = 'Basic Hair Styling - Men'
            THEN 'Basic Hair Styling - Quick'
        WHEN service_name = 'Basic Hair Styling - Women'
            THEN 'Basic Hair Styling - Styled'
        WHEN service_name = 'Formal Hair styles - Women'
            THEN 'Formal Hair Styling - Premium'
        WHEN service_name = 'Curling - Women'
            THEN 'Hair Curling Service'
        WHEN service_name = 'Straightening - Men'
            THEN 'Hair Straightening - Classic'
        WHEN service_name = 'Straightening - Women'
            THEN 'Hair Straightening - Premium'
        WHEN service_name = 'Bridal Hairstyle - Women'
            THEN 'Wedding Hair Styling'
        WHEN service_name = 'Groom Styling - Men'
            THEN 'Special Event Hair Styling'
        ELSE service_name
    END,
    description = CASE 
        WHEN service_name LIKE '%- Men' OR service_name LIKE '%- Women'
            THEN REGEXP_REPLACE(description, ' for (men|women)', '')
        ELSE description
    END
WHERE service_name LIKE '%- Men' OR service_name LIKE '%- Women';