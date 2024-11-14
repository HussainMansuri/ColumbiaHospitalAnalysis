#Q15. Identify the top 5 doctors who generated the most revenue but had the fewest patients. (SQL)

SELECT Doctor_Name, SUM(Total_Bill) AS 'Total Revenue',COUNT(Patient_ID) AS 'No_of_patients'
FROM doctor_patients_data
GROUP BY Doctor_Name
ORDER BY Total_Bill DESC, No_of_patients ASC
LIMIT 5;


#Q16.Find the department where the average waiting time has decreased over three consecutive months. (SQL)

WITH AvgWaitTimeByMonth AS (
    SELECT `department_referral`,      CONCAT(Year, '-', Month) AS YearMonth,  
        ROUND(AVG(patient_waittime),2) AS AvgWaitTime
    FROM
        hospital_er_data  
    GROUP BY `department_referral`, Year, Month
),

WaitTimeWithLag AS (
    SELECT `department_referral`,YearMonth, AvgWaitTime,
        LAG(AvgWaitTime, 1) OVER (PARTITION BY department_referral ORDER BY YearMonth) AS PrevMonthAvg,
        LAG(AvgWaitTime, 2) OVER (PARTITION BY department_referral ORDER BY YearMonth) AS TwoMonthsAgoAvg
    FROM
        AvgWaitTimeByMonth
)
SELECT `department_referral`,YearMonth,AvgWaitTime,PrevMonthAvg,TwoMonthsAgoAvg
FROM
    WaitTimeWithLag
WHERE
    AvgWaitTime < PrevMonthAvg  
    AND PrevMonthAvg < TwoMonthsAgoAvg  
ORDER BY department_referral, YearMonth ASC;



#Q17. Determine the ratio of male to female patients for each doctor and rank the doctors based on this ratio. (SQL)

WITH male_female_count AS (
SELECT dp.Doctor_Name, SUM(CASE WHEN patient_gender = "F" THEN 1 ELSE 0 END) AS Female_count,
					   SUM(CASE WHEN patient_gender = "M" THEN 1 ELSE 0 END) AS Male_count
FROM doctor_patients_data dp
JOIN hospital_er_data he
ON dp.patient_id = he.patient_id
GROUP BY dp.Doctor_Name),
ratioed_table AS 
( SELECT Doctor_Name, ROUND((Male_count/Female_count),2) AS male_to_female_ratio
FROM male_female_count)
SELECT *,DENSE_RANK() OVER(ORDER BY male_to_female_ratio) AS ranked_by_ratio FROM ratioed_table;



#Q18. Calculate the average satisfaction score of patients for each doctor based on their visits. (SQL)

SELECT dp.Doctor_Name, ROUND(AVG(he.patient_sat_score),2) AS `Average Satisfaction Score`
FROM doctor_patients_data dp
JOIN hospital_er_data he
ON dp.patient_id = he.patient_id
GROUP BY 1
ORDER BY `Average Satisfaction Score`;



#Q19.Find doctors who have treated patients from different races and calculate the diversity of their patient base. (SQL)


SELECT dp.Doctor_Name, ROUND((SUM(CASE WHEN LOWER(he.patient_race) = "white" THEN 1 ELSE 0 END ))/COUNT(he.patient_ID),2)*100 AS percent_Of_white_patients,
						ROUND((SUM(CASE WHEN LOWER(he.patient_race) = "african american" THEN 1 ELSE 0 END))/COUNT(he.patient_ID),2)*100 AS Percent_of_african_american_patients,
                        ROUND((SUM(CASE WHEN LOWER(he.patient_race) = "asian" THEN 1 ELSE 0 END))/COUNT(he.patient_ID),2)*100 AS Percent_of_asian_patients,
                        ROUND((SUM(CASE WHEN LOWER(he.patient_race) = "native american/alaska native" THEN 1 ELSE 0 END))/COUNT(he.patient_ID),2)*100 AS Percent_of_native_patients,
                        ROUND((SUM(CASE WHEN LOWER(he.patient_race) = "pacific islander" THEN 1 ELSE 0 END))/COUNT(he.patient_ID),2)*100 AS Percent_of_pacific_islander_patients,
                        ROUND((SUM(CASE WHEN LOWER(he.patient_race) = "two or more races" THEN 1 ELSE 0 END))/COUNT(he.patient_ID),2)*100 AS Percent_of_mixed_race,
                        ROUND((SUM(CASE WHEN LOWER(he.patient_race) = "declined to identify" THEN 1 ELSE 0 END))/COUNT(he.patient_ID),2)*100 AS Percent_of_declined_to_identify,
                        COUNT(he.patient_ID) AS Total_patients
FROM doctor_patients_data dp
JOIN hospital_er_data he
ON dp.patient_id = he.patient_id
GROUP BY dp.Doctor_ID;



#Q20. Calculate the ratio of total bills generated by male patients to female patients for each department. (SQL)

WITH male_female_count AS (
SELECT dp.department_referral AS Department_Name, SUM(CASE WHEN patient_gender = "F" THEN dp.Total_Bill ELSE 0 END) AS Female_Bill_Total,
					   SUM(CASE WHEN patient_gender = "M" THEN dp.Total_Bill ELSE 0 END) AS Male_Bill_Total
FROM doctor_patients_data dp
JOIN hospital_er_data he
ON dp.patient_id = he.patient_id
GROUP BY dp.department_referral)
SELECT Department_Name, ROUND((Male_Bill_Total/Female_Bill_Total),2) AS male_to_female_bill_ratio
FROM male_female_count
ORDER BY male_to_female_bill_ratio DESC;

/* #Q21.Update the patient satisfaction 
score for all patients who visited the "General Practice" department and had a waiting time of more than 30 minutes.
Increase their satisfaction score by 2 points, but ensure that the satisfaction score does not exceed 10. (SQL) */

UPDATE hospital_er_data 
SET patient_sat_score = LEAST(patient_sat_score + 2,10)
WHERE LOWER(department_referral) = "general practice" AND patient_waittime > 30;





