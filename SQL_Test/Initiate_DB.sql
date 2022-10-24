CREATE TABLE Patients (
    Patient_ID integer NOT NULL,
    FirstName varchar2(50) NOT NULL,
    LastName varchar2(50) NOT NULL,
    MotherName varchar2(100) NOT NULL,
    Sex varchar2(10) NOT NULL,
    DateOfBirth date NOT NULL,
    DateOfDeath date,
    PlaceOfBirth varchar2(35) NOT NULL,
    PhoneNumber varchar2(15) NOT NULL,
    Email varchar2(319) NOT NULL,
    CONSTRAINT Patients_PK PRIMARY KEY (Patient_ID),
	CONSTRAINT Patients_Dates_Check CHECK (DateOfBirth <= DateOfDeath)
);

CREATE TABLE Address_Of_Patient(
    Patient_ID integer NOT NULL,
    PostCode varchar2(16) NOT NULL,
    City varchar2(35) NOT NULL,
    Street varchar2(95) NOT NULL,
    HouseNumber varchar2(5) NOT NULL,
    CONSTRAINT Address_Of_Patient_PK PRIMARY KEY (Patient_ID),
	CONSTRAINT Address_Of_Patient_Patients_FK FOREIGN KEY (Patient_ID) REFERENCES Patients (Patient_ID)
);

CREATE TABLE Relationships (
    Relationship_ID integer NOT NULL,
    Patient_ID_Who integer NOT NULL,
    Patient_ID_With integer NOT NULL,
    ConnectionType varchar2(50) NOT NULL,
    ConnectionQuality varchar2(50) NOT NULL,
    ConnectionDistance smallint NOT NULL,
    ConnectionStartDate date NOT NULL,
    ConnectionEndDate date,
    CONSTRAINT Relationships_PK PRIMARY KEY (Relationship_ID),
	CONSTRAINT Relationships_Patients_FK FOREIGN KEY (Patient_ID_Who) REFERENCES PATIENTS (Patient_ID),
	CONSTRAINT Relationships_Dates_Check CHECK (ConnectionStartDate <= ConnectionEndDate),
	CONSTRAINT Relationships_Quality_Check CHECK (ConnectionDistance >= 1 AND ConnectionDistance <= 10)
);

CREATE OR REPLACE TRIGGER birthDateCheck BEFORE INSERT ON Relationships
FOR EACH ROW
DECLARE
	v_birthDate_Latest date;
BEGIN
	SELECT MAX(DateOfBirth) INTO v_birthDate_Latest FROM Patients WHERE :NEW.Patient_ID_Who = Patients.Patient_ID OR :NEW.Patient_ID_With = Patients.Patient_ID;
	IF :NEW.ConnectionStartDate < v_birthDate_Latest THEN
		:NEW.ConnectionStartDate := v_birthDate_Latest;
	END IF;
END;
/
CREATE OR REPLACE TRIGGER deathDateTrigger AFTER UPDATE ON Patients
FOR EACH ROW
BEGIN
	UPDATE Relationships SET ConnectionEndDate = :NEW.DateOfDeath 
	WHERE (Relationships.Patient_ID_Who = :OLD.Patient_ID OR Relationships.Patient_ID_With = :OLD.Patient_ID) AND 
	(Relationships.ConnectionEndDate IS NULL OR Relationships.ConnectionEndDate > :NEW.DateOfDeath);
END;