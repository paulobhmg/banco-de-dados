/* TRIGGERS de bancos de dados
 - São gatilhos, disparados automaticamente, antes ou depois de um comando DML (INSERT, UPDATE, DELETE).
 - Utilizados para automatizar ações nas tabelas de bancos de dados.
 - Existem TRIGGERS DE LINHA e TRIGGERS DE TABELA.
 - Triggers de tabela são acionadas uma única vez, antes ou depois de um comando DML e pode executar uma operação específica, 
   como calcular o valor total do salário de todos os empregados, ou fazer uma alteração em todos os dados da tabela.
 - Triggers de linha são acionadas PARA CADA REGISTRO afetado por um comando DML, ou seja, para cada linha afetada pelo comando DML,
   será executada uma ação, definida no código da trigger.
 
 ** A sequência de execução das triggers é a seguinte, cada uma com sua prioridade, caso exista.
	 1° - Executa Trigger de tabela BEFORE
	 2° - Executa Trigger de linha BEFORE
	 3° - Executa a operação DML que acionou o gatilho
	 4° - Executa Trigger de linha AFTER
	 5° - Executa Trigger de tabela AFTER */
   
-- TRIGGERS A NÍVEL DE COMANDO.
CREATE OR REPLACE TRIGGER trg_bfr_insert_employee_stm BEFORE INSERT ON employees
BEGIN
  IF TO_CHAR(SYSDATE, 'DAY') IN ('SÁBADO', 'DOMINGO') OR TO_CHAR(SYSDATE, 'HH24') NOT BETWEEN 8 AND 18 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Funcionários só podem ser cadastrado de segunda à sexta, em horário comercial.');
  END IF;     
END trg_bfr_insert_employee_stm;

-- É possível utilizar alguns pseudônimos para manipular o comportamento de uma trigger, de acordo com a operação que está sendo realizada.
CREATE OR REPLACE TRIGGER trg_bfr_dml_employee_stm 
BEFORE INSERT OR DELETE OR UPDATE ON employees
BEGIN
  IF TO_CHAR(SYSDATE, 'DAY') IN ('SÁBADO', 'DOMINGO') OR TO_CHAR(SYSDATE, 'HH24') NOT BETWEEN 8 AND 18 THEN
    IF INSERTING THEN
      RAISE_APPLICATION_ERROR(-20001, 'Não é possível inserir novos funcionários fora do horário comercial.');
    ELSIF DELETING THEN 
      RAISE_APPLICATION_ERROR(-20001, 'Não é possível alterar dados de funcionários fora do horário comercial');
    ELSE 
      RAISE_APPLICATION_ERROR(-200001, 'Não é possível deletar funcionários fora do horário comercial.');
    END IF;
  END IF;
END;

-- Código teste para disparar a trigger antes de um INSERT
BEGIN
  insere_novo_empregado(
    pfirst_name => 'Augusto',
    plast_name => 'Nogueira',
    pemail => 'agNog',
    phire_date => SYSDATE,
    pjob_id => 'IT_PROG', 
    psalary => 3000,
    pcommission => NULL
  );
  
  dbms_output.PUT_LINE('Linhas afetadas: ' || sql%ROWCOUNT);
  IF(sql%ROWCOUNT >= 1) THEN
    dbms_output.PUT_LINE('Funcionário cadastrado.');
    COMMIT;
  ELSE ROLLBACK;    
  END IF;
END;
---------------------------------------------

/* Para as TRIGGERS DE LINHA, é possível adicionar uma cláusula WHEN, fazendo com que a TRIGGER só seja disparada caso a condição dessa cláusula seja verdadeira */

-- Tabela que será populada automaticamente pelo disparo da trigger
CREATE TABLE employees_log (
	log_id      NUMBER(6) NOT NULL,
	data_log    DATE DEFAULT SYSDATE,
	usuario     VARCHAR2(30) NOT NULL,
	evento 	 		CHAR(1) NOT NULL,
	employee_id NUMBER(6) NOT NULL,
	old_salary  NUMBER(8,2)
	new_salary  NUMBER(8,2)
);

ALTER TABLE employees_log
ADD CONSTRAINT employees_log_pk PRIMARY KEY (log_id);

CREATE SEQUENCE employee_log_seq 
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE
MINVALUE 1
NOMAXVALUE;

-- TRIGGER
CREATE OR REPLACE TRIGGER trg_grava_log_employee_aft_dml 
AFTER INSERT OR DELETE OR UPDATE OF salary ON employees
FOR EACH ROW
WHEN (new.salary > 1000)
DECLARE
	vEvento 		 CHAR(1);
	vEmployee_id employees.employee_id%TYPE;
BEGIN
	CASE
		WHEN INSERTING THEN
			vEvento := 'I';
			vEmployee_id := :NEW.employee_id;
		WHEN UPDATING THEN
			vEvento := 'U';
			vEmployee_id := :OLD.employee_id;
		WHEN DELETING THEN 
			vEvento := 'D';
			vEmployee_id := :OLD.employee_id;
		END CASE;	
	prc_grava_log_employee(vEvento, vEmployee_id, :OLD.salary, :NEW.salary);
END;

-- Procedure que será executada pela trigger
CREATE OR REPLACE PROCEDURE prc_grava_log_employee(pEvento CHAR, pEmployee_id NUMBER, pOld_salary NUMBER, pNew_salary NUMBER) IS
BEGIN
	INSERT INTO employees_log (log_id, usuario, evento, employee_id, old_salary, new_salary)
	VALUES (employee_log_seq.NEXTVAL, USER, pEvento, pEmployee_id, pOld_salary, pNew_salary);

	EXCEPTION
		WHEN OTHERS THEN
			RAISE_APPLICATION_ERROR(-20001, 'Erro ao inserir log de usuário');
END;

-- Código testador da trigger
UPDATE EMPLOYEES SET salary = 1500 WHERE employee_id = 100;

INSERT INTO employees(employee_id, last_name, email, hire_date, job_id, salary)
VALUES (employees_seq.NEXTVAL, 'sobrenome', 'email', SYSDATE, 'IT_PROG', 13000);

DELETE FROM employees where employee_id = 213;
---------------------------------------------------------------------------------------------

/* MUTATING TABLES são tabelas que estão sendo alteradas por uma TRIGGER
 Existem algumas regras que restringem a manipulação de MUTATING TABLES:
 - Não alterar primary keys, foreign key ou unique keys, da tabela base da trigger.
 - Essa restrição é valida para todas as triggers a nível de linha
 - Também é válida para triggers de comando onde foram utilizadas comando DELETE CASCADE
 
 - Não ler informações de tabelas que estão sendo modificadas, também válida para triggers a nível de linha.
 - Triggers de comando podem ler informações das MUTANT TABLES, exceto para operações DELETE CASCADE
*/

-- Essa trigger viola a regra para triggers de linha, que diz que não é possível efetuar operações em chaves primárias, estrangeiras e unique, de MUTANT TABLES.
CREATE OR REPLACE TRIGGER trg_altera_email_aft_dml
AFTER DELETE OR INSERT OR UPDATE ON employees
FOR EACH ROW
DECLARE
	vEmail employees.email%TYPE;
BEGIN
	UPDATE employees
	   SET email = SUBSTR(:NEW.first_name, 1, 1) || :NEW.last_name
	 WHERE employee_id = :OLD.employee_id;
	 
  EXCEPTION
		WHEN OTHERS THEN
			RAISE_APPLICATION_ERROR(-20001, 'Erro na trigger.');
END;

-- Testando a violação da TRIGGER de linhas acima
-- O comando update abaixo irá ocasionar um erro de MUTANT TABLE, pois ao ser acionada irá tentar atualizar o e-mail do empregado dentro da trigger.
UPDATE employees
	SET  salary = 1000
 WHERE employee_id = 100;
 
-- DROP da trigger para novo teste
DROP TRIGGER trg_altera_email_aft_dml;

-- Criando uma TRIGGER que não irá violar as regras, pois apesar de fazer referência aos novos valores, não atualizará dentro da trigger os dados da MUTANT TABLE
CREATE OR REPLACE TRIGGER trg_altera_email_aft_dml
AFTER DELETE OR INSERT OR UPDATE ON employees
FOR EACH ROW
DECLARE
	vEmail employees.email%TYPE;
BEGIN
	vEmail := SUBSTR(:new.first_name, 1, 1) || :NEW.last_name;
	
	EXCEPTION
		WHEN OTHERS THEN
			RAISE_APPLICATION_ERROR(-20001, 'Erro na trigger: ' || SQLERRM);
END;

-- TESTANDO o acionamento da trigger.
UPDATE employees 
	 SET email = 'teste...'
 WHERE employee_id = 100;
----------------------------------------

/* Como segunda regra para MUTANT TABLES, temos que não é possível efetuar SELECT's dentro da TRIGGER */

-- Apagar a TRIGGER novamente para criar um novo exemplo
DROP TRIGGER trg_altera_email_aft_dml;

CREATE OR REPLACE TRIGGER trg_employees_aft_dml 
AFTER INSERT OR UPDATE OR DELETE ON employees
FOR EACH ROW
DECLARE
	vMaxSalary employees.salary%TYPE;
BEGIN
	SELECT MAX(salary) 
		INTO vMaxSalary
		FROM employees;
	
	IF NOT DELETING AND :NEW.salary > vMaxSalary * 1.2 THEN
		RAISE_APPLICATION_ERROR(-20001, 'Salário não pode ser maior do que o maior salário + 20%.');
	END IF;
	
	EXCEPTION 
		WHEN OTHERS THEN
			RAISE_APPLICATION_ERROR(-20002, 'Erro de trigger: ' || SQLERRM);
END;

-- Testando a violação da TRIGGER
INSERT INTO employees(employee_id, last_name, email, hire_date, job_id, salary)
VALUES (employees_seq.NEXTVAL, 'sobrenome', 'email', SYSDATE, 'IT_PROG', 13000);
-------------------------------------

/* Para contornar o problema das MUTANT TABLE, é possível utilizar TRIGGERS DE COMANDO, em conjunto com elas, 
	 pois nessas, a única restrição está para as operações de DELETE CASCADE. */
	 
-- PACKAGE para armazenar uma variável global
CREATE OR REPLACE PACKAGE pkg_global IS
	gMaxSalary employees.salary%TYPE;
END pkg_global;

-- TRIGGER DE COMANDO
CREATE OR REPLACE TRIGGER trg_employees_bfr_dml_stmt 
BEFORE INSERT OR UPDATE OR DELETE ON employees
BEGIN
	SELECT MAX(salary)
		INTO pkg_global.gMaxSalary
		FROM employees;
		
	EXCEPTION 
		WHEN OTHERS THEN
			RAISE_APPLICATION_ERROR(-20001, 'Erro na trigger de captura de máx salary: ' || SQLERRM);
END;

-- TRIGGER DE LINHA
-- Para esse exemplo, o problema de MUTANT TABLE foi contornado, pois a TRIGGER acima executa a consulta do maior salário e atribui esse valor à variável global
-- E na trigger abaixo o valor da variável global é utilizado na comparação do salário.
CREATE OR REPLACE TRIGGER trg_employees_aft_dml 
AFTER INSERT OR UPDATE OR DELETE ON employees
FOR EACH ROW
BEGIN
	IF NOT DELETING AND :NEW.salary > pkg_global.gMaxSalary THEN
		RAISE_APPLICATION_ERROR(-20001, 'Salário não pode ser maior do que o maior salário + 20%.');
	END IF;
	dbms_output.PUT_LINE(pkg_global.gMaxSalary);
	
	EXCEPTION 
		WHEN OTHERS THEN
			RAISE_APPLICATION_ERROR(-20002, 'Erro de trigger: ' || SQLERRM);
END;

-- Testando a solução
UPDATE employees
   SET salary = 32000 
 WHERE employee_id = 100;
 
 /* É possível habilitar e desabilitar triggers.
  - Essa funcionalidade é útil quando há a necessidade de fazer uma carga de dados ou efetuar algum teste no sistema e
	  e é necessário desabilitar as travas e validações contidas em uma trigger específica ou em TODAS as triggers de uma tabela */
		
-- Desabilitando uma TRIGGER específica
ALTER TRIGGER trg_employees_aft_dml DISABLE;

-- Habilitando uma TRIGGER específica
ALTER TRIGGER trg_employees_aft_dml ENABLE;

-- Desabilitando TODAS as triggers de uma tabela
ALTER TABLE employees DISABLE ALL TRIGGERS;

-- Habilitando TODAS as triggers de uma tabela
ALTER TABLE employees ENABLE ALL TRIGGERS;

-- Para consultar TRIGGERS no dicionário de dados ORACLE, utilizamos a VIEW USER_TRIGGERS
SELECT * 
	FROM USER_TRIGGERS
 WHERE table_name = 'EMPLOYEES'
   AND table_owner = 'HR';
	 
-- RECOMPILANDO TRIGGERS
ALTER TRIGGER trg_bfr_dml_employee_stm COMPILE;

-- REMOVENDO TRIGGERS
DROP TRIGGER trg_altera_email_bfr;