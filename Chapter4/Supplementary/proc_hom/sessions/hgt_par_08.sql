declare retval INT default null; 
call proc1(1,2,retval);


DECLARE the_new_id INT DEFAULT NULL;
CALL new_customer(the_new_id, 'John', 'Smith', '10 Parliament Square');


CREATE FUNCTION size_by_group_gene(IN P1 INT) 
RETURNS TABLE(C1 INT) 
SPECIFIC F1 LANGUAGE JAVA DETERMINISTIC EXTERNAL NAME 'CLASSPATH:proc_hom_sp.HgtPar.sizeByGroupGene'


drop function func1


CREATE FUNCTION func1(IN P1 INT, IN P2 INT)
RETURNS TABLE(C1 INT, C2 INT)
SPECIFIC F1 LANGUAGE JAVA DETERMINISTIC EXTERNAL NAME 'CLASSPATH:org.uqam.OrgUqam.funcTest1'

CREATE FUNCTION func1(IN P1 INT, IN P2 INT)
RETURNS TABLE(C1 INT, C2 INT) 
SPECIFIC F1 LANGUAGE JAVA DETERMINISTIC EXTERNAL NAME 'CLASSPATH:proc_hom_sp.HgtPar.funcTest1'

                