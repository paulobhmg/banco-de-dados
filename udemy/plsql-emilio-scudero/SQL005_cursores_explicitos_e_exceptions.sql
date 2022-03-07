/* CURSORES EXPLÍCITOS
	- Diferente dos cursores implíticos, que nos permitem utilizar seus atributos apenas para saber se a operação foi realizada com sucesso,
    esses nos permitem controlar melhor as ações que serão seguidas, com base no valor dos seus atributos. 
  - Permitem alocar na memória do ORACLE os dados contidos em consulta. Dessa forma, é possível executar uma série de operações
	  com esses dados, conhecidos como RESULT SET. 
	- Normalmente cursores são utilizados em conjunto com LOOPS, pois um cursor por si só, não retorna seus dados, apenas os armazena.
    Sendo assim, é necessário utilizar comando auxiliares, como FETCH, que recupera o registro apontado pelo ponteiro do cursor, e quando é um cursor
    que possui vários registros, é necessário utilizar um FETCH repetidas vezes.		
	- Para manipular os dados de um cursor, é necessário que o FETCH armazene os valores contidos no cursor em variáveis de memória.
	  Normalmente, quando cria-se cursores, criam-se também estruturas do tipo record, que irão receber os dados do cursor.
	*/

/* Controlando cursor com LOOP SIMPLES
 - Neste exemplo, o loop irá percorrer o vetor, passando por todos os registros.
   Em cada iteração é feito um teste, verificando se o FETCH encontrou algum valor e caso não encontre, sai do LOOP e fecha o cursor.
	 Caso encontre valor, imprime os dados do funcionário e pula para o próximo registro. */

DECLARE
	CURSOR c1 IS 
		SELECT employee_id, first_name
			FROM employees 
		 ORDER BY employee_id;
	r1 c1%ROWTYPE;
BEGIN
	OPEN c1;
		LOOP
			FETCH c1 INTO r1;
			EXIT WHEN c1%NOTFOUND;
			dbms_output.PUT_LINE(r1.employee_id || ' - ' || r1.first_name);
		END LOOP;
	CLOSE c1;
	
	EXCEPTION 
		WHEN OTHERS THEN
			dbms_output.PUT_LINE(SQLERRM);
END;

-- LOOP SIMPLES em cursor com parâmetro
DECLARE
	CURSOR c1(pJob_id IN VARCHAR2) IS
		SELECT employee_id, first_name, salary 
			FROM employees
		 WHERE job_id = pJob_id
		 ORDER BY employee_id;
	r1 c1%ROWTYPE;
BEGIN
	OPEN c1(pJob_id => 'IT_PROG');
		LOOP
			FETCH c1 INTO r1;
			EXIT WHEN c1%NOTFOUND;
			dbms_output.PUT_LINE(r1.employee_id || ' - ' || r1.first_name || ', ' || r1.salary);
		END LOOP;
	CLOSE c1;
	EXCEPTION
		WHEN OTHERS THEN
			dbms_output.PUT_LINE(SQLERRM);
END;
---------------------------

/* Controlando com WHILE LOOP
 - Para esse laço a situação é um pouco diferente, pois primeiro é feito o FETCH e caso não encontre valor, nem entra no LOOP.
 - Se o primeiro FETCH possuir algum valor, entra no LOOP, executa o código para a primeira iteração e 
 - faz um novo FETCH. Para este caso, a condição para permanecer no LOOP é encontrar valor no cursor. Ou seja, quando não encontrar, sai do cursor. */
 
DECLARE
	CURSOR c1 IS
		SELECT employee_id, first_name, salary
		  FROM employees
	   WHERE job_id = 'IT_PROG'
		 ORDER BY employee_id;
	r1 c1%ROWTYPE;
BEGIN
	OPEN c1;
		FETCH c1 INTO r1;
		
		WHILE c1%FOUND LOOP
			dbms_output.PUT_LINE(r1.employee_id || ' - ' || r1.first_name || ', ' || r1.salary);
			FETCH c1 INTO r1;
			EXIT WHEN c1%NOTFOUND;
		END LOOP;
	CLOSE c1;
END;
---------------------------

/* Controlando com FOR LOOP
 - Esse LOOP fornece maior facilidade, pois não há necessiade de criar uma variável RECORD para armazenar os valores,
   pois essa é criada em tempo de execução, na execução do LOOP.
 - Não há necessidade de abertura e fechamento do CURSOR, pois o próprio laço se encarrega de abrir e fechar. 
 - Há ainda a possibilidade definir um SELECT para o cursor na própria definição do laço */

-- Exemplo com CURSOR EXPLÍCITO
DECLARE
	CURSOR c1 IS 
		SELECT employee_id, first_name, salary
		  FROM employees
		 WHERE job_id = 'IT_PROG'
		 ORDER BY employee_id;
BEGIN
	FOR r1 IN c1 LOOP
		dbms_output.PUT_LINE(r1.employee_id || ' - ' || r1.first_name || ', ' || r1.salary);
	END LOOP;
END;

-- Exemplo com CURSOR EXPLÍCITO + PARÂMETRO
DECLARE
	CURSOR c1(pJob_id VARCHAR2) IS
		SELECT employee_id, first_name, salary
		  FROM employees
		 WHERE job_id = pJob_id
		 ORDER BY employee_id;
BEGIN
	FOR r1 IN c1(pJob_id => 'IT_PROG') LOOP
		dbms_output.PUT_LINE(r1.employee_id || ' - ' || r1.first_name || ', ' || r1.salary);
	END LOOP;
END;

-- Exemplo com CURSOR declarado em tempo de execução
BEGIN
	FOR r1 IN (
		SELECT employee_id, first_name, salary
		  FROM employees
		 WHERE job_id = 'IT_PROG'
		 ORDER BY employee_id )
	LOOP
		dbms_output.PUT_LINE(r1.employee_id || ' - ' || r1.first_name || ', ' || r1.salary);
	END LOOP;
END;
----------------------------------------------------------------------

/* EXCEÇÕES 
 - Permitem capturar e tratar erros obtidos durante a execução do código do programa
 - Caso uma EXCEPTION não seja tratada, ocorrerá a finalização do sistema por erro.
 - Quando uma EXCEPTION é lançada, caso não seja tratada no bloco em que foi lançada, será propagada para o bloco mais externo.
 - As exceções podem ser predefinidas, definidas pelo desenvolvedor ou exceções existentes que não possuem um código vinculado a ela. Essas devem ser tratadas através de PRAGMA EXCEPTION. 
 - NÃO são obrigatórias, porém altamente recomendadas, tendo em vista que o não tratamento poderá ocasionar erro e a parada do sistema.
 - Na cláusula WHEN da EXCEPTION, pode ser passada como condição uma ou mais exceptions. 
 
 ** Quando uma exceção é capturada em um bloco WHEN, poderá escolher qual ação será tomada, inclusive parar o sistema
    através da PROCEDURE RAISE_EXCEPTION_ERROR, que faz com que a execução do sistema seja interrompida e exibido o código do erro e mensagem.
 ** Exceções definidas pelo desenvolvedor deverão ser lançadas através do comando RAISE e deverá ser tratada, pois o Oracle NÃO trata exceções definidas
    pelo desenvolvedor, sendo necessário a declaração, lançamento e tratativa por parte do desenvolvedor. */

-- Tratando EXCEPTIONS predefinidas da oracle
DECLARE
	vEmployee employees%ROWTYPE;
	vId NUMBER := &id;
BEGIN
	SELECT * INTO vEmployee FROM employees
	WHERE employee_id = vId;
	
	dbms_output.PUT_LINE(vEmployee.employee_id || ' - ' || vEmployee.first_name);
	
	EXCEPTION 
		WHEN no_data_found THEN
			RAISE_APPLICATION_ERROR(-20001, q'[Nenhum registro encontrado para o ID ']' || vId || q'['.]');
		WHEN too_many_rows THEN
			RAISE_APPLICATION_ERROR(-20002, 'Muitos registros para SELECT INTO');
		WHEN OTHERS THEN
			RAISE_APPLICATION_ERROR(-20003, SQLERRM);
END;

/* Tratando EXCEPTIONS defindas pelo desenvolvedor
 - O exemplo abaixo apresenta uma má prática, pois o RAISE está sendo utilizado como redirecionador de fluxo, ou seja,
   se o cargo for de presidente, direciona, da mesma forma que o GO TO, para o tratamento da exceção, que simplesmente executa uma atualização do salário do presidente.
 - O comando RAISE deve ser utilizado apenas para capturar exceções definidas pelo desenvolvedor,
   ou seja, as exceptions que NÃO são conhecidas pelo Oracle e devem ser tratadas, caso ocorram. */
	 
DECLARE
	vEmployee_id 					 employees.employee_id%TYPE;
	vJob_id 		 					 employees.job_id%TYPE;
	is_president_exception EXCEPTION;
BEGIN
	SELECT employee_id, job_id 
	  INTO vEmployee_id, vJob_id
		FROM employees
	 WHERE employee_id = &id;
  
  IF vJob_id = 'AD_PRES' THEN
    RAISE is_president_exception;
  ELSE 
    dbms_output.PUT_LINE('Não tem cargo de presidente');
  END IF;
  
	EXCEPTION
		WHEN no_data_found THEN
      RAISE_APPLICATION_ERROR(-20001, 'Funcionário não encontrado.');
		WHEN is_president_exception THEN
			UPDATE employees
				 SET salary = salary * 1.11
			 WHERE employee_id = vEmployee_id;
			COMMIT;
      dbms_output.PUT_LINE('Salário do presidente alterado.');
		WHEN OTHERS THEN
			RAISE_APPLICATION_ERROR(-20002, SQLERRM);
END;


/* PRAGMA EXCEPTION_INIT 
 - Existem erros no Oracle que não estão vinculados a nenhum código predefinido da ORACLE. Dessa forma, não há como tratá-los.
   Por exemplo, erros de UNIQUE KEY, FK CONSTRAINTS. Esses erros, embora possam acontecer e parar a execução do programa, não 
	 tem um código vinculado. 
 - Dessa forma, para tratá-los, é necessário definir uma EXCEPTION, da mesma forma que foi definida no exemplo anterior, e 
   vinculá-la à um código de erro do Oracle. Dessa forma, quando ocorrer tal erro, a exceção será lançada. 
 - Aqui, uma outra diferença é que não é necessário utilizar o comando RAISE para lançar a exception, pois a partir do momento em que
   ela foi vinculada pelo PRAGMA EXCEPTION_INIT, o oracle passou a conhecê-la e capturá-la para tratativa. 
	
 ** Como os códigos de erros do oracle são muitos, nos casos em que há a necessidade de tratar erros de códigos desconhecidos, as opções
    que temos é pesquisar os erros na documentação do oracle ou forçar o erro a acontecer, a fim de descobrir qual é o seu código vinculado. */

DECLARE
	fk_not_found_exception EXCEPTION;
	PRAGMA EXCEPTION_INIT(fk_not_found_exception, -2291);
BEGIN
	INSERT INTO employees (employee_id, last_name, email, hire_date, job_id) 
	VALUES (employees_seq.NEXTVAL, 'trust', 'pkk@gmail', SYSDATE, 'INEXTISTS');
	COMMIT;

	EXCEPTION 
		WHEN fk_not_found_exception THEN
			RAISE_APPLICATION_ERROR(-20002, 'Não existe o cargo informado para o SELECT');
		WHEN OTHERS THEN 
			ROLLBACK;
			RAISE_APPLICATION_ERROR(-20003, SQLERRM);	
END;