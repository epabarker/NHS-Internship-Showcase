SELECT
    subject_id,
    bool_or(infection) infection,
    bool_or(explicit_sepsis) explicit_sepsis,
    bool_or(organ_dysfunction) organ_dysfunction,
    bool_or(mech_vent) mech_vent,
    bool_or(angus_sepsis_icu.angus_sepsis) angus_sepsis
FROM
    mimic_derived.angus_sepsis_icu
GROUP BY subject_id
ORDER BY subject_id;