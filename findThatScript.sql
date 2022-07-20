CREATE DEFINER=`root`@`localhost` PROCEDURE `findThatString`(
	IN databaseToSearch VARCHAR(255),
    IN needle VARCHAR(255),
    IN limitQtdTables INT,
    IN offsetTable INT
)
BLOCK1: BEGIN
    DECLARE done 										BOOL DEFAULT FALSE;
    DECLARE tablename, temp_table, colname, temp_column	CHAR(255);
    DECLARE cur1 CURSOR FOR SELECT DISTINCT TABLE_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = databaseToSearch LIMIT limitQtdTables OFFSET offsetTable;
    -- This handler is for debug purpose only
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
		SELECT @s1;
		
    SET @match_found := FALSE;
    OPEN cur1;
    LOOP1: loop
        FETCH cur1 INTO tablename;
        
        BLOCK2: BEGIN
            DECLARE cur2 CURSOR FOR SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = databaseToSearch AND TABLE_NAME = tablename;
            DECLARE CONTINUE HANDLER FOR NOT FOUND 
				SET done = TRUE;
				
            SET done := FALSE;
            SET @match_found := 0;
            OPEN cur2;
			LOOP2: loop	
				FETCH cur2 INTO colname;
                IF done THEN
                    CLOSE cur2;
                    LEAVE LOOP2;
				END IF;
				
                SELECT tablename INTO @temp_table;
                SELECT colname 	 INTO @temp_column; 
				SET @s1 = CONCAT('SELECT COUNT(*) INTO @match_found FROM `', @temp_table, '` WHERE `', @temp_column, '` LIKE "%', needle, '%"');
				PREPARE stmt1 FROM @s1; EXECUTE stmt1; DEALLOCATE PREPARE stmt1; 
                
                IF @match_found THEN
					SELECT @temp_table, @temp_column, @s1;
					CLOSE cur2;
					LEAVE BLOCK2;
				END IF;	
			END loop LOOP2;
        END BLOCK2;
    END loop LOOP1;
END BLOCK1
