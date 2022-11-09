# Precision Antimicrobial Prescribing in [[Neo4j]]
I want to test to see if Neo4j and graph databases more generally are a good fit for the MIMIC-IV database. What inspired this was looking at a data-led approach to examining the data, and the desire to see all information pertinent to an individual in one place. 

I will limit the size of the database to 100 patients from the Sepsis cohort, which is in turn a subset of the whole MIMIC database. Actions leading up to this are referenced in [[MIMIC-IV Sepsis subset of whole]]. 

## Code
We will be doing a similar thing to the original subset, except this time we are:
- Grabbing the first 100 patients of sepsis derived table
- Finding matches to all tables
- Exporting these smaller tables to csv files for import into Neo4j.


```SQL
--Create Schema for subset if it doesn't exist
DROP SCHEMA IF EXISTS subset_core; CREATE SCHEMA subset_core;
DROP SCHEMA IF EXISTS subset_hosp; CREATE SCHEMA subset_hosp;
DROP SCHEMA IF EXISTS subset_icu; CREATE SCHEMA subset_icu;

-- LIMIT sepsis table to first 100 IDS
-- get set of 100 patients
DROP TABLE IF EXISTS subset_core.patient_subset; CREATE TABLE subset_core.patient_subset AS
SELECT DISTINCT sepsis3.subject_id FROM mimic_derived.sepsis3
JOIN mimic_derived.icustay_detail
ON sepsis3.stay_id = icustay_detail.stay_id
LIMIT 100;

-- limit sepsis table to these IDs
DROP TABLE IF EXISTS subset_core.sepsis_subset; CREATE TABLE subset_core.sepsis_subset AS  
SELECT DISTINCT mimic_derived.icustay_detail.subject_id, mimic_derived.icustay_detail.hadm_id,  mimic_derived.icustay_detail.stay_id FROM mimic_derived.icustay_detail 
INNER JOIN subset_core.patient_subset 
ON mimic_derived.icustay_detail.subject_id = subset_core.patient_subset.subject_id;

-- admissions
DROP TABLE IF EXISTS subset_core.admission_subset; CREATE TABLE subset_core.admission_subset AS
SELECT DISTINCT hadm_id FROM subset_core.sepsis_subset;

-- stays
DROP TABLE IF EXISTS subset_core.stay_subset; CREATE TABLE subset_core.stay_subset AS
SELECT DISTINCT stay_id FROM subset_core.sepsis_subset;

--Create tables where subject_id has highest granularity
-- CORE --
-- patients
DROP TABLE IF EXISTS subset_core.patients; CREATE TABLE subset_core.patients AS
SELECT patients.*
FROM mimic_core.patients
INNER JOIN subset_core.patient_subset ON mimic_core.patients.subject_id = subset_core.patient_subset.subject_id;

--Create tables where hadm_id has highest granularity
-- CORE --
-- admissions
DROP TABLE IF EXISTS subset_core.admissions; CREATE TABLE subset_core.admissions AS
SELECT admissions.*
FROM mimic_core.admissions
INNER JOIN subset_core.admission_subset ON mimic_core.admissions.hadm_id = subset_core.admission_subset.hadm_id;

-- HOSP --
-- diagnoses_icd
DROP TABLE IF EXISTS subset_hosp.diagnoses_icd; CREATE TABLE subset_hosp.diagnoses_icd AS
SELECT diagnoses_icd.*
FROM mimic_hosp.diagnoses_icd
INNER JOIN subset_core.admission_subset ON mimic_hosp.diagnoses_icd.hadm_id = subset_core.admission_subset.hadm_id;

-- drgcodes
DROP TABLE IF EXISTS subset_hosp.drgcodes; CREATE TABLE subset_hosp.drgcodes AS
SELECT drgcodes.*
FROM mimic_hosp.drgcodes
INNER JOIN subset_core.admission_subset ON mimic_hosp.drgcodes.hadm_id = subset_core.admission_subset.hadm_id;

-- emar
DROP TABLE IF EXISTS subset_hosp.emar; CREATE TABLE subset_hosp.emar AS
SELECT emar.*
FROM mimic_hosp.emar
INNER JOIN subset_core.admission_subset ON mimic_hosp.emar.hadm_id = subset_core.admission_subset.hadm_id;

-- hcpcsevents
DROP TABLE IF EXISTS subset_hosp.hcpcsevents; CREATE TABLE subset_hosp.hcpcsevents AS
SELECT hcpcsevents.*
FROM mimic_hosp.hcpcsevents
INNER JOIN subset_core.admission_subset ON mimic_hosp.hcpcsevents.hadm_id = subset_core.admission_subset.hadm_id;

-- microbiologyevents
DROP TABLE IF EXISTS subset_hosp.microbiologyevents; CREATE TABLE subset_hosp.microbiologyevents AS
SELECT microbiologyevents.*
FROM mimic_hosp.microbiologyevents
INNER JOIN subset_core.admission_subset ON mimic_hosp.microbiologyevents.hadm_id = subset_core.admission_subset.hadm_id;

-- pharmacy
DROP TABLE IF EXISTS subset_hosp.pharmacy; CREATE TABLE subset_hosp.pharmacy AS
SELECT pharmacy.*
FROM mimic_hosp.pharmacy
INNER JOIN subset_core.admission_subset ON mimic_hosp.pharmacy.hadm_id = subset_core.admission_subset.hadm_id;

-- poe
DROP TABLE IF EXISTS subset_hosp.poe; CREATE TABLE subset_hosp.poe AS
SELECT poe.*
FROM mimic_hosp.poe
INNER JOIN subset_core.admission_subset ON mimic_hosp.poe.hadm_id = subset_core.admission_subset.hadm_id;

-- prescriptions
DROP TABLE IF EXISTS subset_hosp.prescriptions; CREATE TABLE subset_hosp.prescriptions AS
SELECT prescriptions.*
FROM mimic_hosp.prescriptions
INNER JOIN subset_core.admission_subset ON mimic_hosp.prescriptions.hadm_id = subset_core.admission_subset.hadm_id;

-- procedures_icd
DROP TABLE IF EXISTS subset_hosp.procedures_icd; CREATE TABLE subset_hosp.procedures_icd AS
SELECT procedures_icd.*
FROM mimic_hosp.procedures_icd
INNER JOIN subset_core.admission_subset ON mimic_hosp.procedures_icd.hadm_id = subset_core.admission_subset.hadm_id;

-- services
DROP TABLE IF EXISTS subset_hosp.services; CREATE TABLE subset_hosp.services AS
SELECT services.*
FROM mimic_hosp.services
INNER JOIN subset_core.admission_subset ON mimic_hosp.services.hadm_id = subset_core.admission_subset.hadm_id;

-- transfers
DROP TABLE IF EXISTS subset_core.transfers; CREATE TABLE subset_core.transfers AS
SELECT transfers.*
FROM mimic_core.transfers
INNER JOIN subset_core.admission_subset ON mimic_core.transfers.hadm_id = subset_core.admission_subset.hadm_id;

-- labevents
DROP TABLE IF EXISTS subset_hosp.labevents; CREATE TABLE subset_hosp.labevents AS
SELECT labevents.*
FROM mimic_hosp.labevents
INNER JOIN subset_core.admission_subset ON mimic_hosp.labevents.hadm_id = subset_core.admission_subset.hadm_id;

--Create tables where stay_id has highest granularity
-- CORE --
-- icu_stays
DROP TABLE IF EXISTS subset_icu.icu_stays; CREATE TABLE subset_icu.icu_stays AS
SELECT icustays.*
FROM mimic_icu.icustays
INNER JOIN subset_core.stay_subset ON mimic_icu.icustays.stay_id = subset_core.stay_subset.stay_id;

-- ICU --
-- chartevents
DROP TABLE IF EXISTS subset_icu.chartevents; CREATE TABLE subset_icu.chartevents AS
SELECT chartevents.*
FROM mimic_icu.chartevents
INNER JOIN subset_core.stay_subset ON mimic_icu.chartevents.stay_id = subset_core.stay_subset.stay_id;

-- datetimeevents
DROP TABLE IF EXISTS subset_icu.datetimeevents; CREATE TABLE subset_icu.datetimeevents AS
SELECT datetimeevents.*
FROM mimic_icu.datetimeevents
INNER JOIN subset_core.stay_subset ON mimic_icu.datetimeevents.stay_id = subset_core.stay_subset.stay_id;

-- inputevents
DROP TABLE IF EXISTS subset_icu.inputevents; CREATE TABLE subset_icu.inputevents AS
SELECT inputevents.*
FROM mimic_icu.inputevents
INNER JOIN subset_core.stay_subset ON mimic_icu.inputevents.stay_id = subset_core.stay_subset.stay_id;

-- procedureevents
DROP TABLE IF EXISTS subset_icu.procedureevents; CREATE TABLE subset_icu.procedureevents AS
SELECT procedureevents.*
FROM mimic_icu.procedureevents
INNER JOIN subset_core.stay_subset ON mimic_icu.procedureevents.stay_id = subset_core.stay_subset.stay_id;

-- outputevents
DROP TABLE IF EXISTS subset_icu.outputevents; CREATE TABLE subset_icu.outputevents AS
SELECT outputevents.*
FROM mimic_icu.outputevents
INNER JOIN subset_core.stay_subset ON mimic_icu.outputevents.stay_id = subset_core.stay_subset.stay_id;

-- Create/Copy tables that require no alteration
-- HOSP --
-- d_hcpcs
DROP TABLE IF EXISTS subset_hosp.d_hcpcs; CREATE TABLE subset_hosp.d_hcpcs AS
SELECT * FROM mimic_hosp.d_hcpcs;

-- d_icd_diagnoses
DROP TABLE IF EXISTS subset_hosp.d_icd_diagnoses; CREATE TABLE subset_hosp.d_icd_diagnoses AS
SELECT * FROM mimic_hosp.d_icd_diagnoses;

-- d_icd_procedures
DROP TABLE IF EXISTS subset_hosp.d_icd_procedures; CREATE TABLE subset_hosp.d_icd_procedures AS
SELECT * FROM mimic_hosp.d_icd_procedures;

-- d_labitems
DROP TABLE IF EXISTS subset_hosp.d_labitems; CREATE TABLE subset_hosp.d_labitems AS
SELECT * FROM mimic_hosp.d_labitems;

-- ICU --
-- d_items
DROP TABLE IF EXISTS subset_icu.d_items; CREATE TABLE subset_icu.d_items AS
SELECT * FROM mimic_icu.d_items;

-- EMAR_DETAIL & POE_DETAIL --
-- emar_detail
DROP TABLE IF EXISTS subset_hosp.emar_detail; CREATE TABLE subset_hosp.emar_detail AS
SELECT emar_detail.*
FROM mimic_hosp.emar_detail
INNER JOIN mimic_hosp.emar ON mimic_hosp.emar_detail.emar_id = mimic_hosp.emar.emar_id;

-- poe_detail
DROP TABLE IF EXISTS subset_hosp.poe_detail; CREATE TABLE subset_hosp.poe_detail AS
SELECT poe_detail.*
FROM mimic_hosp.poe_detail
INNER JOIN mimic_hosp.poe ON mimic_hosp.poe_detail.poe_id = mimic_hosp.poe.poe_id;



-- Drop temporary table subset_ids
DROP TABLE IF EXISTS subset_core.patient_subset;
DROP TABLE IF EXISTS subset_core.admission_subset;
DROP TABLE IF EXISTS subset_core.stay_subset;

-- EXPORT TABLES --
COPY  TO 'C:/Users/gq19765/OneDrive - University of Bristol/Documents/Projects/PAMP/PAMP_subset_Neo4j/' CSV HEADER;

```
