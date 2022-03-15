/* OBJECTS, TABLE FUNCTIONS E PIPELINE TABLE FUNCTIONS 
 - Quando criamos tipos RECORD e COLLECTIONS em procedures, esses objetos ficam visíveis apenas na procedure ou bloco onde foram definidas,
   mas é possível definir TYPES como objetos, que serão enxergados por todo o sistema. 
	 
 - A partir da criação de OBJETOS, é possível criar TABLE FUNCTIONS, que possibilitam retornar Collections como retorno de funções. */
	 
CREATE TYPE employees_row AS OBJECT (
  employee_id NUMBER(6),
  first_name  VARCHAR(20),
  salary      NUMBER(8,2),
  job_id      VARCHAR(10)
);

CREATE TYPE employees_row_table IS TABLE OF employees_row;

-- Criando função que retorna uma Collection
CREATE OR REPLACE FUNCTION GET_EMPLOYEES_TABLE_FUNCTION(pDepartment_id IN NUMBER) RETURN employees_row_table IS
  vEmployeesTable employees_row_table := employees_row_table();
BEGIN
  FOR i IN (
    SELECT employee_id, first_name, salary, job_id 
      FROM employees
     WHERE department_id = pDepartment_id
     ORDER BY employee_id )
  LOOP
		-- Para cada iteração do LOOP, é atribuído um novo OBJETO do tipo employee_row na Collection que será retornada.
		vEmployeesTable.EXTEND;
		vEmployeesTable(vEmployeesTable.LAST) := employees_row(i.employee_id, i.first_name, i.salary, i.job_id);
  END LOOP;
  RETURN vEmployeesTable;
END;

-- Utilizando TABLE FUNCTIONS
SELECT * FROM TABLE(GET_EMPLOYEES_TABLE_FUNCTION(60));
----------------------------

/* PIPELINED FUNCTIONS é utilizada também como TABLE FUNCTION, porém neste caso, ao invés de retornar uma Collection inteira, que pode ser muito grande
   e consumir muita memória, a cada iteração do LOOP irá retornar uma linha. Isso irá aumentar a performance devido à economia de recursos em memória. */

CREATE OR REPLACE FUNCTION GET_EMPLOYEES_TABLE_FUNCTION_PIPELINED(pDepartment_id IN NUMBER) RETURN employees_row_table PIPELINED IS
	vEmployeesTable employees_row_table := employees_row_table();
BEGIN
	FOR e IN (
		SELECT employee_id, first_name, salary, job_id
		  FROM employees
		 WHERE department_id = pDepartment_id
		 ORDER BY employee_id )
 LOOP
		PIPE ROW(employees_row(e.employee_id, e.first_name, e.salary, e.job_id));
 END LOOP;
END;

-- Utilizando TABLE FUNCTIONS para PIPELINED FUNCTIONS
SELECT * FROM TABLE(GET_EMPLOYEES_TABLE_FUNCTION_PIPELINED(60));