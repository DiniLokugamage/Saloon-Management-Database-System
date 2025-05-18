--Daily Customer Visits
SELECT 
    appointment_date,
    COUNT(*) as total_appointments,
    COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed,
    COUNT(CASE WHEN status = 'cancelled' THEN 1 END) as cancelled
FROM appointment
GROUP BY appointment_date
ORDER BY appointment_date;


-- employee performanace report
SELECT 
    employee.id AS employee_id,
    employee.first_name,
    employee.last_name,
    COUNT(appointment.id) AS services_completed,
    COALESCE(SUM(service.price), 0) AS total_revenue
FROM employee
JOIN employee_service ON employee_service.employee_id = employee.id
JOIN appointment ON appointment.employee_service_id = employee_service.id
JOIN service ON employee_service.service_id = service.id
GROUP BY employee.id, employee.first_name, employee.last_name
ORDER BY total_revenue DESC;


--Gender-Based Customer Distribution Across Services
SELECT 
    s.service_name,
    c.gender,
    COUNT(DISTINCT c.id) as number_of_customers
FROM appointment a
    JOIN customer c 
        ON a.customer_id = c.id
    JOIN employee_service es 
        ON a.employee_service_id = es.id
    JOIN service s 
        ON es.service_id = s.id
GROUP BY 
    s.service_name,
    c.gender
ORDER BY 
    s.service_name;

--Gender-Based Staff Assignment Analysis
SELECT customer.gender AS customer_gender, 
       employee.gender AS staff_gender,
       COUNT(*) AS total_appointments
FROM appointment
LEFT JOIN customer ON appointment.customer_id = customer.id
LEFT JOIN employee_service ON appointment.employee_service_id = employee_service.id
LEFT JOIN employee ON employee_service.employee_id = employee.id
GROUP BY customer_gender, staff_gender;


--Most popular services
SELECT 
    s.service_name, 
    COUNT(*) AS appointment_count
FROM appointment a
JOIN employee_service es ON a.employee_service_id = es.id
JOIN service s ON es.service_id = s.id
GROUP BY s.service_name
ORDER BY appointment_count DESC;

--Customer Visit Frequency
SELECT 
    customer_id,
    COUNT(*) as visit_count,
    MIN(appointment_date) as first_visit,
    MAX(appointment_date) as last_visit
FROM appointment
GROUP BY customer_id
ORDER BY visit_count DESC;

--Employee service loard
SELECT 
    es.employee_id,
    COUNT(DISTINCT es.service_id) as services_offered,
    COUNT(a.id) as total_appointments
FROM employee_service es
LEFT JOIN appointment a ON es.id = a.employee_service_id
GROUP BY es.employee_id
ORDER BY total_appointments DESC;

--Daily Revenue Report
SELECT 
    a.appointment_date,
    COUNT(*) as total_appointments,
    SUM(p.amount) as total_revenue
FROM appointment a
JOIN payment p ON a.id = p.appointment_id
GROUP BY a.appointment_date
ORDER BY a.appointment_date;

--Busy hour analysis
SELECT 
    EXTRACT(HOUR FROM appointment_time) as hour_of_the_day,
    COUNT(*) as total_appointment_count
FROM appointment
GROUP BY EXTRACT(HOUR FROM appointment_time)
ORDER BY total_appointment_count DESC;

--revenue by each service
SELECT 
    s.service_name,
    COUNT(*) as number_of_appointments,
    SUM(p.amount) as total_revenue,
    ROUND((SUM(p.amount) * 100.0 / (SELECT SUM(amount) FROM payment)), 1) as revenue_percentage
FROM appointment a
JOIN payment p ON a.id = p.appointment_id
JOIN employee_service es ON a.employee_service_id = es.id
JOIN service s ON es.service_id = s.id
WHERE p.status = 'COMPLETED'  -- only completed payments
GROUP BY s.service_name
ORDER BY total_revenue DESC;

WITH employee_service_count AS (
    SELECT 
        s.service_name,
        es.employee_id,
        COUNT(*) as completed_services,
        -- Rank employees within each service based on service count
        RANK() OVER (PARTITION BY s.service_name ORDER BY COUNT(*) DESC) as rank
    FROM appointment a
    JOIN employee_service es ON a.employee_service_id = es.id
    JOIN service s ON es.service_id = s.id
    WHERE a.status = 'completed'  -- Only completed appointments
    GROUP BY s.service_name, es.employee_id
)
SELECT 
    service_name,
    employee_id,
    completed_services as total_appointments
FROM employee_service_count
WHERE rank = 1  -- Only get the top performer for each service
ORDER BY total_appointments DESC;


