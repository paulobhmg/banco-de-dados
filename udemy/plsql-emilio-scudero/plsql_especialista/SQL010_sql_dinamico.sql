/* SQL Dinâmico
 - Permitem a construção de código SQL durante a execução do programa
*/

CREATE OR REPLACE PROCEDURE prc_lista_employees_dinamico (pManager_id employees.manager_id%TYPE, pDepartment_id employees.department_id%TYPE) IS
	vEmpoyees employees%ROWTYPE;
	TYPE empTabType IS TABLE OF vEmployees%TYPE INDEX BY BINARY_INTEGER;
	empTab empTabType;
	vSql VARCHAR(1000) DEFAULT 'SELECT * FROM employees WHERE 1=1 ';
BEGIN
	-- O código SQL será gerado dinamicamente com base nos valores passados por parâmetro para a procedure
	IF pManager_id IS NOT NULL THEN
		vSql := vSql || 'AND manager_id = ' || pManager_id || ' ';
	END IF;
	IF pDepartment_id IS NOT NULL THEN
		vSql := vSql || 'AND department_id = ' || pDepartment_id || ' ';
	END IF;
	vSql := vSql || 'ORDER BY employee_id ';
	dbms_output.PUT_LINE(vSql);
	
	EXECUTE IMMEDIATE vSql
	BULK COLLECT INTO empTab;
	
	FOR i IN 1..empTab.COUNT LOOP
		dbms_output.PUT_LINE(
			empTab(i).employee_id || ', ' || 
			empTab(i).first_name  || ', ' ||
			empTab(i).salary
		);
	END LOOP;
END;

EXECUTE prc_lista_employees_dinamico(pDepartment_id => 90);
EXECUTE prc_lista_employees_dinamico(pDepartment_id => 50, pManager_id => 100);
EXECUTE prc_lista_employees_dinamico(pManager_id => 100);
EXECUTE prc_lista_employees_dinamico;
---------------------------------------------

/* SQL dinâmico com variáveis do tipo BIND
 - O oracle utiliza um espaço em memória chamado SHARED POOL, ou seja, um espaço compartilhado onde serão armazenados todos os comandos utilizados durante a sessão.
   Quando utilizamos um comando, o Oracle verifica se ele já existe no SHARED POOL e caso exista, utiliza o mesmo plano de execução já utilizado anteriormente.
	 Caso o comando não exista, o Oracle o adiciona ao POOL e traça um novo plano de execução.
 - Comandos iguais utilizam o mesmo plano de execução, mas quando temos comandos com alteração de um parâmetro, este já não é mais igual, embora o restante do código seja o mesmo.
   Devido a isso, o Oracle efetua um HARD parsing, que é a criação total do plano de execução e armazenamento do comando no SHARED POOL.
 - Para evitar o HARD PARSING, é possível utilizar as variáveis do tipo BIND em códigos SQL dinâmicos. Com isso, temos o que é conhecido como SOFT PARSING,
   fazendo com que o Oracle utilize todo o corpo do comando anterior, alternando apenas os parâmetros, que serão passados dinamicamente. */
	 
CREATE OR REPLACE PROCEDURE prc_lista_employees_dinamico_bind(
	pDepartment_id employees.department_id%TYPE DEFAULT NULL,
	pManager_id 	 employees.manager_id%TYPE DEFAULT NULL)
IS
	vEmployees employees%ROWTYPE;
	TYPE empTabType IS TABLE OF vEmployees%TYPE;
	empTab empTabType := empTabType();
	vSql VARCHAR(1000) DEFAULT 'SELECT * FROM employees WHERE 1=1 ';
BEGIN
	IF pDepartment_id IS NOT NULL THEN
		vSql := vSql || 'AND department_id = :pDepartment_id ';
	END IF;
	IF pManager_id IS NOT NULL THEN
		vSql := vSql || 'AND manager_id = :pManager_id ';
	END IF;
	vSql := vSql || 'ORDER BY employee_id ';
	
	CASE
		WHEN pDepartment_id IS NOT NULL AND pManager_id IS NOT NULL THEN
			EXECUTE IMMEDIATE vSql BULK COLLECT INTO empTab USING pDepartment_id, pManager_id;
		WHEN pDepartment_id IS NOT NULL AND pManager_id IS NULL THEN
			EXECUTE IMMEDIATE vSql BULK COLLECT INTO empTab USING pDepartment_id;
		WHEN pDepartment_id IS NULL AND pManager_id IS NOT NULL THEN
			EXECUTE IMMEDIATE vSql BULK COLLECT INTO empTab USING pManager_id;
		ELSE
			EXECUTE IMMEDIATE vSql BULK COLLECT INTO empTab; 
	END CASE;
	
	FOR i IN 1..empTab.COUNT LOOP
		dbms_output.PUT_LINE(
			empTab(i).employee_id || ', ' || 
			empTab(i).first_name  || ', ' ||
			empTab(i).salary
		);
	END LOOP;
	
	dbms_output.PUT_LINE(vSql);
END;

EXECUTE prc_lista_employees_dinamico_bind(pDepartment_id => 60);
EXECUTE prc_lista_employees_dinamico_bind(pDepartment_id => 50, pManager_id => 100);
EXECUTE prc_lista_employees_dinamico_bind(pManager_id => 100);
EXECUTE prc_lista_employees_dinamico_bind;
------------------------------------------------------

/* Também é possível utilzar SQL dinâmico para definição de CURSORES */

CREATE OR REPLACE PROCEDURE prc_lista_empregados_cursor_dinamico(
	pDepartment_id employees.department_id%TYPE DEFAULT NULL,
	pManager_id 	 employees.manager_id%TYPE DEFAULT NULL)
IS
	TYPE empRef IS REF CURSOR;
	vEmpCursor empRef;
	vEmployees employees%ROWTYPE;
  TYPE vEmpListType IS TABLE OF vEmployees%TYPE INDEX BY BINARY_INTEGER;
  vEmpList vEmpListType;
	vSql VARCHAR2(1000) DEFAULT 'SELECT * FROM employees WHERE 1=1 ';
BEGIN
	IF pDepartment_id IS NOT NULL THEN
		vSql := vSql || 'AND department_id = :pDepartment_id ';
	END IF;
	IF pManager_id IS NOT NULL THEN
		vSql := vSql || 'AND manager_id = :pManager_id ';
	END IF;
	vSql := vSql || 'ORDER BY employee_id ';
	
	CASE 
		WHEN pDepartment_id IS NOT NULL AND pManager_id IS NOT NULL THEN
			OPEN vEmpCursor FOR vSql USING pDepartment_id, pManager_id;
		WHEN pDepartment_id IS NOT NULL AND pManager_id IS NULL THEN
			OPEN vEmpCursor FOR vSql USING pDepartment_id;
		WHEN pDepartment_id IS NULL AND pManager_id IS NOT NULL THEN
			OPEN vEmpCursor FOR vSql USING pManager_id;
		ELSE 
			OPEN vEmpCursor FOR vSql;
	END CASE;
	
	FETCH vEmpCursor BULK COLLECT INTO vEmpList;
	CLOSE vEmpCursor;
	
	FOR i IN 1..vEmpList.COUNT LOOP
		dbms_output.PUT_LINE(
			vEmpList(i).employee_id || ' - ' ||
			vEmpList(i).first_name  || ', '  ||
			vEmpList(i).department_id || ', ' ||
			vEmpList(i).manager_id
		);
	END LOOP;
	dbms_output.PUT_LINE(vSql);
END;

EXECUTE prc_lista_empregados_cursor_dinamico(pDepartment_id => 60);
EXECUTE prc_lista_empregados_cursor_dinamico(50, 100);
EXECUTE prc_lista_empregados_cursor_dinamico(NULL, 100);
EXECUTE prc_lista_empregados_cursor_dinamico;
-------------------------------------------------------------

/* Para sistemas legados, que utilizam versões do Oracle antes da versão 8, não existe o comando EXECUTE IMMEDIATE.
 - Esses sistemas utilizam o pacote DBMS_SQL, que é um pouco mais complexo de se utilizar */
 
-- Exemplo com UPDATE
CREATE OR REPLACE PROCEDURE prc_atualiza_salario_dbms_sql(
	pEmployee_id employees.employee_id%TYPE,
	pPercentual  INTEGER)
IS
	vCursorId 			INTEGER;
	vLinhasAfetadas INTEGER;
BEGIN
  -- Primeiro passo, a variável vCursor irá receber o ID de um cursor aberto pela procedure. O cursor é referenciado pelo seu ID.
	vCursorId := DBMS_SQL.OPEN_CURSOR;
	dbms_sql.PARSE( -- O comando faz o PARSE do código SQL para dentro do cursor, especificando também qual será a forma de criação do comando
		vCursorId, 
		'UPDATE employees
			  SET salary = salary * (:pPercentual / 100)
			WHERE employee_id = :pEmployee_id',
		dbms_sql.NATIVE
	);
	
	-- Especifica para qual cursor e qual variável será atribuida o valor para o bind
	dbms_sql.BIND_VARIABLE(vCursorId, ':pEmployee_id', pEmployee_id);
  dbms_sql.BIND_VARIABLE(vCursorId, ':pPercentual', pPercentual);

	-- O comando execute, além de executar o cursor, retorna o número de linhas afetadas por ele.
	vLinhasAfetadas := dbms_sql.EXECUTE(vCursorId);
	dbms_output.PUT_LINE('Linhas afetadas: ' || vLinhasAfetadas);
	
	dbms_sql.CLOSE_CURSOR(vCursorId); -- Fechamento do cursor
	
	EXCEPTION 
		WHEN OTHERS THEN
			RAISE_APPLICATION_ERROR(-20001, 'Erro ao atualizar salário: ' || SQLERRM);
END;	

-- Exemplo com SELECT
DECLARE
	vCursorId 			INTEGER;
	vLinhasAfetadas INTEGER;
	vEmployee_id 	  employees.employee_id%TYPE;
	vFirst_name 		employees.first_name%TYPE;
BEGIN
	vCursorId := dbms_sql.OPEN_CURSOR;
	
	dbms_sql.PARSE(vCursorId, 'SELECT employe_id, first_name FROM employees ORDER BY employee_id', dbms_sql.NATIVE);
	
	dbms_sql.DEFINE_COLUMN(vCursorId, 1, vEmployee_id, 30);
	dbms_dql.DEFINE_COLUMN(vCursorId, 2, vFirst_name,  30);
	
	vLinhasAfetadas := dbms_sql.EXECUTE_AND_FETCH(vCursorId);
	
	LOOP
		EXIT WHEN dbms_sql.FETCH_ROWS(vCursorId) = 0;
		dbms_sql.COLUMN_VALUE(vCursorId, 1, vEmployee_id);
		dbms_sql.COLUMN_VALUE(vCursor, 2, vFirst_name);
		
		dbms_output.PUT_LINE(vEmployee_id || ' - ' || vFirst_name);
	END LOOP;
	dbms_output.PUT_LINE('Registros encontrados: ' || vLinhasAfetadas);
	dbms_sql.CLOSE_CURSOR(vCursorId);
	
	EXCEPTION 
		WHEN OTHERS THEN
			RAISE_APPLICATION_ERROR(-20001, 'Erro ao executar SELECT: ' || SQLERRM);
END;


	