-- 1. Create the trigger function for end_time calculation
CREATE OR REPLACE FUNCTION calculate_end_time()RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    service_duration INT;
BEGIN
    -- Get the service duration from service table
    SELECT s.duration_min INTO service_duration
    FROM employee_service es
    JOIN service s ON es.service_id = s.id
    WHERE es.id = NEW.employee_service_id;

    -- Calculate end_time by adding duration to appointment_time
    NEW.end_time := NEW.appointment_time + (service_duration || ' minutes')::interval;

    RETURN NEW;
END;
$$;

-- 2. Create the trigger that will run BEFORE INSERT
CREATE TRIGGER set_appointment_end_time
    BEFORE INSERT ON appointment
    FOR EACH ROW
    EXECUTE FUNCTION calculate_end_time();





-- 1. Create the trigger function for payment creation
CREATE OR REPLACE FUNCTION create_pending_payment()RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
DECLARE
    service_price DECIMAL(10,2);
BEGIN
    -- Get the service price
    SELECT s.price INTO service_price
    FROM employee_service es
    JOIN service s ON es.service_id = s.id
    WHERE es.id = NEW.employee_service_id;

    -- Create payment record
    INSERT INTO payment (
        appointment_id,
        amount,
        payment_date,
        payment_time,
        status
    ) VALUES (
        NEW.id,
        service_price,
        NEW.appointment_date,
        NEW.appointment_time,
        'PENDING'
    );

    RETURN NEW;
END;
$$;

-- 2. Create the trigger that will run AFTER INSERT
CREATE TRIGGER create_appointment_payment
    AFTER INSERT ON appointment
    FOR EACH ROW
    EXECUTE FUNCTION create_pending_payment();


	


-- Create the trigger function for update the time and status of the payment table after update appointment tabels''' status 
CREATE OR REPLACE FUNCTION update_payment_on_appointment_status()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Update payment status and copy appointment's end_time
    UPDATE payment
    SET 
        status = CASE 
            WHEN NEW.status = 'completed' THEN 'COMPLETED'::payment_status
            WHEN NEW.status = 'cancelled' THEN 'CANCELLED'::payment_status
            ELSE 'PENDING'::payment_status
        END,
        payment_time = CASE
            WHEN NEW.status = 'completed' THEN OLD.end_time  -- Copy appointment's end_time
            ELSE payment_time
        END
    WHERE appointment_id = NEW.id;
    
    RETURN NEW;
END;
$$;

CREATE TRIGGER update_payment_status_on_appointment
AFTER UPDATE OF status ON appointment
FOR EACH ROW
WHEN (NEW.status <> OLD.status)
EXECUTE FUNCTION update_payment_on_appointment_status();

UPDATE appointment SET status = 'completed' WHERE id = 2;




-- Helper function for completed appointments with correct enum value 'in_progress'
CREATE OR REPLACE FUNCTION insert_and_complete_appointment(
    p_customer_id INTEGER,
    p_employee_service_id INTEGER,
    p_appointment_date DATE,
    p_appointment_time TIME
) RETURNS void AS $$
BEGIN
    -- First insert with 'in_progress' status
    INSERT INTO appointment (
        customer_id, 
        employee_service_id, 
        appointment_date, 
        appointment_time, 
        status
    ) VALUES (
        p_customer_id, 
        p_employee_service_id, 
        p_appointment_date, 
        p_appointment_time, 
        'in_progress'  -- Using correct enum value
    );
    
    -- Then update to 'completed' status
    UPDATE appointment 
    SET status = 'completed'
    WHERE customer_id = p_customer_id 
    AND employee_service_id = p_employee_service_id
    AND appointment_date = p_appointment_date
    AND appointment_time = p_appointment_time;
END;
$$ LANGUAGE plpgsql;


select * from appointment;


