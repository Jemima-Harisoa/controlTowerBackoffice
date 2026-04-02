-- ===============================================================================================
-- SPRINT 5: Vehicle Prioritization - Minimum Trajectories
-- ===============================================================================================
-- Objective: Test 3-tier priority system via genererPlanning() execution
-- Priority: 1. Proximité (Diesel=0, Essence=1) 
--           2. Min créneau count (distinct date|heure per vehicle)
--           3. Available capacity (higher is better)
-- 
-- Prerequisite: Execute genererPlanning() after inserting reservations to establish
-- trajectory counts on vehicles, then verify assignment order matches priorities
-- ===============================================================================================

-- Reset test data for Sprint 5
-- Note: planning_assignation_detail doesn't exist - use planning_trajet_detail instead
DELETE FROM planning_trajet_detail WHERE id > 0;
DELETE FROM planning_trajet WHERE id > 0;
DELETE FROM reservations WHERE nom LIKE '%SPRINT5%';

-- ===============================================================================================
-- SETUP PHASE: Establish trajectory counts by creating initial reservations
-- After genererPlanning() execution:
-- - V1 will have 2 créneau (08:00, 09:00 on same date)
-- - V2 will have 1 créneau (10:00 on same date)
-- - V3 will have 2 créneau (08:00, 11:00 on same date)
-- ===============================================================================================

-- Batch 1: Create unassigned reservations to build V1=2, V2=1, V3=2 counts
-- V1 gets 2 créneau: 08:00 and 09:00
INSERT INTO reservations (nom, email, date_arrivee, heure, nombre_personnes, hotel_id, is_confirmed) VALUES
('SPRINT5-SETUP-001-V1-H0800', 'setup@sprint5.com', '2025-03-20 08:00:00', '08:00', 2, 1, false),
('SPRINT5-SETUP-002-V1-H0900', 'setup@sprint5.com', '2025-03-20 09:00:00', '09:00', 2, 1, false);

-- V2 gets 1 créneau: 10:00
INSERT INTO reservations (nom, email, date_arrivee, heure, nombre_personnes, hotel_id, is_confirmed) VALUES
('SPRINT5-SETUP-003-V2-H1000', 'setup@sprint5.com', '2025-03-20 10:00:00', '10:00', 2, 1, false);

-- V3 gets 2 créneau: 08:00 and 11:00
INSERT INTO reservations (nom, email, date_arrivee, heure, nombre_personnes, hotel_id, is_confirmed) VALUES
('SPRINT5-SETUP-004-V3-H0800', 'setup@sprint5.com', '2025-03-20 08:00:00', '08:00', 2, 1, false),
('SPRINT5-SETUP-005-V3-H1100', 'setup@sprint5.com', '2025-03-20 11:00:00', '11:00', 2, 1, false);

-- ===============================================================================================
-- CAS 1: All vehicles at 0 trajectory (Initial state before any assignments)
-- Expected: Diesel priority (0) > capacity (inverted) > vehicle ID
-- Result: First assignment goes to diesel vehicle with highest capacity
-- Verification: Run genererPlanning() with empty database → V3 gets first (highest capacity)
-- ===============================================================================================
-- Note: Test this by dropping all planning data and running genererPlanning() on case 1 only
INSERT INTO reservations (nom, email, date_arrivee, heure, nombre_personnes, hotel_id, is_confirmed) VALUES
('SPRINT5-CAS1-RES001-INIT', 'test@cas1.com', '2025-03-21 08:00:00', '08:00', 2, 1, false);


-- ===============================================================================================
-- CAS 2: V1=2, V2=1, V3=2 créneau (After SETUP phase assignments)
-- Expected: New reservation should favor V2 (min count = 1)
-- Verification: genererPlanning() with SETUP phase data assigned → V2 gets assignment
-- ===============================================================================================
INSERT INTO reservations (nom, email, date_arrivee, heure, nombre_personnes, hotel_id, is_confirmed) VALUES
('SPRINT5-CAS2-RES001-MinTrajet', 'test@cas2.com', '2025-03-20 12:00:00', '12:00', 2, 1, false);


-- ===============================================================================================
-- CAS 3: All vehicles equal count (V1=2, V2=2, V3=2 créneau)
-- Expected: Use Diesel tiebreaker (0), then capacity tiebreaker
-- Setup: After CAS2 assignment, V2 now has 2 like V1 and V3
-- Verification: Next reservation should favor Diesel with highest capacity
-- ===============================================================================================
INSERT INTO reservations (nom, email, date_arrivee, heure, nombre_personnes, hotel_id, is_confirmed) VALUES
('SPRINT5-CAS3-RES001-TiebreakerDiesel', 'test@cas3.com', '2025-03-20 13:00:00', '13:00', 2, 1, false);


-- ===============================================================================================
-- CAS 4: Single count equality (V1=1, V2=1, V3=1 créneau)
-- Expected: Favor Diesel (0), then capacity
-- Scenario: Very simple case with minimal assignments → tests basic tiebreaker
-- ===============================================================================================
INSERT INTO reservations (nom, email, date_arrivee, heure, nombre_personnes, hotel_id, is_confirmed) VALUES
('SPRINT5-CAS4-RES001', 'test@cas4.com', '2025-03-22 08:00:00', '08:00', 2, 1, false),
('SPRINT5-CAS4-RES002', 'test@cas4.com', '2025-03-22 09:00:00', '09:00', 2, 1, false),
('SPRINT5-CAS4-RES003', 'test@cas4.com', '2025-03-22 10:00:00', '10:00', 2, 1, false);


-- ===============================================================================================
-- CAS 5: Capacity constraint vs min trajectory
-- Expected: Min trajectory still prioritized if capacity OK
-- Scenario: 4-person reservation needs vehicle with ≥4 capacity
-- ===============================================================================================
INSERT INTO reservations (nom, email, date_arrivee, heure, nombre_personnes, hotel_id, is_confirmed) VALUES
('SPRINT5-CAS5-RES001-4Person', 'test@cas5.com', '2025-03-23 08:00:00', '08:00', 4, 1, false);

-- ===============================================================================================
-- TESTING METHODOLOGY
-- ===============================================================================================
-- 1. Verify compterTrajetsVehicule() returns correct counts
-- 2. Execute genererPlanning() and observe vehicle assignments
-- 3. Validate:
--    ✓ CAS1: Highest capacity assigned first (when all at 0)
--    ✓ CAS2: Min trajectory vehicle (V2) gets preference
--    ✓ CAS3: Diesel + capacity tiebreaker works
--    ✓ CAS4: Simple equal case uses tiebreaker
--    ✓ CAS5: Capacity constraint respected but min-traj still prioritized
-- ===============================================================================================
