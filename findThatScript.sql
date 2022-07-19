CREATE DEFINER=`root`@`localhost` PROCEDURE `findThatString`(
	IN databaseToSearch VARCHAR(255),
    IN needle VARCHAR(255),
    IN limitQtdTables INT,
    IN offsetTable INT
)
BLOCK1: BEGIN
    DECLARE done1, done2									BOOL default false;
    DECLARE tablename, temp_table, colname, temp_column		CHAR(255);
    DECLARE cur1 CURSOR FOR SELECT DISTINCT TABLE_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = databaseToSearch LIMIT limitQtdTables OFFSET offsetTable;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
		SELECT @s1;
    SET @match_found := FALSE;
    OPEN cur1;
    
    LOOP1: loop
        FETCH cur1 INTO tablename;
		IF done1 THEN
			CLOSE cur1;
            LEAVE LOOP1;
        END IF;
        
        BLOCK2: begin
            DECLARE cur2 CURSOR FOR SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = databaseToSearch AND TABLE_NAME = tablename;
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done2 = TRUE;
            SET done2 := FALSE;
            SET @match_found := 0;
            OPEN cur2;
			LOOP2: loop	
				FETCH cur2 INTO colname;
                IF done2 THEN
                    CLOSE cur2;
                    LEAVE LOOP2;
				END IF;
				
                SELECT tablename INTO @temp_table;
                SELECT colname 	 INTO @temp_column; 
				SET @s1 = CONCAT('SELECT COUNT(*) INTO @match_found FROM ', @temp_table, ' WHERE `', @temp_column, '` LIKE "%', needle, '%"');
				PREPARE stmt1 FROM @s1; EXECUTE stmt1; DEALLOCATE PREPARE stmt1; 
                
                IF @match_found THEN
					SELECT @temp_table, @temp_column, @s1;
					CLOSE cur2;
					LEAVE BLOCK1;
				END IF;	
			END loop LOOP2;
        END BLOCK2;
        
        IF @match_found THEN
            CLOSE cur1;
            LEAVE LOOP1;
        END IF;
    END loop LOOP1;
END BLOCK1
