# Sprint 5 Test Checklist: Vehicle Prioritization by Minimum Trajectories

**Status**: Development ✅ Backend | ⏳ Test Validation | ⏳ Integration

---

## Implementation Summary

### Backend Changes ✅

**File**: [src/main/java/service/PlanningTrajetService.java](src/main/java/service/PlanningTrajetService.java)

#### 1. Modified Method: `trouverMeilleurVehicule(Reservation)`
- **Lines**: 765-800 (refactored)
- **Changes**:
  - ✅ Replaced simple diesel priority with 3-tier Comparator
  - ✅ Added `compterTrajetsVehicule()` as sorting criteria
  - ✅ Implemented capacity as negative (favor higher)
  - ✅ Added vehicle ID as final tiebreaker
- **Logic**:
  ```
  Vehicle selection priority:
  1. Proximité: Diesel (score 0) > Essence (score 1)
  2. Min Trajets: Count distinct date|heure per vehicle
  3. Capacity: Favor higher capacity (inverted sort)
  4. Vehicle ID: Fallback tiebreaker
  ```

#### 2. New Method: `compterTrajetsVehicule(Vehicule)`
- **Lines**: 801-842 (added)
- **Purpose**: Count distinct trajectory slots (date + heure combinations) per vehicle
- **Logic**:
  - Gets all planning entries for vehicle
  - Maps to unique date|heure keys
  - Counts distinct keys using streams
  - Returns int representing trajectory slot count
- **Used By**: Comparator in `trouverMeilleurVehicule()`

---

## Test Strategy

### Prerequisites
1. Database initialized with [database/init/*.sql](database/init)
2. Vehicles table populated with ≥3 diesel vehicles (V1, V2, V3)
3. Maven build successful: `mvn clean package -DskipTests`
4. Application deployed to Docker or local Tomcat

### Test Data
**File**: [database/init/09-sprint5-min-trajets-test-data.sql](database/init/09-sprint5-min-trajets-test-data.sql)

**Structure**:
- **SETUP Phase**: Create initial reservations establishing V1=2, V2=1, V3=2 counts
- **CAS 1**: All vehicles at 0 trajectories (initial state)
- **CAS 2**: V1=2, V2=1, V3=2 créneau → Favor V2
- **CAS 3**: All equal counts (V1=2, V2=2, V3=2) → Use tiebreaker
- **CAS 4**: Equal counts (V1=1, V2=1, V3=1) → Simple tiebreaker
- **CAS 5**: Capacity constraint with 4-person group

---

## Validation Tests

### Unit Tests (Code-Level)

#### Test 1: compterTrajetsVehicule() Logic
```
Objective: Verify trajectory counting accuracy
Steps:
  1. Create planning entries for vehicle V1 with:
     - RES001 at 2025-03-20 08:00
     - RES002 at 2025-03-20 08:00 (same créneau, should count as 1)
     - RES003 at 2025-03-20 09:00 (different créneau, should count as 2)
  2. Call compterTrajetsVehicule(V1)
  3. Assert result == 2 (distinct créneau)

Expected Result: ✅ Count = 2
```

#### Test 2: 3-Tier Comparator Order
```
Objective: Verify Comparator applies priorities in correct order
Setup:
  - V1: Essence, 3 trajectories, capacity 8
  - V2: Diesel, 1 trajectory, capacity 6
  - V3: Diesel, 2 trajectories, capacity 4

Steps:
  1. Create list [V1, V3, V2]
  2. Apply Comparator via min() in trouverMeilleurVehicule()
  3. Assert selected vehicle == V2

Expected Result: ✅ V2 selected (Diesel despite fewer trajets)
```

#### Test 3: Tiebreaker - Equal Diesel Count
```
Objective: Verify capacity tiebreaker when trajets equal
Setup:
  - V1: Diesel, 2 trajectories, capacity 4
  - V2: Diesel, 2 trajectories, capacity 8
  
Steps:
  1. Create list [V1, V2]
  2. Apply Comparator
  3. Assert selected vehicle == V2

Expected Result: ✅ V2 selected (higher capacity)
```

#### Test 4: Final Tiebreaker - Same Everything
```
Objective: Verify vehicle ID used as final tiebreaker
Setup:
  - V1 (ID=101): Diesel, 1 trajectory, capacity 6
  - V2 (ID=105): Diesel, 1 trajectory, capacity 6

Steps:
  1. Apply Comparator
  2. Assert selected vehicle == V1

Expected Result: ✅ V1 selected (lower ID)
```

---

### Integration Tests (Data Flow)

#### Test 5: genererPlanning() with CAS2 Setup Data
```
Objective: Verify prioritization during real planning generation
Setup:
  1. Load 09-sprint5-min-trajets-test-data.sql (SETUP + CAS2)
  2. Ensure no planning/assignation data exists
  3. Call planningTrajetService.genererPlanning()

Verification:
  - SETUP reservations assigned to V1, V2, V3
  - CAS2 "MinTrajet" reservation assigned to V2
  - V2 should have lowest count (1 vs V1=2, V3=2)

Expected Result: ✅ V2 gets assignment
```

#### Test 6: Diesel Priority Override
```
Objective: Verify Diesel prioritized even with fewer trajets
Setup:
  - V1: Essence, 0 trajectories, capacity 8
  - V2: Diesel, 1 trajectory, capacity 6

Create reservation and call genererPlanning()

Expected Result: ✅ V2 selected (Diesel priority > min trajets)
```

#### Test 7: Capacity Constraint Respected
```
Objective: Verify capacity filter doesn't bypass min-trajet priority
Setup:
  - CAS5 with 4-person reservation
  - V1: Diesel, 2 trajets, capacity 3 (insufficient)
  - V2: Diesel, 1 trajet, capacity 6 (sufficient)

Expected Result: ✅ V2 selected (has capacity AND min trajets)
```

---

## Manual Testing Checklist

### 1. Database Integrity
- [ ] Apply migration: `09-sprint5-min-trajets-test-data.sql`
- [ ] Verify 18 test reservations created
- [ ] Check all have `is_confirmed = false`
- [ ] Verify no planning data before genererPlanning()

### 2. Application Start
- [ ] Build: `mvn clean package -DskipTests` ✅
- [ ] Deploy: `docker-compose up -d` (or local Tomcat)
- [ ] Login to backoffice
- [ ] Navigate to "Planning des Trajets" page

### 3. Manual Planning Generation
- [ ] Click "Générer le planning automatiquement"
- [ ] Wait for completion
- [ ] Check planning_trajet table populated:
  ```sql
  SELECT COUNT(*) FROM planning_trajet; -- Should be 18
  SELECT DISTINCT vehicule_id FROM planning_assignation_detail 
  WHERE reservation_id IN (
    SELECT id FROM reservations WHERE nom LIKE 'SPRINT5%'
  );
  ```

### 4. Verify Assignment Order for CAS2
- [ ] Query CAS2 assignments:
  ```sql
  SELECT r.nom, p.vehicule_id, COUNT(DISTINCT 
    DATE(r.date_arrivee) || '|' || r.heure) as trajet_count
  FROM reservations r
  JOIN planning_trajet p ON r.id = p.reservation_id
  WHERE r.nom LIKE '%CAS2%'
  GROUP BY r.nom, p.vehicule_id
  ORDER BY trajet_count;
  ```
- [ ] Expected: V2 gets "MinTrajet" reservation (min 1 count)

### 5. Verify Diesel Priority
- [ ] Check all assignments prioritized diesel
- [ ] Query non-diesel assignments (should be rare):
  ```sql
  SELECT r.nom, v.type_carburant
  FROM reservations r
  JOIN planning_trajet p ON r.id = p.reservation_id
  JOIN vehicule v ON p.vehicule_id = v.id
  WHERE r.nom LIKE 'SPRINT5%'
  AND v.type_carburant != 'Diesel'
  AND EXISTS (
    SELECT 1 FROM vehicule v2 WHERE v2.type_carburant = 'Diesel'
  );
  ```
- [ ] Should be empty (Diesel always prioritized)

### 6. Capacity Constraints
- [ ] CAS5 (4-person) assignment:
  ```sql
  SELECT r.nom, v.id, v.capacite_passagers
  FROM reservations r
  JOIN planning_trajet p ON r.id = p.reservation_id
  JOIN vehicule v ON p.vehicule_id = v.id
  WHERE r.nom LIKE '%CAS5%';
  ```
- [ ] [ ] Vehicle capacity ≥ 4 required

---

## Frontend Validation (Optional - Sprint 5 spec says "No UI changes")

As per TODO: "Frontend : aucun changement"

- [ ] Existing UI displays trajectory counts (if feature available)
- [ ] No new columns required
- [ ] No layout changes need

---

## Performance Checks

#### Test 8: Query Performance
```
Objective: Verify compterTrajetsVehicule() doesn't cause timeouts

Steps:
  1. genererPlanning() with all 18 reservations
  2. Measure execution time: Target < 5 seconds
  3. Check database logs for slow queries

Expected Result: ✅ Completes in < 5 seconds
```

---

## Regression Testing

### Existing Functionality Preserved
- [ ] Sprint 4 features still work:
  - [ ] Wait time grouping (same créneau = 1 planning line)
  - [ ] Planning detail metadata (hours, distance, etc.)
  - [ ] Proximity sorting within créneau
  
- [ ] Sprint 3 features intact:
  - [ ] Multi-client grouping
  - [ ] Capacity-based filtering
  - [ ] Distance calculation
  
- [ ] Basic assignment works:
  - [ ] Reservations assignable manually
  - [ ] No data loss on new assignments
  - [ ] Vehicle details display correctly

---

## Deployment Checklist

### Pre-Deployment
- [ ] Code review completed
- [ ] All tests ✅ or addressed
- [ ] Maven build clean: `mvn clean package -DskipTests` ✅
- [ ] WAR file: `target/ControlTowerBackoffice.war` exists
- [ ] Migration file: `09-sprint5-min-trajets-test-data.sql` validated

### Deployment Steps
1. [ ] Backup database: `docker exec -it db pg_dump controltower > backup_sprint5.sql`
2. [ ] Stop containers: `docker-compose down`
3. [ ] Deploy new image: `docker-compose up -d`
4. [ ] Wait 30s for startup
5. [ ] Verify: `docker logs tomcat | grep "INFO.*started"`
6. [ ] Run regression tests

### Post-Deployment
- [ ] Generate planning → Verify assignments match priorities
- [ ] Check logs for errors: No `ERROR` in logs
- [ ] Verify database: `SELECT COUNT(*) FROM reservations WHERE vehicule_id IS NULL;`
  - Should be < total count (some assigned)

---

## Known Issues & Limitations

| Issue | Impact | Status |
|-------|--------|--------|
| Docker startup timing | Transient with delays | ✅ Managed |
| Null vehicle ID in count | Handled with `<= 0` check | ✅ Fixed |
| Trajectory count accuracy | Depends on date format | ⏳ Validate |
| Mixed fuel types | Not yet tested | ⏳ CAS4 scheduled |
| Capacity limits | Basic testing only | ⏳ CAS5 scheduled |

---

## Success Criteria

✅ = Completed | ⏳ = Pending | ❌ = Failed

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Code compiles without errors | ✅ | Build SUCCESS |
| `compterTrajetsVehicule()` added | ✅ | Lines 801-842 |
| 3-tier Comparator implemented | ✅ | Lines 765-800 |
| Test data created (18 reservations) | ✅ | 09-sprint5 file |
| CAS1 passes (0 trajets all) | ⏳ | Pending execution |
| CAS2 passes (V1=2, V2=1, V3=2) | ⏳ | Pending execution |
| CAS3 passes (equality tiebreaker) | ⏳ | Pending execution |
| CAS4 passes (simple equality) | ⏳ | Pending execution |
| CAS5 passes (capacity constraint) | ⏳ | Pending execution |
| Regression tests pass | ⏳ | Pending execution |

---

## Next Steps

1. **Immediate** (This session):
   - [ ] Deploy to Docker and execute genererPlanning()
   - [ ] Verify CAS test data assignments match predictions
   - [ ] Run regression tests

2. **Follow-up** (Sprint 5 completion):
   - [ ] Document actual vs expected results
   - [ ] Fix any priority ordering issues
   - [ ] Update UI if trajectory counts visible

3. **Sprint 6 Preparation**:
   - Ensure Sprint 5 commits clean
   - Prepare for vehicle splitting logic
   - Test edge cases (1-person reservations, etc.)

---

**Last Updated**: 2026-03-19  
**Author**: Sprint 5 Implementation  
**Status**: Development Phase ✅ | Testing Phase ⏳
