-- ============================================================================
-- SCRIPT DE DATOS DE PRUEBA "GYM OS"
-- Genera 30 miembros, suscripciones variadas y registros financieros.
-- ============================================================================

-- 1. LIMPIEZA
DELETE FROM financial_entries;
DELETE FROM payments;
DELETE FROM subscriptions;
DELETE FROM members;
-- DELETE FROM plans; -- Opcional, mantener si ya existen

-- 2. PLANES BASE (Si no existen)
INSERT OR IGNORE INTO plans (id, name, duration_days, price, is_active) VALUES 
(1, 'Mensual', 30, 3000, 1),
(2, 'Trimestral', 90, 8500, 1),
(3, 'Anual', 365, 30000, 1),
(4, 'Clase Suelta', 1, 500, 1),
(5, 'Semestral', 180, 16000, 1);

-- 3. MIEMBROS (30 Perfiles Variados)
INSERT INTO members (id, first_name, last_name, email, phone, health_notes, created_at) VALUES 
(1, 'Agustin', 'López', 'agus.lopez@gmail.com', '115550001', 'Asmático', date('now', '-300 days')),
(2, 'Valentina', 'Martinez', 'valen.m@hotmail.com', '115550002', NULL, date('now', '-250 days')),
(3, 'Camila', 'Rodriguez', 'camila.r@yahoo.com', '115550003', 'Lesión rodilla', date('now', '-200 days')),
(4, 'Mateo', 'Garcia', 'mateo.g@outlook.com', '115550004', NULL, date('now', '-180 days')),
(5, 'Nicolas', 'Fernandez', 'nico.fer@gmail.com', '115550005', NULL, date('now', '-150 days')),
(6, 'Luciana', 'Gonzalez', 'luli.gonz@gmail.com', '115550006', 'Hipertensión', date('now', '-120 days')),
(7, 'Joaquin', 'Perez', 'joaco.p@live.com', '115550007', NULL, date('now', '-100 days')),
(8, 'Mia', 'Sanchez', 'mia.sanchez@gmail.com', '115550008', NULL, date('now', '-90 days')),
(9, 'Bautista', 'Romero', 'bauti.r@gmail.com', '115550009', 'Alergia al polen', date('now', '-80 days')),
(10, 'Delfina', 'Diaz', 'delfi.d@gmail.com', '115550010', NULL, date('now', '-75 days')),
(11, 'Felipe', 'Alvarez', 'feli.alv@gmail.com', '115550011', NULL, date('now', '-60 days')),
(12, 'Catalina', 'Torres', 'cata.torres@gmail.com', '115550012', NULL, date('now', '-55 days')),
(13, 'Tomas', 'Ruiz', 'tomas.r@gmail.com', '115550013', 'Diabetes Tipo 2', date('now', '-50 days')),
(14, 'Emilia', 'Sosa', 'emi.sosa@gmail.com', '115550014', NULL, date('now', '-45 days')),
(15, 'Lautaro', 'Castro', 'lauti.c@gmail.com', '115550015', NULL, date('now', '-40 days')),
(16, 'Sofia', 'Muñoz', 'sofia.m@gmail.com', '115550016', NULL, date('now', '-35 days')),
(17, 'Franco', 'Ortiz', 'franco.o@gmail.com', '115550017', 'Dolor lumbar', date('now', '-30 days')),
(18, 'Juana', 'Nuñez', 'juana.n@gmail.com', '115550018', NULL, date('now', '-28 days')),
(19, 'Benjamín', 'Luna', 'benja.l@gmail.com', '115550019', NULL, date('now', '-25 days')),
(20, 'Renata', 'Juarez', 'rena.j@gmail.com', '115550020', NULL, date('now', '-20 days')),
(21, 'Santino', 'Cabrera', 'santi.c@gmail.com', '115550021', NULL, date('now', '-15 days')),
(22, 'Martina', 'Rios', 'martu.r@gmail.com', '115550022', NULL, date('now', '-12 days')),
(23, 'Ignacio', 'Ferreyra', 'nacho.f@gmail.com', '115550023', NULL, date('now', '-10 days')),
(24, 'Abril', 'Gimenez', 'abril.g@gmail.com', '115550024', NULL, date('now', '-8 days')),
(25, 'Lorenzo', 'Duarte', 'lolo.d@gmail.com', '115550025', NULL, date('now', '-5 days')),
(26, 'Victoria', 'Acosta', 'vicky.a@gmail.com', '115550026', NULL, date('now', '-3 days')),
(27, 'Pedro', 'Silva', 'pedro.s@gmail.com', '115550027', NULL, date('now', '-2 days')),
(28, 'Zoe', 'Flores', 'zoe.f@gmail.com', '115550028', NULL, date('now', '-1 day')),
(29, 'Simon', 'Pereyra', 'simon.p@gmail.com', '115550029', 'Marcapasos', date('now', 'start of day')),
(30, 'Olivia', 'Benitez', 'oli.benitez@gmail.com', '115550030', NULL, date('now', 'start of day'));


-- 4. SUSCRIPCIONES Y PAGOS (Lógica compleja para generar estados variados)
-- Usamos una tabla temporal para iterar o simplemente queries secuenciales.

-- BLOQUE A: Suscripciones ACTIVAS - Plan Mensual (Recientes)
-- Miembros 17-25
INSERT INTO subscriptions (member_id, plan_id, start_date, enrollment_fee) VALUES
(17, 1, date('now', '-5 days'), 0),
(18, 1, date('now', '-10 days'), 0),
(19, 1, date('now', '-15 days'), 0),
(20, 1, date('now', '-20 days'), 0),
(21, 1, date('now', '-5 days'), 0),
(22, 1, date('now', '-2 days'), 0),
(23, 1, date('now', '-3 days'), 0),
(24, 1, date('now', '-7 days'), 0),
(25, 1, date('now', '-1 day'), 0);

-- BLOQUE B: Suscripciones ACTIVAS - Plan Trimestral
-- Miembros 4-8
INSERT INTO subscriptions (member_id, plan_id, start_date, enrollment_fee) VALUES
(4, 2, date('now', '-30 days'), 0),
(5, 2, date('now', '-60 days'), 0),
(6, 2, date('now', '-15 days'), 0),
(7, 2, date('now', '-10 days'), 0),
(8, 2, date('now', '-80 days'), 0); -- A punto de vencer en 10 días

-- BLOQUE C: Suscripciones ACTIVAS - Plan Anual
-- Miembros 1-3
INSERT INTO subscriptions (member_id, plan_id, start_date, enrollment_fee) VALUES
(1, 3, date('now', '-300 days'), 0), -- Vence en 65 días
(2, 3, date('now', '-100 days'), 0),
(3, 3, date('now', '-200 days'), 0);

-- BLOQUE D: Suscripciones POR VENCER (Vencen en < 7 dias)
-- Miembros 9-12 (Plan Mensual iniciado hace ~25 dias)
INSERT INTO subscriptions (member_id, plan_id, start_date, enrollment_fee) VALUES
(9, 1, date('now', '-25 days'), 0),
(10, 1, date('now', '-28 days'), 0), -- Vence en 2 días
(11, 1, date('now', '-29 days'), 0), -- Vence mañana
(12, 1, date('now', '-24 days'), 0);

-- BLOQUE E: Suscripciones VENCIDAS (Expiradas hace poco)
-- Miembros 13-16
INSERT INTO subscriptions (member_id, plan_id, start_date, enrollment_fee) VALUES
(13, 1, date('now', '-35 days'), 0), -- Venció hace 5 días
(14, 1, date('now', '-60 days'), 0),
(15, 2, date('now', '-100 days'), 0), -- Trimestral vencido hace 10 días
(16, 1, date('now', '-40 days'), 0);

-- BLOQUE F: Nuevos Ingresos (Hoy)
INSERT INTO subscriptions (member_id, plan_id, start_date, enrollment_fee) VALUES
(26, 1, date('now'), 1000), -- Pagó matrícula
(27, 2, date('now'), 1000),
(28, 3, date('now'), 0),
(29, 4, date('now'), 0),
(30, 5, date('now'), 0);

-- 5. GENERAR PAGOS Y ENTRADAS FINANCIERAS PARA TODAS LAS SUSCRIPCIONES INSERTADAS
-- Insertamos pagos para todas las suscripciones creadas arriba.
-- Nota: SQLite no tiene variables fáciles en scripts batch, así que hacemos INSERT ... SELECT

INSERT INTO payments (subscription_id, amount, payment_date, payment_type)
SELECT 
    s.id, 
    p.price, 
    s.start_date, 
    'enrollment' -- Simplificación: asumimos que el primer pago es "enrollment" o alta
FROM subscriptions s
JOIN plans p ON s.plan_id = p.id;

-- Insertar Pagos de Matrícula (solo donde enrollment_fee > 0)
INSERT INTO payments (subscription_id, amount, payment_date, payment_type)
SELECT 
    s.id, 
    s.enrollment_fee, 
    s.start_date, 
    'enrollment'
FROM subscriptions s
WHERE s.enrollment_fee > 0;

-- 6. GENERAR ENTRADAS FINANCIERAS (Para el Dashboard)
-- Ingresos por Planes
INSERT INTO financial_entries (entry_type, classification, amount, description, payment_id, entry_date)
SELECT 
    'renewal_income', 
    'income', 
    pay.amount, 
    'Pago de suscripción - ' || m.first_name || ' ' || m.last_name, 
    pay.id, 
    pay.payment_date
FROM payments pay
JOIN subscriptions s ON pay.subscription_id = s.id
JOIN members m ON s.member_id = m.id
WHERE pay.amount > 0 AND s.enrollment_fee = 0; -- Excluir matrículas explicítas para no duplicar lógica visual

-- Ingresos por Matrículas
INSERT INTO financial_entries (entry_type, classification, amount, description, payment_id, entry_date)
SELECT 
    'enrollment_income', 
    'income', 
    pay.amount, 
    'Pago de Matrícula - ' || m.first_name || ' ' || m.last_name, 
    pay.id, 
    pay.payment_date
FROM payments pay
JOIN subscriptions s ON pay.subscription_id = s.id
JOIN members m ON s.member_id = m.id
WHERE pay.amount > 0 AND s.enrollment_fee > 0 AND pay.amount = s.enrollment_fee;

-- GASTOS FIJOS (Ejemplo)
INSERT INTO financial_entries (entry_type, classification, amount, description, entry_date) VALUES 
('custom_expense', 'expense', 50000, 'Alquiler Local', date('now', 'start of month')),
('custom_expense', 'expense', 15000, 'Luz y Agua', date('now', '-5 days')),
('custom_expense', 'expense', 8000, 'Internet', date('now', '-10 days')),
('custom_expense', 'expense', 12000, 'Limpieza', date('now', '-2 days'));

