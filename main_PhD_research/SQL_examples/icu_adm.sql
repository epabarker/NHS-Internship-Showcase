SELECT mimic_derived.angus_sepsis.*, mimic_icu.icustays.first_careunit, mimic_icu.icustays.last_careunit
FROM mimic_derived.angus_sepsis
INNER JOIN mimic_icu.icustays ON mimic_derived.angus_sepsis.hadm_id = mimic_icu.icustays.hadm_id