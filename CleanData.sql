-- Create the state lookup table
DROP TABLE IF EXISTS state_lookup;
CREATE TABLE IF NOT EXISTS state_lookup (
	abbr VARCHAR(2) COLLATE pg_catalog."default" NOT NULL,
    name TEXT COLLATE pg_catalog."default" NOT NULL,
	-- Assign a primary key
    CONSTRAINT state_lookup_pkey PRIMARY KEY (abbr)
);

-- Populate the state lookup table
INSERT INTO state_lookup (abbr, name) VALUES
('AL', 'Alabama'),
('AK', 'Alaska'),
('AZ', 'Arizona'),
('AR', 'Arkansas'),
('CA', 'California'),
('CO', 'Colorado'),
('CT', 'Connecticut'),
('DE', 'Delaware'),
('DC', 'District of Columbia'),
('FL', 'Florida'),
('GA', 'Georgia'),
('HI', 'Hawaii'),
('ID', 'Idaho'),
('IL', 'Illinois'),
('IN', 'Indiana'),
('IA', 'Iowa'),
('KS', 'Kansas'),
('KY', 'Kentucky'),
('LA', 'Louisiana'),
('ME', 'Maine'),
('MD', 'Maryland'),
('MA', 'Massachusetts'),
('MI', 'Michigan'),
('MN', 'Minnesota'),
('MS', 'Mississippi'),
('MO', 'Missouri'),
('MT', 'Montana'),
('NE', 'Nebraska'),
('NV', 'Nevada'),
('NH', 'New Hampshire'),
('NJ', 'New Jersey'),
('NM', 'New Mexico'),
('NY', 'New York'),
('NC', 'North Carolina'),
('ND', 'North Dakota'),
('OH', 'Ohio'),
('OK', 'Oklahoma'),
('OR', 'Oregon'),
('PA', 'Pennsylvania'),
('PR', 'Puerto Rico'),
('RI', 'Rhode Island'),
('SC', 'South Carolina'),
('SD', 'South Dakota'),
('TN', 'Tennessee'),
('TX', 'Texas'),
('UT', 'Utah'),
('VT', 'Vermont'),
('VA', 'Virginia'),
('WA', 'Washington'),
('WV', 'West Virginia'),
('WI', 'Wisconsin'),
('WY', 'Wyoming');

-- Clean medical data
-- Remove extraneous columns from medical data
ALTER TABLE medical
DROP COLUMN IF EXISTS "CaseOrder",
DROP COLUMN IF EXISTS "Customer_id",
DROP COLUMN IF EXISTS "Interaction",
DROP COLUMN IF EXISTS "UID",
DROP COLUMN IF EXISTS "TimeZone",
DROP COLUMN IF EXISTS "Job",
ADD COLUMN IF NOT EXISTS "StateAbbr" CHAR(2);

-- Add state abbreaviations to medical data
UPDATE medical
SET "StateAbbr" = state_lookup.abbr
FROM state_lookup
WHERE "State" = state_lookup.name;

-- Encode variables in medical data
-- Check if first column is of VARCHAR type
DO $$
DECLARE
    column_type VARCHAR;
BEGIN
    SELECT data_type
    INTO column_type
    FROM information_schema.columns
    WHERE table_schema = 'public'
    AND table_name = 'medical'
    AND column_name = 'ReAdmis';
	-- Encode binary columns
    IF column_type = 'character varying' THEN
		UPDATE medical
		SET 
			"ReAdmis" = CASE WHEN "ReAdmis" = 'Yes' THEN 1 ELSE 0 END,
			"Soft_drink" = CASE WHEN "Soft_drink" = 'Yes' THEN 1 ELSE 0 END,
			"HighBlood" = CASE WHEN "HighBlood" = 'Yes' THEN 1 ELSE 0 END,
			"Stroke" = CASE WHEN "Stroke" = 'Yes' THEN 1 ELSE 0 END,
			"Overweight" = CASE WHEN "Overweight" = 'Yes' THEN 1 ELSE 0 END,
			"Arthritis" = CASE WHEN "Arthritis" = 'Yes' THEN 1 ELSE 0 END,
			"Diabetes" = CASE WHEN "Diabetes" = 'Yes' THEN 1 ELSE 0 END,
			"Hyperlipidemia" = CASE WHEN "Hyperlipidemia" = 'Yes' THEN 1 ELSE 0 END,
			"BackPain" = CASE WHEN "BackPain" = 'Yes' THEN 1 ELSE 0 END,
			"Anxiety" = CASE WHEN "Anxiety" = 'Yes' THEN 1 ELSE 0 END,
			"Allergic_rhinitis" = CASE WHEN "Allergic_rhinitis" = 'Yes' THEN 1 ELSE 0 END,
			"Reflux_esophagitis" = CASE WHEN "Reflux_esophagitis" = 'Yes' THEN 1 ELSE 0 END,
			"Asthma" = CASE WHEN "Asthma" = 'Yes' THEN 1 ELSE 0 END; 
	END IF;
END;
$$ LANGUAGE plpgsql;

-- Update data types in medical data
ALTER TABLE medical
ALTER COLUMN "ReAdmis" TYPE INT USING "ReAdmis"::INT,
ALTER COLUMN "Soft_drink" TYPE INT USING "Soft_drink"::INT,
ALTER COLUMN "HighBlood" TYPE INT USING "HighBlood"::INT,
ALTER COLUMN "Stroke" TYPE INT USING "Stroke"::INT,
ALTER COLUMN "Overweight" TYPE INT USING "Overweight"::INT,
ALTER COLUMN "Arthritis" TYPE INT USING "Arthritis"::INT,
ALTER COLUMN "Diabetes" TYPE INT USING "Diabetes"::INT,
ALTER COLUMN "Hyperlipidemia" TYPE INT USING "Hyperlipidemia"::INT,
ALTER COLUMN "BackPain" TYPE INT USING "BackPain"::INT,
ALTER COLUMN "Anxiety" TYPE INT USING "Anxiety"::INT,
ALTER COLUMN "Allergic_rhinitis" TYPE INT USING "Allergic_rhinitis"::INT,
ALTER COLUMN "Reflux_esophagitis" TYPE INT USING "Reflux_esophagitis"::INT,
ALTER COLUMN "Asthma" TYPE INT USING "Asthma"::INT;

-- Clean comp readmission data
-- Drop extraneous columns
ALTER TABLE readmissions
DROP COLUMN IF EXISTS "Facility Name",
DROP COLUMN IF EXISTS "Facility ID",
DROP COLUMN IF EXISTS "Measure Name",
DROP COLUMN IF EXISTS "Footnote",
DROP COLUMN IF EXISTS "Excess Readmission Ratio",
DROP COLUMN IF EXISTS "Predicted Readmission Rate",
DROP COLUMN IF EXISTS "Start Date",
DROP COLUMN IF EXISTS "End Date";

-- Remove missing values
DO $$
DECLARE
    column_type VARCHAR;
BEGIN
    SELECT data_type
    INTO column_type
    FROM information_schema.columns
    WHERE table_schema = 'public'
    AND table_name = 'readmissions'
    AND column_name = 'Number of Discharges';
	IF column_type = 'text' THEN
		DELETE FROM readmissions
		WHERE "Number of Discharges" = 'N/A' 
		OR "Expected Readmission Rate" = 'N/A' 
		OR "Number of Readmissions" = 'N/A' 
		OR "Number of Readmissions" = 'Too Few to Report';
	END IF;
END;
$$ LANGUAGE plpgsql;

-- Update data types
ALTER TABLE readmissions
ALTER COLUMN "Number of Discharges" TYPE INT USING "Number of Discharges"::INT,
ALTER COLUMN "Expected Readmission Rate" TYPE DOUBLE PRECISION USING "Expected Readmission Rate"::DOUBLE PRECISION,
ALTER COLUMN "Number of Readmissions" TYPE INT USING "Number of Readmissions"::INT;

-- Aggregate comp readmission data
-- Create table to store aggregated comp values
DROP TABLE IF EXISTS comp;
CREATE TABLE IF NOT EXISTS comp (
	"State" CHAR(2),
	"Comp Admissions" INT,
	"Comp Readmissions" INT,
	"Comp Readmission Rate" DOUBLE PRECISION,
	"Comp Expected Readmissions" INT,
	"Comp Expected Readmission Rate" DOUBLE PRECISION,
	CONSTRAINT comp_pkey PRIMARY KEY ("State")
);

-- Populate the state column
INSERT INTO comp ("State")
SELECT DISTINCT "State"
FROM readmissions
ORDER BY "State";

-- Insert aggregate values
UPDATE comp 
SET 
	"Comp Admissions" = agg.total_discharges, 
	"Comp Readmissions" = agg.total_readmissions,
	"Comp Expected Readmission Rate" = agg.err
FROM (
	SELECT "State", 
	SUM("Number of Discharges") AS total_discharges, 
	SUM("Number of Readmissions") AS total_readmissions,
	AVG("Expected Readmission Rate")/100 AS err
	FROM readmissions
	GROUP BY "State"
) AS agg
WHERE comp."State" = agg."State";

-- Update calculated columns
UPDATE comp
SET "Comp Readmission Rate" = "Comp Readmissions"::DOUBLE PRECISION/"Comp Admissions"::DOUBLE PRECISION;
	
-- Join medical and comp readmission data
SELECT
	medical.*, 
	comp."Comp Admissions", 
	comp."Comp Readmissions", 
	comp."Comp Readmission Rate",
	comp."Comp Expected Readmission Rate"
FROM medical
JOIN comp ON medical."StateAbbr" = comp."State";