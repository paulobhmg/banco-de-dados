/* DBMS_FLASHBACK 
   Permite consultar os dados do banco de dados em momentos passados, possibilitando restaurar o estado do banco 
	 após algum erro ou atualização incorreta de dados 
	
 - Possibilita visualizar como os dados estavam antes do COMMIT e caso tenha ocorrido algum erro é possível utilizar o 
   SYSTEM CHANGE NUMBER, que é um ponto no tempo, para restaurar as informações. 
 - Essa funcionalidade permite restaurar os dados sem a necessidade de efetuar um BACKUP, que pode ocasionar na perda das novas informações lançadas antes do erro.
 - A restauração é feita a partir dos SEGMENTOS de UNDO, que devem ser estudados em um curso de administração de banco de dados.
 - É possível configurar esses segmentos, definindo um tempo que será possível restaurar o estado do banco.

 ** A tablespace de UNDO é circular e seus dados são sobrepostos na medida em que seu espaço é preenchido. Portanto, o DBA configura um tamanho para essa tablespace
    e também o parâmetro UNDO_RETENTION, visto na view v$parameter. Esse parâmetro configura, EM SEGUNDOS, qual é o tempo que os dados do banco de dados deverão permanecer
		na tablespace de UNDO, para flashback do banco, caso seja necessário. 
	- Vale ressaltar que esse parâmetro não necessariamente é quem definirá o tempo de armazenamento, tendo em vista que dependendo do tamanho da tablespace, os dados poderão
	  ser armazenados por mais tempo e também e maior volume.
 É necessário o privilegio EXECUTE DBMS_FLASHBACK;
*/
	 
-- Privilégios para execução da package
GRANT EXECUTE ON dbms_flashback TO hr;

-- Para consultar os dados em um momento no passado, passando como parâmetro a data e hora em que deseja voltar no tempo.
-- A partir da utilização do comando abaixo, executar as consultas necessárias e armazenar os dados em memória.
dbms_flashback.ENABLE_AT_TIME(TO_DATE('15/03/2022 10:10:00', 'DD/MM/YYYY HH24:MI:SS'));

-- Depois de armazenar os dados em memória, desabilita o flashBack para voltar ao estado atual do banco e utiliza as informações restauradas para atualizar os dados do banco.
dbms_flashback.DISABLE;

-- Consultando os dados antes da alteração
SELECT employee_id, 
       first_name, 
       salary,
       job_id
  FROM employees
 WHERE job_id = 'IT_PROG';
	
-- Atualizando os dados
UPDATE employees
	 SET salary = 100
 WHERE job_id = 'IT_PROG';
COMMIT;

-- Em um contexto que não existe o FLASHBACK, caso o comando acima tenha sido incorreto, seria necessário fazer o backup dos dados.
DECLARE
	CURSOR c1 IS 
		SELECT employee_id, first_name, salary, job_id
	  	FROM employees 
		 WHERE job_id = 'IT_PROG';	
	vEmployees c1%ROWTYPE;
  TYPE empListType IS TABLE OF vEmployees%TYPE INDEX BY BINARY_INTEGER;
  empList empListType;
	linhasAfetadas INTEGER;
BEGIN
	dbms_flashback.ENABLE_AT_TIME(SYSDATE - 20 / 1440);
	OPEN c1;
		FETCH c1 BULK COLLECT INTO empList;
	CLOSE c1;
	dbms_flashback.DISABLE;
	
	FORALL i IN 1..empList.COUNT
		UPDATE employees
			 SET salary = empList(i).salary
		 WHERE job_id = 'IT_PROG' 
		   AND employee_id = empList(i).employee_id;
	
	linhasAfetadas := sql%ROWCOUNT;
	IF linhasAfetadas > 1 THEN 
		dbms_output.PUT_LINE('Linhas afetadas: ' || linhasAfetadas);
		COMMIT;
	ELSE
		ROLLBACK;
		dbms_output.PUT_LINE('ALGO ERRADO ACONTECEU');
	END IF;
	
	EXCEPTION 
		WHEN OTHERS THEN
			ROLLBACK;
			DBMS_OUTPUT.put_line(SQLERRM);
END;
---------------------------------------

/* FLASHBACK QUERY é uma forma mais simples de restaurar os dados, pois não há a necessidade de utilizar procedures, como por exemplo dbms_flashback.ENABLE_AT_TIME.
 - Dessa forma, é possível definir no próprio comando SELECT do cursor, qual é o momento no tempo em que se deseja consultar os dados do banco, passando um TIMESTAMP 
   desse momento. */

-- Consultando os dados antes da alteração
SELECT employee_id, 
       first_name, 
       salary,
       job_id
  FROM employees
 WHERE job_id = 'IT_PROG';
	
-- Atualizando os dados
UPDATE employees
	 SET salary = 100
 WHERE job_id = 'IT_PROG';
COMMIT;

-- Restaurando os dados com FLASHBACK QUERY
DECLARE
	CURSOR c1 IS
		SELECT employee_id, salary 
			FROM employees AS OF TIMESTAMP(SYSTIMESTAMP - INTERVAL '10' MINUTE)
		 WHERE job_id = 'IT_PROG';
	vEmployees c1%ROWTYPE;
	TYPE empTabType IS TABLE OF vEmployees%TYPE INDEX BY BINARY_INTEGER;
	empTab empTabType;
	linhasAfetadas NUMBER;
BEGIN
	OPEN c1;
		FETCH c1 BULK COLLECT INTO empTab;
	CLOSE c1;
	
	FORALL i IN 1..empTab.COUNT
		UPDATE employees
		   SET salary = empTab(i).salary
		 WHERE employee_id = empTab(i).employee_id;
  linhasAfetadas := sql%ROWCOUNT;
	
	IF linhasAfetadas >= 1 THEN
		COMMIT;
	ELSE 
		ROLLBACK;
		dbms_output.PUT_LINE('Erro ao atualizar.');
	END IF;
	dbms_output.PUT_LINE('Registros afetados: ' || linhasAfetadas);
	
	EXCEPTION 
		WHEN OTHERS THEN
			dbms_output.PUT_LINE(SQLERRM);	
END;	
-------------------------------------------

/* FLASHBACK DROP permite a restauração de tabelas dropadas que ainda estão na lixeira.
 - Quando esse recurso é utilizado, a tabela, os registros e índices são restaurados, porém as constraints NÃO são.
 - Para as constraints, será necessário a recriação ou a restauração através de scripts de importação, com base uma base de dados similar. 
 
 ** Após serem apagadas, as tabelas são armazenadas na view USER_RECYCLEBIN.
 ** Objetos na lixeira, recebem um novo nome, a fim de evitar o conflito de nomes de objetos. O nome antigo passa a ser referenciado pela coluna 'ORIGINAL_NAME' 
 
 ** Diferente do FLASHBACK de registros, objetos apagados não seguem o parâmetro de tempo para sua restauração, pois na medida em que a tablespace da lixeira precisar
    ser utilizada, os objetos que ali estão serão sobrescritos. 
		
 ** Objetos dropados com a cláusula PURGE, não serão enviados para a lixeira e serão removidos definitivamente do banco. Sendo assim, não poderão ser restaurados por esse recurso. */

-- Tabela para exemplo
CREATE TABLE employees_copy AS
SELECT * FROM employees;

-- Visualizando o objeto.
SELECT * FROM user_objects
WHERE object_name = 'EMPLOYEES_COPY';

-- Caso apague um objeto dessa forma, ele não irá para a lixeira.
DROP TABLE employees_copy PURGE;

-- Conferindo lixeira.
SELECT * FROM USER_RECYCLEBIN;

-- Restaurando a tabela da lixeira
FLASHBACK TABLE employees_copy TO BEFORE DROP;
-------------------------------------------


