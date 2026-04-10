Query 1 — Overall no-show rate by gender
SELECT
  gender,
  COUNT(*) AS total_appointments,
  SUM(no_show_flag) AS total_no_shows,
  ROUND(SUM(no_show_flag) / COUNT(*) * 100, 2) AS no_show_rate_pct
FROM
  `hospital-analysis-492900.hospital_data.appointments`
GROUP BY
  gender
ORDER BY
  no_show_rate_pct DESC;


Query 2 — No-show rate by age group
SELECT
  age_group,
  COUNT(*) AS total_appointments,
  SUM(no_show_flag) AS total_no_shows,
  ROUND(SUM(no_show_flag) / COUNT(*) * 100, 2) AS no_show_rate_pct
FROM
  `hospital-analysis-492900.hospital_data.appointments`
GROUP BY
  age_group
ORDER BY
  CASE age_group
    WHEN 'Child' THEN 1
    WHEN 'Young Adult' THEN 2
    WHEN 'Adult' THEN 3
    WHEN 'Senior' THEN 4
  END;


Query 3 — Top 10 neighbourhoods with highest no-show rates (min 100 appointments)
SELECT
  neighbourhood,
  COUNT(*) AS total_appointments,
  SUM(no_show_flag) AS total_no_shows,
  ROUND(SUM(no_show_flag) / COUNT(*) * 100, 2) AS no_show_rate_pct
FROM
  `hospital-analysis-492900.hospital_data.appointments`
GROUP BY
  neighbourhood
HAVING
  COUNT(*) >= 100
ORDER BY
  no_show_rate_pct DESC
LIMIT 10;


Query 4 — Impact of SMS reminders on no-show rate
SELECT
  CASE sms_received
    WHEN 1 THEN 'SMS Sent'
    WHEN 0 THEN 'No SMS'
  END AS sms_status,
  COUNT(*) AS total_appointments,
  SUM(no_show_flag) AS total_no_shows,
  ROUND(SUM(no_show_flag) / COUNT(*) * 100, 2) AS no_show_rate_pct
FROM
  `hospital-analysis-492900.hospital_data.appointments`
GROUP BY
  sms_received
ORDER BY
  sms_received;


Query 5 — Monthly appointment volume and no-show trend
SELECT
  FORMAT_DATE('%Y-%m', appointment_day) AS appointment_month,
  COUNT(*) AS total_appointments,
  SUM(no_show_flag) AS total_no_shows,
  ROUND(SUM(no_show_flag) / COUNT(*) * 100, 2) AS no_show_rate_pct
FROM
  `hospital-analysis-492900.hospital_data.appointments`
GROUP BY
  appointment_month
ORDER BY
  appointment_month;



