-- Location of file -> 'D:/SIIT/Project_DB_Lecture/data_sampled/aisles.csv'
-- insert aisles.csv data into aisles table
LOAD DATA LOCAL INFILE 'D:/SIIT/Project_DB_Lecture/data_sampled_2/aisles.csv'
INTO TABLE aisles
CHARACTER SET 'utf8mb4'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Location of file -> 'D:/SIIT/Project_DB_Lecture/data_sampled/departments.csv'
-- insert departments.csv data into departments table
LOAD DATA LOCAL INFILE 'D:/SIIT/Project_DB_Lecture/data_sampled_2/departments.csv'
INTO TABLE departments
CHARACTER SET 'utf8mb4'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;