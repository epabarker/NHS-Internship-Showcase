SELECT
    subject_id,
    bool_or(infection) infection,
    bool_or(explicit_sepsis) explicit_sepsis,
    bool_or(organ_dysfunction) organ_dysfunction,
    bool_or(mech_vent) mech_vent,
    bool_or(angus_sepsis.angus_sepsis) angus_sepsis
FROM
    mimic_derived.angus_sepsis
GROUP BY subject_id
ORDER BY subject_id;