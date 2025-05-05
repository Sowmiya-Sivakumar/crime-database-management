create database crime
use crime
CREATE TABLE Crime ( 
    CrimeID INT PRIMARY KEY, 
    IncidentType VARCHAR(255), 
    IncidentDate DATE, 
    Location VARCHAR(255), 
    Description TEXT, 
    Status VARCHAR(20) 
); 
CREATE TABLE Victim ( 
    VictimID INT PRIMARY KEY, 
    CrimeID INT, 
    Name VARCHAR(255), 
    ContactInfo VARCHAR(255), 
    Injuries VARCHAR(255), 
    FOREIGN KEY (CrimeID) REFERENCES Crime(CrimeID) 
); 
CREATE TABLE Suspect ( 
    SuspectID INT PRIMARY KEY, 
    CrimeID INT, 
    Name VARCHAR(255), 
    Description TEXT, 
    CriminalHistory TEXT, 
    FOREIGN KEY (CrimeID) REFERENCES Crime(CrimeID) 
); 
INSERT INTO Crime (CrimeID, IncidentType, IncidentDate, Location, Description, Status) 
VALUES 
    (1, 'Robbery', '2023-09-15', '123 Main St, Cityville', 'Armed robbery at a convenience store', 'Open'), 
    (2, 'Homicide', '2023-09-20', '456 Elm St, Townsville', 'Investigation into a murder case', 'Under 
Investigation'), 
    (3, 'Theft', '2023-09-10', '789 Oak St, Villagetown', 'Shoplifting incident at a mall', 'Closed'); 
    select * from Crime
    INSERT INTO Victim (VictimID, CrimeID, Name, ContactInfo, Injuries) 
VALUES 
    (1, 1, 'John Doe', 'johndoe@example.com', 'Minor injuries'), 
    (2, 2, 'Jane Smith', 'janesmith@example.com', 'Deceased'), 
(3, 3, 'Alice Johnson', 'alicejohnson@example.com', 'None');
select * from Victim
INSERT INTO Suspect (SuspectID, CrimeID, Name, Description, CriminalHistory) 
VALUES 
(1, 1, 'Robber 1', 'Armed and masked robber', 'Previous robbery convictions'), 
(2, 2, 'Unknown', 'Investigation ongoing', NULL), 
(3, 3, 'Suspect 1', 'Shoplifting suspect', 'Prior shoplifting arrests'); 
select * from Suspect
-- 1. Select all open incidents --
select * from crime
where status ='open'

-- 2. Find the total number of incidents --
SELECT COUNT(*) AS TotalIncidents FROM Crime;

-- 3. List all unique incident types. --
SELECT DISTINCT IncidentType FROM Crime;

-- 4. Retrieve incidents that occurred between '2023-09-01' and '2023-09-10'. --
select * from crime 
where Incidentdate between'2023-09-01' and '2023-09-10';

-- 5. List persons involved in incidents in descending order of age.  --
ALTER TABLE Victim ADD Age INT;
ALTER TABLE Suspect ADD Age INT;
-- Victims
UPDATE Victim SET Age = 30 WHERE VictimID = 1;
UPDATE Victim SET Age = 28 WHERE VictimID = 2;
UPDATE Victim SET Age = 35 WHERE VictimID = 3;

-- Suspects
UPDATE Suspect SET Age = 32 WHERE SuspectID = 1;
UPDATE Suspect SET Age = 45 WHERE SuspectID = 2;
UPDATE Suspect SET Age = 33 WHERE SuspectID = 3;
SELECT Name, Age, 'Victim' AS Role
FROM Victim
UNION
SELECT Name, Age, 'Suspect' AS Role
FROM Suspect
ORDER BY Age DESC;

-- 6. Find the average age of persons involved in incidents. --
SELECT AVG(Age) AS AverageAge
FROM (
    SELECT Age FROM Victim
    UNION ALL
    SELECT Age FROM Suspect
) AS AllPersons;

-- 7. List incident types and their counts, only for open cases. --
SELECT IncidentType, COUNT(*) AS IncidentCount
FROM Crime
WHERE Status = 'Open'
GROUP BY IncidentType;

-- 8. Find persons with names containing 'Doe'.  --
SELECT Name AS PersonName, 'Victim' AS Role
FROM Victim
WHERE Name LIKE '%Doe%'
UNION
SELECT Name AS PersonName, 'Suspect' AS Role
FROM Suspect
WHERE Name LIKE '%Doe%';

-- 9. Retrieve the names of persons involved in open cases and closed cases. --
SELECT 
    Suspect.Name AS SuspectName,
    Crime.Status AS CaseStatus
FROM 
    Suspect
INNER JOIN 
    Crime
ON 
    Suspect.CrimeID = Crime.CrimeID
WHERE 
    Crime.Status IN ('Open', 'Closed');
    SELECT 
    Victim.Name AS VictimName,
    Crime.Status AS CaseStatus
FROM 
    Victim
INNER JOIN 
    Crime
ON 
    Victim.CrimeID = Crime.CrimeID
WHERE 
    Crime.Status IN ('Open', 'Closed');

-- 10. List incident types where there are persons aged 30 or 35 involved. --
SELECT DISTINCT c.IncidentType
FROM Crime c
JOIN Victim v ON c.CrimeID = v.CrimeID
WHERE v.Age IN (30, 35)
UNION
SELECT DISTINCT c.IncidentType
FROM Crime c
JOIN Suspect s ON c.CrimeID = s.CrimeID
WHERE s.Age IN (30, 35);

-- 11. Find persons involved in incidents of the same type as 'Robbery'. --
-- Victims in Robbery incidents
SELECT v.Name AS PersonName, 'Victim' AS Role
FROM Victim v
JOIN Crime c ON v.CrimeID = c.CrimeID
WHERE c.IncidentType = 'Robbery'
UNION
-- Suspects in Robbery incidents
SELECT s.Name AS PersonName, 'Suspect' AS Role
FROM Suspect s
JOIN Crime c ON s.CrimeID = c.CrimeID
WHERE c.IncidentType = 'Robbery';

-- 12. List incident types with more than one open case. --
SELECT IncidentType, COUNT(*) AS OpenCaseCount
FROM Crime
WHERE Status = 'Open'
GROUP BY IncidentType
HAVING COUNT(*) > 1;

-- 13. List all incidents with suspects whose names also appear as victims in other incidents. --
SELECT DISTINCT c.CrimeID, c.IncidentType, c.IncidentDate, c.Location, c.Status
FROM Crime c
JOIN Suspect s ON c.CrimeID = s.CrimeID
WHERE s.Name IN (
    SELECT v.Name
    FROM Victim v
    WHERE v.CrimeID <> s.CrimeID
);

-- 14.  Retrieve all incidents along with victim and suspect details. --
SELECT 
    c.CrimeID,
    c.IncidentType,
    c.IncidentDate,
    c.Location,
    c.Status,
    
    v.VictimID,
    v.Name AS VictimName,
    v.ContactInfo,
    v.Injuries,
    
    s.SuspectID,
    s.Name AS SuspectName,
    s.Description,
    s.CriminalHistory
FROM Crime c
LEFT JOIN Victim v ON c.CrimeID = v.CrimeID
LEFT JOIN Suspect s ON c.CrimeID = s.CrimeID
ORDER BY c.CrimeID;

-- 15. Find incidents where the suspect is older than any victim. -- 
SELECT DISTINCT c.CrimeID, c.IncidentType, c.IncidentDate, c.Location, c.Status
FROM Crime c
JOIN Suspect s ON c.CrimeID = s.CrimeID
WHERE s.Age > ALL (
    SELECT v.Age
    FROM Victim v
    WHERE v.CrimeID = c.CrimeID
);

-- 16. Find suspects involved in multiple incidents: --

SELECT 
    Name, 
    COUNT(DISTINCT CrimeID) AS IncidentCount
FROM 
    Suspect
GROUP BY 
    Name
HAVING 
    COUNT(DISTINCT CrimeID) > 1;

    -- 17. List incidents with no suspects involved. --
    SELECT 
    Crime.CrimeID, 
    Crime.IncidentType, 
    Crime.IncidentDate, 
    Crime.Location, 
    Crime.Description, 
    Crime.Status
FROM 
    Crime
LEFT JOIN 
    Suspect
ON 
    Crime.CrimeID = Suspect.CrimeID
WHERE 
    Suspect.SuspectID IS NULL;
    
   --  18. List all cases where at least one incident is of type 'Homicide' and all other incidents are of type 
'Robbery'. --
SELECT * FROM Crime
WHERE EXISTS (
    SELECT 1 FROM Crime c1 WHERE c1.IncidentType = 'Homicide'
)
AND NOT EXISTS (
    SELECT 1 FROM Crime c2 
    WHERE c2.IncidentType NOT IN ('Robbery', 'Homicide')
);

-- 19. Retrieve a list of all incidents and the associated suspects, showing suspects for each incident, or 
'No Suspect' if there are none. --
SELECT 
    Crime.CrimeID,
    Crime.IncidentType,
    Crime.IncidentDate,
    Crime.Location,
    Crime.Description AS CrimeDescription,
    Crime.Status,
    IFNULL(Suspect.Name, 'No Suspect') AS SuspectName
FROM 
    Crime
LEFT JOIN 
    Suspect
ON 
    Crime.CrimeID = Suspect.CrimeID;
    
   --  20. List all suspects who have been involved in incidents with incident types 'Robbery' or 'Assault' --
   SELECT DISTINCT s.Name
FROM Suspect s
JOIN Crime c ON s.CrimeID = c.CrimeID
WHERE c.IncidentType IN ('Robbery', 'Assault');

    
    
   
























