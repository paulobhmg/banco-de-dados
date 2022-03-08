/* SYSREFCURSOR é um tipo de variável que RECEBE um cursor ou o RESULT SET de um cursor.
 - Ele pode ser passado como parâmetros em funções e retornado; */
 
CREATE OR REPLACE PROCEDURE prc_cria_sysrefcursor(sysref OUT SYS_REFCURSOR) IS
BEGIN
	OPEN sysref FOR
		SELECT first_name, salary
		  FROM employees
		 ORDER BY first_name;
END;

CREATE OR REPLACE PROCEDURE prc_display_sysrefcursor1 IS
	sysref 			SYS_REFCURSOR;
	vFirst_name employees.first_name%TYPE;
	vSalary 	  employees.salary%TYPE;
BEGIN
	prc_cria_sysrefcursor(sysref);
	-- Observar que neste caso não houve a necessidade de abertura e fechamento de cursor, pois ele está fazendo referência ao resultset retornado pela função anterior.
	LOOP 
		FETCH sysref INTO vFirst_name, vSalary;
		EXIT WHEN sysref%NOTFOUND;
		dbms_output.PUT_LINE(vFirst_name || ' - ' || vSalary);
	END LOOP;
END;

-- Exemplo de SYS_REFCURSOR com FUNCTION
CREATE OR REPLACE FUNCTION fnc_cria_sysrefcursor(pDepartment_id NUMBER) RETURN SYS_REFCURSOR IS
	vSysref SYS_REFCURSOR;
BEGIN
	OPEN vSysref FOR
		SELECT e.first_name, e.salary, d.department_name
		  FROM employees e, departments d 
		 WHERE e.department_id = d.department_id
		   AND e.department_id = pDepartment_id
		 ORDER BY e.first_name;
		 
		RETURN vSysref;
END;

CREATE OR REPLACE PROCEDURE prc_display_sysrefcursor2(pDepartment_id NUMBER) IS
	vSysref          SYS_REFCURSOR;
  vFirst_name      employees.first_name%TYPE;
  vSalary          employees.salary%TYPE;
  vDepartment_name departments.department_name%TYPE;
BEGIN
	vSysref := fnc_cria_sysrefcursor(pDepartment_id);
	LOOP
    FETCH vSysref INTO vFirst_name, vSalary, vDepartment_name;
    EXIT WHEN vSysref%NOTFOUND;
    dbms_output.PUT_LINE(vFirst_name || ', ' || vSalary || ', ' || vDepartment_name);
  END LOOP;
END;