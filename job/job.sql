SELECT

job,
what,
TO_CHAR (next_date, 'DD/MM/YYYY HH24: MI : SS') AS proxima_execucao,
broken
FROM user_jobs
WHERE UPPER (what) LIKE '%CONSULTA%';