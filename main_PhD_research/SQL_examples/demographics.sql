SELECT mimic_core.patients.gender,mimic_core.patients.anchor_age,mimic_core.admissions.ethnicity
FROM mimic_core.patients
INNER JOIN mimic_core.admissions ON mimic_core.patients.subject_id=mimic_core.admissions.subject_id