/* Utilizando comandos SQL dentro dos blocos SQL 
 - É possível utilizar os comandos DML e DCL dentro dos blocos SQL.
 - Blocos PLSQL não são uma unidade de transação.
 - Os comandos COMMIT, SAVEPOINT e ROLLBACK são independentes do bloco SQL.
 - Não é possível utilizar comandos DDL dentro de blocos PLSQL, podendo ser executados apenas em SQL dinâmico.
 - Da mesma forma, comandos DCL também só poderão ser utilizados dentro de SQL dinâmicos. */
 
/* UTILIZANDO COMANDO SELECT EM BLOCO PLSQL
 - Dentro de um BLOCO PLSQL, os valores de um comando SELECT devem ser armazenados em uma ou mais variáveis,
   através da cláusula INTO. Deverá existir uma variável para cada coluna retornada do SELECT.
 - Vale lembrar que o SELECT INTO retorna apenas um valor, ocasionando exception TOO_MANY_ROWS, caso retorne mais de um registro. */

-- Exemplificando a atribuição com o comando SELECT retornando apenas um registro OK.
DECLARE
	vEmployeeId     employees.employee_id%TYPE;
	vEmployeeName   employees.first_name%TYPE;
	vEmployeeSalary employees.salary%TYPE;
	vDepartmentName departments.department_name%TYPE;
BEGIN
	SELECT e.employee_id,
				 e.first_name,
				 e.salary,
				 d.department_name
		INTO vEmployeeId, vEmployeeName, vEmployeeSalary, vDepartmentName
		FROM employees e, departments d
	 WHERE e.department_id = d.department_id
		 AND e.employee_id = 121;	
		 
	dbms_output.PUT_LINE(vEmployeeId || ' - ' || vEmployeeName || ', ' || vEmployeeSalary || ', ' || vDepartmentName);
	EXCEPTION
		WHEN too_many_rows THEN
			dbms_output.PUT_LINE('Muitos registros retornados.');
		WHEN no_data_found THEN
			dbms_output.PUT_LINE('Nenhum registro encontrado.');
		WHEN OTHERS THEN
			dbms_output.PUT_LINE('Erro ao buscar funcionários: ' || SQLERRM);
END;

-- Neste exemplo, caso o vJobId estivesse no comando SELECT, seria necessário agrupar.
DECLARE
	vJobId 	   employees.job_id%TYPE := 'IT_PROG';
	vSumSalary employees.salary%TYPE;
	vAvgSalary employees.salary%TYPE;
BEGIN
	SELECT ROUND(SUM(NVL(salary, 0)), 2),
				 ROUND(AVG(NVL(salary, 0)), 2)
		INTO vSumSalary, vAvgSalary
	  FROM employees
	 WHERE job_id = vJobId;
	dbms_output.PUT_LINE(vSumSalary || ', ' || vAvgSalary);
	 
	EXCEPTION
		WHEN too_many_rows THEN
			dbms_output.PUT_LINE('Muitas linhas retornadas.');
		WHEN no_data_found THEN
			dbms_output.PUT_LINE('Nenhum registro encontrado.');
		WHEN OTHERS THEN
			dbms_output.PUT_LINE('Erro ao consultar employees: ' || SQLERRM);
END;

-- Exemplificando a atribuição com o comando SELECT retornando mais de um registro.
DECLARE
	vJobId     employees.job_id%TYPE;
	vSumSalary employees.salary%TYPE;
	vAvgSalary employees.salary%TYPE;
BEGIN
	SELECT job_id,
				 ROUND(SUM(NVL(salary, 0)), 2), 
				 ROUND(AVG(NVL(salary, 0)), 2)
		INTO vJobId, vSumSalary, vAvgSalary
		FROM employees 
	 GROUP BY job_id;
	 
  dbms_output.PUT_LINE(vJobId || ' - ' || vSumSalary || ', ' || vAvgSalary);
		 
	EXCEPTION
		WHEN too_many_rows THEN
			dbms_output.PUT_LINE('Muitos registros retornados.');
		WHEN no_data_found THEN
			dbms_output.PUT_LINE('Nenhum registro encontrado.');
		WHEN OTHERS THEN
			dbms_output.PUT_LINE('Erro ao buscar funcionários: ' || SQLERRM);
END;

-- Exemplificando a atribuição com o comando SELECT retornando nenhum registro.
DECLARE
	vEmployeeId     employees.employee_id%TYPE;
	vEmployeeName   employees.first_name%TYPE;
	vEmployeeSalary employees.salary%TYPE;
	vDepartmentName departments.department_name%TYPE;
BEGIN
	SELECT e.employee_id,
				 e.first_name,
				 e.salary,
				 d.department_name
		INTO vEmployeeId, vEmployeeName, vEmployeeSalary, vDepartmentName
		FROM employees e, departments d
	 WHERE e.department_id = d.department_id
		 AND e.employee_id = 988;	
		 
	dbms_output.PUT_LINE(vEmployeeId || ' - ' || vEmployeeName || ', ' || vEmployeeSalary || ', ' || vDepartmentName);
	EXCEPTION
		WHEN too_many_rows THEN
			dbms_output.PUT_LINE('Muitos registros retornados.');
		WHEN no_data_found THEN
			dbms_output.PUT_LINE('Nenhum registro encontrado.');
		WHEN OTHERS THEN
			dbms_output.PUT_LINE('Erro ao buscar funcionários: ' || SQLERRM);
END;
-------------------------------------------------------------------

/* Os comandos DML, quando utilizados em BLOCOS PLSQL, poussuem a mesma sintaxe e comportamento apresentado na linguagem SQL. */

-- Comando INSERT
BEGIN
	INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, job_id, salary)
	VALUES (employee_seq.NEXTVAL, 'Tiago', 'Nogueira', 'th@gmail.com', '27/10/2021', 'IT_PROG', 30000);
  COMMIT;
END;

-- Comando UPDATE
DECLARE
	vLastName employees.last_name%TYPE DEFAULT 'Bixão';
	vSalary employees.salary%TYPE DEFAULT &salary;
BEGIN
	UPDATE employees
		 SET last_name = vLastName,
		     salary = vSalary
	 WHERE first_name = 'Paulo';
  COMMIT;
END;

-- Comando DELETE
DECLARE
	vEmployeeId employees.employee_id%TYPE DEFAULT 208;
BEGIN
	DELETE FROM employees WHERE employee_id = vEmployee_id;
	COMMIT;
END;
------------------------------------------------------------------

/* TRANSAÇÕES consistem em conjuntos de comandos DML, que formam uma unidade lógica de trabalho.
 - Neste conceito, uma transação é bem sucedida quando todos os comandos envolvidos são efetivados, caso contrário nenhum deverá ser efetivado.
 - Comandos DDL e DCL possuem comandos COMMIT automático.
 
 * Uma transação se inicia com a execução de um comando DML e é finalizada em uma das seguintes situações:
   - Após a execução dos commandos COMMIT ou ROLLBACK
	 - Após a execução de comandos DDL ou DCL, pois elas tem COMMIT automático (Nesse caso, os dados alterados antes do comando DDL ou DCL podem ser gravados inconsistentes).
	 - Após o encerramento anormal da sessão (efetuando um COMMIT automático)
	 - Após CRASH do sistema (Queda do sistema operacional, rede, banco de dados) - Neste caso, após retorno do sistema, operações pendentes nas sessões receberão um ROLLBACK automático.

 * Transações permitem a utilização de SAVEPOINTS, permitindo retornar o banco ao último estado salvo, descartando todas as alterações
	 feitas após o SAVEPOINT salvo.	 
*/

-- PROCEDURE PARA RETORNAR ESTADO DA SEQUENCIA;
CREATE OR REPLACE PROCEDURE prcRecuperaValorAnteriorDaSequencia(sequenceName IN VARCHAR2) IS
BEGIN
	EXECUTE IMMEDIATE 'ALTER SEQUENCE :1 INCREMENT BY -1 MINVALUE 0' USING sequenceName;
END prcRecuperaValorAnteriorDaSequencia;

/* VERIFICAR ESSE TESTE NO FUTURO
	DECLARE
		vNewSalary  employees.salary%TYPE DEFAULT &pNewSalary;
		vEmployeeId employees.employee_id%TYPE;
	BEGIN
		vEmployeeId := employees_seq.NEXTVAL;
		BEGIN
			INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, job_id, salary)
			VALUES (vEmployeeId, 'Tiago', 'Nogueira', 'th@gmail.com', '27/10/2021', 'IT_PROG', 30000);
			dbms_output.PUT_LINE(vEmployeeId);
			SAVEPOINT insertPoint;
			
			EXCEPTION 
				WHEN OTHERS THEN
					prcRecuperaValorAnteriorDaSequencia('employees_seq');
					ROLLBACK;
		END;
		BEGIN
			UPDATE employees
				 SET salary = vNewSalary
			 WHERE employee_id = vEmployeeId;
			
			IF vNewSalary < 20000 THEN 
				RAISE_APPLICATION_ERROR(-20001, 'Empregado não pode receber menos do que 20000.');
			END IF;
			
			EXCEPTION 
				WHEN OTHERS THEN
					dbms_output.PUT_LINE(SQLERRM);
					ROLLBACK TO insertPoint;
					COMMIT;
		END; 
	END;*/

-- Transação simples.
DECLARE
	vEmployeeId employees.employee_id%TYPE := 208;
BEGIN
	UPDATE employees
	   SET salary = 33000
	 WHERE employee_id = vEmployeeId;
	 COMMIT;
END;

-- Transação básica com SAVEPOINT
BEGIN
	INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, job_id, salary)
	VALUES (employees_seq.NEXTVAL, 'Renato', 'Nogueira', 'nato@gmail.com', '01/03/2016', 'IT_PROG', 3000);
	SAVEPOINT insertOk;
	
	UPDATE employees
		 SET salary = 12000
	 WHERE employee_id = 209;
  ROLLBACK TO insertOk;
	COMMIT;
END;

/* Transação complexa 
 Neste exemplo, é necessário atentar-se que, ao utilizar o ROLLBACK TO SAVEPOINT, os valores armazenados
 nas variáveis não são restaurados ao estado anterior, apenas os dados alterados no banco de dados.
 Os valores das variáveis deverão ser retornados ao estado anterior utilizando a lógica desenvolvida no programa. */
DECLARE
	vSalarioAtual employees.salary%TYPE;
	vNovoSalario  employees.salary%TYPE := &newSalary;
BEGIN
	SELECT salary INTO vSalarioAtual FROM employees WHERE employee_id = 208;
	UPDATE employees
		 SET salary = vNovoSalario
	 WHERE employee_id = 208;
	dbms_output.PUT_LINE('Primeiro salário informado: ' || vNovoSalario);
	
	IF(vNovoSalario < vSalarioAtual) THEN
		dbms_output.PUT_LINE('Menor do que o atual.');
	ELSE
		vSalarioAtual := vNovoSalario;
	END IF;
	SAVEPOINT primeiroUpdate;
	
	vNovoSalario := &newSalary;
  UPDATE employees
		 SET salary = vNovoSalario
	 WHERE employee_id = 208;
	SAVEPOINT segundoUpdate;
	dbms_output.PUT_LINE('Segundo salário informado: ' || vNovoSalario);
	
	IF vNovoSalario < vSalarioAtual THEN
		dbms_output.PUT_LINE('Menor do que o atual.');
		ROLLBACK TO primeiroUpdate;
		IF vNovoSalario < vSalarioAtual THEN
			dbms_output.PUT_LINE('Salário não pode ser menor do que o atual.');
			ROLLBACK;
		ELSE COMMIT;
		END IF;
	ElSE COMMIT;
	END IF;
END;

/* CURSOR IMPLÍCITO é aberto sempre que é executado um comando SQL.
 - Esse cursor é aberto administrado e fechado automaticamente pelo ORACLE.
 - Após cada comando, é possível utilizar um atributo de cursor para verificar se houve ou não alteração nos dados.
 - Os atributos de cursor devem ser utilizados imediatamente após o comando ser executado, pois ao executar qualquer outro comando, o valor será sobrescrito.
 - O nome do cursor é SQL e os atributos possíveis são: SQL%ROWCOUNT, SQL%FOUND, SQL%NOTFOUND. */
 
 /* OPERADORES PLSQL
 - Existe uma regra de precedência quanto à utilização dos operadores utilizados no PLSQL, principalmente quando utilizados em operações complexas.
 - As operações são lidas, linha a linha, da esquerda para a direita.
 1°: Exponênciações
 2°: Sinais positivo e negativo para os números
 3°: Operadores de multiplicação e divisão - na mesma procedência
 4°: Operadores de adição, subtração e concatenação - na mesma precedência
 5°: Operadores de comparação = < > <= >= <> != BETWEEN IN IS NULL LIKE 
 6°: Operador lógico AND
 7°: Operador lógico NOT
 8°: Operador lógido OR 

 Para forçar ou sobrepor uma regra de precedência, utiliza-se parênteses. 
 Caso os parênteses estejam alinhados, serão resolvidos de dentro pra fora. */