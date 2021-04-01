SELECT pid, UPPER(TRIM(pname)) AS name,
  TO_CHAR(dobirth, 'DD-MON-RRRR HH24:MI:SS') AS dob,
  TO_CHAR(SYSDATE, 'DD-MON-RRRR HH24:MI:SS') AS today,
  --TRUNC((SYSDATE - dobirth)/365.25) AS age_years
  EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM dobirth) AS age_years
  FROM patient;
  WHERE TRUNC((SYSDATE - dobirth)/365.25) > &age;

SELECT pid, UPPER(TRIM(pname)) AS name,
  EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM dobirth) AS age_years
  FROM patient;

SELECT p.pid AS "PATIENT ID#", UPPER(TRIM(pname)) AS name, 
  TO_CHAR(vdate, 'DD-MON-RRRR HH24:MI:SS') AS vdate
  FROM patient p, visits v
  WHERE p.pid = v.pid;


SELECT p1.pid, UPPER(TRIM(pname)) AS name, v1.vaccinated, vdate
  FROM patient p1, vaccinations v1
  WHERE p1.pid IN(
    SELECT p.pid FROM patient p, vaccinations v
    WHERE p.pid = v.pid
    AND EXTRACT(YEAR FROM vdate) > 2006
    AND UPPER(vaccinated) = 'TYPHOID'
  AND EXTRACT(YEAR FROM vdate) > 2006
  AND UPPER(vaccinated) = 'TYPHOID');
  AND EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM dobirth) < 30;

SELECT p.pid, UPPER(TRIM(pname)) AS name, vaccinated, vdate
SELECT p.pid, pname, vaccinated, vdate FROM patient p, vaccinations v
        WHERE p.pid = v.pid
        AND EXTRACT(YEAR FROM vdate) > 2006
        AND UPPER(vaccinated) = 'TYPHOID';

  