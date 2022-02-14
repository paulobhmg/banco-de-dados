/* PL/SQL significa Procedural language / Structured query language
   escrita através de blocos de códigos que são executados diretamente no banco de dados,
	 permitindo o desenvolvimento de programas complexos, que processam grandes volumes de informação.
	 
	 A linguagem PL/SQL permite o armazenamento de programas diretamente no banco de dados, proporcionando
	 melhor performance para aplicações, tendo em vista que em uma procedure, function ou package já terão em seu 
	 escopo todos os comandos necessários para execução.
	 
	 ** Ao executar blocos PL/SQL através da interface SQLPLUS, os blocos são enviados para um motor PL/SQL que os compila, executa
	    e verifica a existência de comandos SQL. Caso existam, são enviados para o EXECUTOR SQL, que os passa para o banco de dados.
			
*/

-- Estrutura básica de um bloco PL/SQL, que pode conter blocos e vários sub-blocos.

DECLARE
	vNumero1 NUMBER;
	vNumero2 NUMBER;
	vSoma 	 NUMBER DEFAULT 0;
BEGIN
	vSoma := vNumero1 + vNumero2;
	dbms_output.PUT_LINE(vNumero1 || '+' || vNumero2 || '=' || vSoma);
	EXCEPTION
		WHEN OTHERS THEN
			dbms_output.PUT_LINE(SQLERRM);
END;

-- Declarando um cursor
DECLARE
	CURSOR c1(pManager_id NUMBER, pCountry_id VARCHAR) IS
		SELECT e.first_name, e.manager_id, e.department_id, d.location_id
			FROM employees e, departments d
		 WHERE e.manager_id = pManager_id
		   AND e.department_id = d.department_id
		   AND e.department_id IN (SELECT department_id 
															   FROM departments
															  WHERE location_id IN (SELECT location_id
																											  FROM locations 
																										   WHERE UPPER(country_id) = UPPER(pCountry_id)));
	r1 c1%ROWTYPE;
BEGIN
	OPEN c1(&pManager_id, '&pCountry_id');
    LOOP
			FETCH c1 INTO r1;
			EXIT WHEN c1%NOTFOUND; 
			dbms_output.PUT_LINE(r1.first_name || ', ' || r1.manager_id || ', ' || r1.department_id || ', ' || r1.location_id);
		END LOOP;
	CLOSE c1;
	EXCEPTION
		WHEN OTHERS THEN
			dbms_output.PUT_LINE(SQLERRM);
END;

/* O pacote DBMS_OUTPUT utiliza-se de um buffer em memória para transferência de mensagens.
   Com ele é possível fazer o debug visual do código e capturar mensagens em trechos específicos. 
	 As mensagens são exibidas APENAS AO TÉRMINO DO PROGRAMA.
	 
	 As procedures ENABLE e DISABLE desse pacote, habilitam e desabilitam as chamadas às demais funcionalidades.
*/ 			

-- PUT insere nova informação no BUFFER, mas não escreve a informação na tela.
-- Quando utilizado dessa forma, é necessário utilizar o NEW_LINE, que irá exibir ao final da execução, as informações do buffer.
BEGIN
	dbms_output.PUT('Hello ');
	dbms_output.PUT('World!');
	dbms_output.NEW_LINE;
END;

-- PUT_LINE insere uma nova informação, seguido de uma quebra de linha, imprimindo na tela ao final da execução.
BEGIN
	dbms_output.PUT_LINE('Hello World');
END;

/* Existem também as variáveis do tipo BIND e as de SUBSTITUIÇÃO. Ambas são utilizadas para substituir
   de forma dinâmica o conteúdo de uma variável utilizada durante a execução do programa. 
   
	 As variáveis do tipo BIND podem ser utilizadas em qualquer lugar do programa, na sessão ativa, e não é
	 necessário ser declarada em  bloco de declaração específico.
	 
	 Essas variáveis não podem ser utilizadas em cláusulas FROM, pois não permitem a utilização de palavras reservadas.
 */
 
-- Para declarar uma variável do tipo BIND, utiliza-se uma nomeação como uma declaração de variável comum
-- Porém, para referenciá-la é necessário utilizar ":" antes do nome da variável.
VARIABLE mensagem VARCHAR2(200);
BEGIN
	:mensagem := 'Curso PLSQL';
  dbms_output.PUT_LINE(:mensagem);
END;

-- Ativando o AUTOPRINT não é necessário utilizar o dbms_output para exibir o valor da variável, pois ele será exibido automaticamente
SET AUTOPRINT ON;

-- Para alterar o valor de uma variável do tipo BIND é necessário usar o comando EXEC
EXEC :mensagem := 'Olá mundo!';


/* As variáveis de SUBSTITUIÇÃO podem ser utilizadas em comandos DML ou PL/SQL. 
   Seu objetivo é deixar a consulta SQL dinâmica.
	 Ao contrário das variáveis do tipo BIND, estas podem ser utilizadas para completar códigos SQL
	 pois permitem a utilização de palavras reservadas em sua substituição.
	 
	 Não necessita ser obrigatoriamente declarada, pois pode ser criada no momento da execução do código.
	 Quando utilizamos diretamente sem defini-la, ela não ficará armazenada na sessão e será visivel apenas durante a execução que a referenciou.
*/

DEFINE manager_id = 101;
SELECT * 
FROM   employees
WHERE  manager_id = &manager_id;

-- Para visualizar o conteúdo de uma variável de substituição, utiliza-se DEFINE e para removê-la utiliza-se UNDEFINE;
DEFINE manager_id;
UNDEFINE manager_id;

-- Outra forma de definir uma variável, escolhendo qual mensagem será exibida para o usuário é com o ACCEPT
ACCEPT vManager_id NUMBER FOR 999 DEFAULT 10 PROMPT "Informe o código do gerente: ";
SELECT first_name, manager_id 
FROM   employees
WHERE  manger_id = &vManager_id;
------------------------------------------------------------------------------------------------------------------------------------------------------

/* Características básicas da linguagem:
   - Identificadores devem ter no máximo 30 caracteres
	 - Não é permitido a utilização de palavras reservadas
	 - Pode-se utilizar letras, números e ALGUNS caracteres especiais
	 - Obrigatoriamente devem iniciar com uma letra
	 - Seu escopo é limitado ao bloco onde foram declarados e cada bloco pode ter sua própria declaração de identificadores
*/

-- Exemplo
CREATE OR REPLACE PROCEDURE prc_processa_pagamento(pNumero_dias NUMBER) IS
	vValorIR 			NUMBER;
	vValorBruto   NUMBER;
	vValorLiquido NUMBER;
BEGIN
	vValorBruto := 6850;
	
	DECLARE
		vTaxaIR NUMBER DEFAULT 0.27;
	BEGIN
		vValorIR := ((vValorBruto * vTaxaIR) / 30) * pNumero_dias;
		vValorLiquido := vValorBruto - vValorIR;
	END;
	
	dbms_output.PUT_LINE('Salário: ' || vValorBruto);
	dbms_output.PUT_LINE('Dias trabalhados: ' || pNumeroDeDias);
	dbms_output.PUT_LINE('Valor IR: ' || vValorIR);
	dbms_output.PUT_LINE('Valor líquido: ' || vValorLiquido);
	
	EXCEPTION
		WHEN OTHERS THEN
			dbms_output.PUT_LINE(SQLERRM);
END;
	
/* Uma transação é uma unidade lógica de trabalho composta por um ou mais comandos DML
   utilizados para determinada operação no banco de dados.
	 Para concretizar de fato alterações no banco de dados é necessário utilizar comandos DCL específicos, que controlam a efetivação de uma transação. 
	 
	 Transações explícitas devem seguir as seguintes regras:
	  - Devem ser setadas como o primeiro comando da transação
		- São permitidas apenas consultas
		- Comandos DDL possuem COMMITS implícitos, portanto, se utilizados em uma transação, encerram o efeito do SET TRANSACTION
*/

-- Exemplo de transação uso incorreto de transação em SQL
DELETE FROM employees
WHERE  employee_id = 101;

SET TRANSACTION;
ROLLBACK;

-- Transações em PL/SQL seguem a mesma premissa que uma transação em SQL, fornecendo, além do controle transacional,
-- SAVEPOINTS, permitindo retornar o banco ao estado em que estava em determinados pontos no código de acordo com algum resultado insperado.
BEGIN
  INSERT INTO departments VALUES (271, 'Development', NULL, 1700);
  SAVEPOINT save1;
  
  INSERT INTO departments VALUES (272, 'Design', NULL, 1700);
  SAVEPOINT save2;
  
  INSERT INTO departments VALUES (273, 'ia', NULL, 1700);
  SAVEPOINT save3;
  
  INSERT INTO departments VALUES (274, 'Io', NULL, 1700);
  SAVEPOINT save4;
  
  ROLLBACK TO save1;
  COMMIT;
END;  

SELECT * FROM DEPARTMENTS;	

/* Tipos de dados em PL/SQL
	 - VARCHAR2: Extensão do VARCHAR utilizado em outras linguagens SQL, utilizado para armazenamento de texto
   - CHAR: Armazenamento de Strings de comprimento fixo
	 - NUMBER(p,s): Numérico com sinal e ponto decimal, sendo "p" a precisão e "s" a escala (casas decimais)
	 - DATE: Data com hora, minuto e segundo. Caso não seja especificado a hora, considera como padrão "00:00:00"
	 - BOOLEAN: true ou false
	 - CLOB e NCLOB: Armazenamento de objetos muito grandes
	 - BLOB: Armazena dados não estruturados como "som", "imagens" e "dados binários"
	 - BFILE: Armazena nome de arquivos e diretórios. Tamanho máx diretórios: 30 caract, tamanho máximo arquivos: 255 caract
	 - ROWID: Tipo especial que armazena o endereço físico das linhas armazenadas em uma tabela. Consultas por rowid são mais rápidas.
	 
	 ** Atentar-se às restrições para campos LONG e LONG RAW:
		  - Não podem crirar object type com esse atributo
			- Uma tabela só poderá ter um campo desse tipo
			- Não podem ser indexados
			- Não podem ser usados nas cláusulas WHERE, GROUP BY, ORDER BY e CONNECT BY
--------------------------------------------------------------------------------------------------------------------------------------------------------*/

-- EXCEPTIONS 

DECLARE
  vEmployee_id NUMBER;
BEGIN
  BEGIN
    SELECT employee_id 
      INTO vEmployee_id
      FROM employees
     WHERE department_id = 9999;
  END;
  
  -- O SELECT acima irá gerar NO_DATA_FOUND exception, pois não existe dp com esse número. Portanto, necessário tratar a exception.
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      dbms_output.PUT_LINE('Department not found');
    WHEN OTHERS THEN
      dbms_output.PUT_LINE(SQLERRM);
END;

-- No exemplo abaixo, é realizada uma consulta por um código de departamento existente.
-- Porém, o SELECT INTO irá retornar várias linhas gerar a TOO_MANY_ROWS exception, pois esse tipo de select permite o retorno de apenas um registro.
DECLARE
  vEmployee_id NUMBER;
BEGIN
  SELECT employee_id 
    INTO vEmployee_id
    FROM employees
   WHERE department_id = 40;
   
  dbms_output.PUT_LINE('Funcionário encontrado. ID: ' || vEmployee_id);
   
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      dbms_output.PUT_LINE('Department not found.');
    -- Antes de add a exceção abaixo, testar sem ela no código.
    WHEN TOO_MANY_ROWS THEN
      dbms_output.PUT_LINE('Mais de um registro retornado.');
    WHEN OTHERS THEN
      dbms_output.PUT_LINE('Erro ao recuperar funcionário: ' || SQLERRM);
END;


-- Quando o oracle captura uma exceção, ele interrompe imediatamente a execução do programa onde ela foi gerada.
-- Se a exceção for tratada por nós, o oracle não fará a interrupção do programa e todas as ações devem ser controladas pelo programador.

DECLARE
  vSalary NUMBER;
  vDepartment_id NUMBER;
BEGIN
  BEGIN
    SELECT AVG(NVL(salary, 0)), department_id
      INTO vSalary, vDepartment_id
      FROM employees
     WHERE department_id = 210
     GROUP BY department_id;
     
    EXCEPTION 
      WHEN NO_DATA_FOUND THEN
        dbms_output.PUT_LINE('Department not found.');
  END;
  -- Nesse exemplo, o valor de salário e departamento inseridos para um novo funcionário serão nulos, pois será capturado uma exceção,
  -- mas a execução do programa não será interrompida, ocasionando os valores incorretos para o INSERT.    
  BEGIN
    INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, job_id, salary, department_id)
    VALUES (210, 'Paulo', 'Nogueira', 'paulo@gmail.com', '03/11/2021', 'IT_PROG', vSalary, vDepartment_id);
    COMMIT;
  END;
  
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.PUT_LINE('Erro ao inserir funcionário: ' || SQLERRM);
END;

-- Para contornar a situação acima temos duas alternativas:
-- 1° Caso ocorra exceção no SELECT INTO, encerrar a execução, informando ao usuário o motivo.
-- 2° Criar blocos IF para verificar se os valores foram preenchidos no SELECT INTO, no momento do INSERT e retornar mensagem ao usuário (mais custoso e desnecessário).
DECLARE
  vSalary NUMBER;
  vDepartment_id NUMBER;
BEGIN
  BEGIN
    SELECT AVG(NVL(salary, 0)), department_id
      INTO vSalary, vDepartment_id
      FROM employees
     WHERE department_id = 90
     GROUP BY department_id;
    
    -- Exemplo corrigido. Ao capturar a exceção o programa será interrompido.
    -- A utilização do RAISE_APPLICATION_ERROR faz com que o programa seja desviado para o primeiro bloco de tratamento
    -- mais externo ao bloco onde ela foi gerada, fazendo com que as demais execuções sejam ignoradas.
    EXCEPTION 
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Department_not_found');
  END;
  
  BEGIN
    INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, job_id, salary, department_id)
    VALUES (211, 'Paulo', 'Nogueira', 'ptf@gmail.com', '03/11/2021', 'ANALYST', vSalary, vDepartment_id);
    COMMIT;
  END;
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      dbms_output.PUT_LINE('Erro ao inserir funcionário: ' || SQLERRM);
END;

/* Observação importante: 
   - Se a execução de um LOOP gerar uma exceção e nele não existir um bloco para tratá-la, o LOOP será interrompido e o programa será desviado
     para o primeiro bloco de tratamento mais externo ao LOOP.
   - Caso haja um bloco e ele não exija o interrompimento do LOOP, ele será executado até o fim e executará apenas a ação definida
     pelo desenvolvedor no tratamento da exceção.
*/

/* Além das exceções vistas anteriormente, que já são predefinidas pela oracle, há a possibilidade de o desenvolvedor
   criar suas próprias exceções. A diferença aqui é que o oracle NUNCA tratará este tipo de exceção, pois não as conhece.
   Cabe ao desenvolvedor, neste caso, declara-la, lança-la e tratá-la.
   
   Para lançar uma exceção criada, utiliza-se o comando RAISE <exception>. Este comando faz com que a execução dos demais não aconteça,
   desviando o programa para o primeiro bloco de tratamento dessa exceção.
   
   ** OBS: Funções de grupo (SUM, MAX, MIN, AVG ETC) não geram exceções. Elas geram valores nulos ou 0
*/
DECLARE
  vSalary NUMBER DEFAULT 1500;
  INVALID_SALARY_EXCEPTION EXCEPTION;
BEGIN
  INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, job_id, salary, department_id)
  VALUES (213, 'Paulo', 'Nogueira', 'ptg@gmail.com', '03/11/2021', 'IT_PROG', vSalary, 90);
    
  IF(vSalary > 1000) THEN  
    ROLLBACK;
    RAISE INVALID_SALARY_EXCEPTION;
  END IF;
  
  COMMIT;
  dbms_output.PUT_LINE('Empregado incluído com sucesso.');
  
  EXCEPTION 
    WHEN INVALID_SALARY_EXCEPTION THEN
      dbms_output.PUT_LINE('Salário do funcionário não pode ser maior do que 1000');
    WHEN OTHERS THEN
      dbms_output.PUT_LINE('Erro ao inserir funcionário: ' || SQLERRM);
END;
---------------------------------------------------------------------------------------------------------------------------------------------------------

/* ESTRUTURAS DE CONDIÇÃO
   São utilizadas quando há a necessidade de alteração no fluxo de um programa, baseando-se em determinada condição.
*/

-- Exemplo IF
DECLARE
	vNumber1   NUMBER := 10;
	vResultado NUMBER;
  vResto     NUMBER;
BEGIN
	vResultado := vNumber1 / 3; -- Alterar este valor para testar resultado diferente
  vResto := MOD(vNumber1, 3);
	IF(vResto = 0) THEN
		dbms_output.PUT_LINE('O resto da divisão é 0.');
	END IF;
	dbms_output.PUT_LINE('O resultado do cálculo é: ' || vResultado);
END;

-- EXEMPLO IF - ELSE
DECLARE
	vNumber1   NUMBER := 10;
	vResultado NUMBER;
	vResto 		 NUMBER;
BEGIN
	vResultado := vNumber1 / 3;
	vResto := MOD(vNumber1, 3);
	IF(vResto = 0) THEN
		dbms_output.PUT_LINE('O resto da divisão = 0.');
	ELSE
		dbms_output.PUT_LINE('O resto da divisão != 0.');
	END IF;
	dbms_output.PUT_LINE('Resultado do cálculo: ' || vResultado);
END;

-- EXEMPLO IF - ELSIF - ELSE (Exemplo calculadora)
DECLARE
	vNumber1   NUMBER DEFAULT &vNumber1;
	vNumber2   NUMBER DEFAULT &vNumber2;
	vResultado NUMBER;
	vOperador  CHAR(1) DEFAULT '&vOperador';
	vImpressao VARCHAR2(100);
BEGIN
	IF(vOperador = '+') THEN
		vResultado := vNumber1 + vNumber2;
		vImpressao := vNumber1 || '+' || vNumber2 || '=' || vResultado || '.';
	ELSIF(vOperador = '-') THEN
		IF(vNumber1 > vNumber2) THEN
			vResultado := vNumber1 - vNumber2;
			vImpressao := vNumber1 || '-' || vNumber2 || '=' || vResultado || '.';
		ELSE
			vResultado := vNumber2 - vNumber1;
			vImpressao := vNumber2 || '-' || vNumber1 || '=' || vResultado || '.';
		END IF;
	ELSIF(vOperador = '*') THEN
		vResultado := vNumber1 * vNumber2;
		vImpressao := vNumber1 || '*' || vNumber2 || '=' || vResultado || '.';
	ELSIF(vOperador = '/') THEN
		vResultado := vNumber1 / vNumber2;
		vImpressao := vNumber1 || '/' || vNumber2 || '=' || vResultado || '.';
	END IF;
	
	dbms_output.PUT_LINE(vImpressao);
	
	EXCEPTION 
		WHEN ZERO_DIVIDE THEN
			dbms_output.PUT_LINE('Não é permitido divisão por 0.');
		WHEN OTHERS THEN
			dbms_output.PUT_LINE('Erro ao efetuar cálculo: ' || SQLERRM);
END;
-------------------------------------------------------------------------------------------------------------------------------------

/* ESTRUTURAS DE REPETIÇÃO são utilizadas quando é necessário que determinada tarefa seja executada repetidas vezes, até que se atenda
   determinada condição ou que não seja mais necessário, como por exemplo percorrer uma tabela inteira. 
*/

-- FOR LOOP: Executa uma tarefa várias vezes até que a condição PREDEFINIDA seja satisfeita OU sua execução seja interrompida.
BEGIN
	FOR i IN 1..10 LOOP
		FOR j IN 1..10 LOOP
			dbms_output.PUT(i || '*' || j || '=' || (i*j) || ' | ');
		END LOOP;
		dbms_output.NEW_LINE;
	END LOOP;
END;

-- É possível alterar a ordem de execução de um LOOP a partir do comando REVERSE
BEGIN
	FOR i IN REVERSE 1..10 LOOP
		FOR j IN REVERSE 1..10 LOOP
			dbms_output.PUT(i || '*' || j || '=' || (i*j) || ' | ');
		END LOOP;
		dbms_output.NEW_LINE;
	END LOOP;
END;

-- Imprimindo apenas números pares
BEGIN
	FOR i IN 1..50 LOOP
		IF(MOD(i,2) = 0) THEN
			dbms_output.PUT(i);
			IF(i < 50) THEN
				dbms_output.PUT(',');
			END IF;
		END IF;
	END LOOP;
	dbms_output.NEW_LINE;
END;

-- É possível delimitar os valores do intervalo do LOOP FOR, substituíndo-os por variáveis.
DECLARE
	vNumero1  NUMBER := &vNumero1;
	vNumero2  NUMBER := &vNumero2;
  vContador NUMBER DEFAULT 1;
BEGIN
	FOR i IN vNumero1..vNumero2 LOOP
		IF(MOD(i,2) = 0) THEN
			dbms_output.PUT(i);
			IF(i < vNumero2) THEN
				dbms_output.PUT(',');
			END IF;
      vContador := vContador +1;
      IF(vContador = 20) THEN
        vContador := 1;
        dbms_output.NEW_LINE;
      END IF;  
		END IF;
	END LOOP;
  dbms_output.NEW_LINE;
END;

-- WHILE LOOP: Entra no loop apenas se a condição para isso for satisfatória
DECLARE
	vLabel        VARCHAR(100) DEFAULT '&vLabel';
	vContador     NUMBER DEFAULT 1;
  vTamanhoLabel NUMBER;
BEGIN
	vTamanhoLabel := LENGTH(vLabel);
	WHILE(vContador <= vTamanhoLabel) LOOP
		dbms_output.PUT(SUBSTR(vLabel, vContador, 1));
		vContador := vContador +1;
	END LOOP;
	dbms_output.NEW_LINE;
END;

-- LOOP: Efetua repetições como os demais, porém, não utiliza um contador predefinido ou uma condição para sua execução
-- Para sair desse loop é necessário utilizar os comandos EXIT ou EXIT WHEN.
DECLARE
	vLabel 			  VARCHAR2(100) DEFAULT '&vLabel';
	vTamanhoLabel NUMBER;
	vContador     NUMBER DEFAULT 1;
BEGIN
  -- Exemplo utilizando o EXIT
	vTamanhoLabel := LENGTH(vLabel);
	LOOP
		IF(vContador > 5) THEN
			EXIT;
		END IF;
		dbms_output.PUT(SUBSTR(vLabel, vContador, 1));
		vContador := vContador + 1;
	END LOOP;
	dbms_output.NEW_LINE;
END;

DECLARE
	vLabel 			  VARCHAR2(100) DEFAULT '&vLabel';
	vTamanhoLabel NUMBER;
	vContador     NUMBER DEFAULT 1;
BEGIN
  -- Exemplo utilizando o EXIT WHEN
	vTamanhoLabel := LENGTH(vLabel);
	LOOP
		EXIT WHEN vContador > vTamanhoLabel;
		dbms_output.PUT(SUBSTR(vLabel, vContador, 1));
		vContador := vContador + 1;
	END LOOP;
	dbms_output.NEW_LINE;
END;
--------------------------------------------------------------------------------------------------------------------------------

/* CURSOR é um comando que permite a construção de uma uma estrutura de repetição, permitindo varrer completamente uma tabela, linhas e colunas.
   - Um cursor basicamente armazena em memória os registros recuperados em um SELECT e estes são manipulados e inseridos em uma ou mais tabelas.
	 - Cursores devem ter a mesma estrutura dos dados da tabela que se deseja manipular e deverá existir uma variável auxiliar, que efetuará de fato a manipulação desses registros.
*/
DECLARE
	CURSOR c1 IS
		SELECT employee_id, first_name, salary, department_id
		  FROM employees;
	r1 c1%ROWTYPE;
BEGIN
 /* **Observação importante sobre o comando FETCH.
      Ao abrir um cursor, ele automaticamente aponta para o primeiro registro do SELECT utilizado em sua definição.
			Porém, o cursor por si só não retorna os dados, necessitando utilizar o FETCH, que recupera este primeiro registro.
			Como o FETCH recupera APENAS UMA LINHA, é necessário utilizar o LOOP, que irá repetir o comando FETCH até que ele percorra
			todos os registros existentes no cursor e não encontre mais registros para recuperar.
	*/
	OPEN c1;
		LOOP
			FETCH c1 INTO r1;
			EXIT WHEN c1%NOTFOUND;
			dbms_output.PUT_LINE('ID: ' || r1.employee_id || ' - ' || r1.first_name || ', salary: ' || r1.salary || ', department: ' || r1.department_id);
		END LOOP;
	CLOSE c1;
	EXCEPTION
		WHEN OTHERS THEN
			dbms_output.PUT_LINE(SQLERRM);
END;

-- Exemplo passando parâmetros na abertura do cursor
DECLARE
	CURSOR c1(cDepartment_id NUMBER) IS
		SELECT employee_id, first_name, salary, department_id
		  FROM employees
		 WHERE department_id = cDepartment_id;
	r1 c1%ROWTYPE;
BEGIN
	OPEN c1(cDepartment_id => 90);
		LOOP
			FETCH c1 INTO r1;
			EXIT WHEN c1%NOTFOUND;
			dbms_output.PUT_LINE('ID: ' || r1.employee_id || ' - ' || r1.first_name || ', salary: ' || r1.salary || ', department: ' || r1.department_id);
		END LOOP;
	CLOSE c1;
	EXCEPTION
		WHEN OTHERS THEN
			dbms_output.PUT_LINE(SQLERRM);
END;

-- O mais comum para cursores é o laço LOOP, porém, também é possível utilizá-lo com o FOR LOOP.
-- Dessa forma, não é necessário declarar uma variável auxiliar e a abertura e fechamento do cursor são controladas pelo próprio laço.
DECLARE
	CURSOR c1 IS
		SELECT employee_id, first_name, salary, department_id
		  FROM employees
     ORDER BY department_id;
BEGIN
	FOR r1 IN c1 LOOP
		dbms_output.PUT_LINE('ID: ' || r1.employee_id || ' - ' || r1.first_name || ', salary: ' || r1.salary || ', department: ' || r1.department_id);
	END LOOP;
	EXCEPTION 
		WHEN OTHERS THEN
			dbms_output.PUT_LINE(SQLERRM);
END;

-- Quando utilizamos cursores com FOR LOOP, podemos também defini-lo diretamente na execução do SELECT.
-- Podemos também utilizar cursores aninhados.
BEGIN
	FOR r1 IN (
		SELECT employee_id, first_name
			FROM employees
		 WHERE manager_id IS NOT NULL
		 ORDER BY department_id)
  LOOP
		dbms_output.PUT_LINE('Empregado: ' || r1.employee_id || ', name: ' || r1.first_name);
		dbms_output.PUT_LINE('Subordinados:');
		FOR r2 IN (
			SELECT employee_id, first_name, salary, manager_id, department_id 
				FROM employees
			 WHERE manager_id = r1.employee_id
			 ORDER BY department_id) 
		LOOP
			dbms_output.PUT_LINE(r2.employee_id || ', name: ' || r2.first_name || ', salary: ' || r2.salary || ', manager_id: ' || r2.manager_id);
		END LOOP;
		dbms_output.PUT_LINE('---------------------------------------------------------------------');
	END LOOP;
END;

/* O oracle possui cursores implícitos e explícitos. Os cursores implícitos são abertos, manipulados e fechados automaticamente pelo Oracle
   quando executamos queries INSERT, DELETE, UPDATE e SELECT INTO, tendo como peculiaridade verificações no uso do SELECT INTO, pois este pode retornar exceptions
   NO_DATA_FOUND ou TOO_MANY_ROWS. Isso faz com que o cursor execute ações de verificações e quando é sabido que um SELECT INTO retornará apenas uma linha, podemos
   garantir melhor performance ao declarar para esta operação um cursor explícito.

	Os cursores possuem atributos que auxiliam a identificar o resultado de algumas das operações feitas durante a execução de uma operação.
	Cursores implicitos são referenciados pelo nome "sql", enquanto os explícitos são referenciados por seu identificador definido em sua declaração.
*/

-- %FOUND: Indica se as operações INSERT, UPDATE ou DELETE foram executadas com êxito, ou se houve retorno de uma ou mais linhas em um SELECT INTO, para cursores implícitos.
-- Também indica se a última operação realizada pelo FETCH foi concluída com êxito.
DECLARE
	CURSOR c1 IS
		SELECT employee_id, first_name FROM employees
     ORDER BY employee_id;
	r1 c1%ROWTYPE;
BEGIN
	OPEN c1;
		LOOP
			FETCH c1 INTO r1;
			EXIT WHEN c1%NOTFOUND;
			IF(c1%FOUND) THEN
				dbms_output.PUT_LINE(r1.employee_id || ', ' || r1.first_name);
			END IF;
		END LOOP;
	CLOSE c1;
	EXCEPTION 
		WHEN OTHERS THEN
			dbms_output.PUT_LINE(SQLERRM);
END;

-- %NOTFOUND: É o oposto do %FOUND, porém não funciona para SELECT INTO, pois neste caso, oque ocorre é o lançamento da exceção NO_DATA_FOUND.
BEGIN
	UPDATE employees
	   SET first_name = 'Lex'
	 WHERE first_name = 'Paulão';
	 
	IF(sql%NOTFOUND) THEN
		dbms_output.PUT_LINE('Não existe funcionário com este nome');
	ELSE
		dbms_output.PUT_LINE('Nome alterado');
		COMMIT;
	END IF;
	
	EXCEPTION 
		WHEN OTHERS THEN
			dbms_output.PUT_LINE(SQLERRM);
END;

-- %ROWCOUNT: Retorna o número de linhas afetadas por uma das operações INSERT, DELETE, UPDATE ou SELECT INTO
DECLARE
	vLinhasAfetadas NUMBER;
BEGIN	
	UPDATE employees
		 SET salary = 10000
	 WHERE department_id = 90;
	 
	vLinhasAfetadas := sql%ROWSCOUNT;
	IF(vLinhasAfetadas > 0) THEN
		COMMIT;
	END IF;
	dbms_output.PUT_LINE('Registros afetados: ' || vLinhasAfetadas);
END;

-- É possível bloquear as linhas da tabela utilizando o FOR UPDATE em um cursor, impedindo que outras sessões manipulem os dados.
-- Após um COMMIT ou ROLLBACK as linhas serão liberadas para outras sessões manipulá-las.
DECLARE
	CURSOR c1(cDepartment_id NUMBER) IS
		SELECT e.employee_id, e.first_name, e.department_id, d.department_name
			FROM employees e, departments d
		 WHERE e.department_id = d.department_id
       AND e.department_id = cDepartment_id
		FOR UPDATE;
	r1 c1%ROWTYPE;
BEGIN
	OPEN c1(cDepartment_id => 90);
		LOOP
			FETCH c1 INTO r1;
			EXIT WHEN c1%NOTFOUND;
			dbms_output.PUT_LINE(r1.employee_id || ', ' || r1.first_name || ', ' || r1.department_name);
		END LOOP;
	CLOSE c1;
END;

-- Com o FOR UPDATE que possui mais de uma tabela, é possível definir quais tabelas se quer bloquear, especificando um campo para bloqueio.
-- No exemplo abaixo as duas tabelas estão sendo bloqueadas, neste caso, não é necessário especificar colunas para o bloqueio, pois todas as tabelas serão lockadas.
-- Se o objetivo for bloquear apenas uma tabela, é necessário especificar na cláusula OF o nome da coluna referente àquela tabela no SELECT.
DECLARE
	CURSOR c1(cDepartment_id NUMBER) IS
		SELECT e.employee_id, e.first_name, d.department_id, d.department_name
			FROM employees e, departments d
		 WHERE e.department_id = d.department_id
		   AND e.department_id = cDepartment_id
		FOR UPDATE OF e.employee_id, d.department_id;
	r1 c1%ROWTYPE;
BEGIN
	OPEN c1(cDepartment_id => 90);
		IF(c1%ISOPEN) THEN
			LOOP
				FETCH c1 INTO r1;
				EXIT WHEN c1%NOTFOUND;
				dbms_output.PUT_LINE(r1.employee_id || ', ' || r1.first_name || ', ' || r1.department_name);
			END LOOP;
		ELSE
			RAISE_APPLICATION_ERROR(-20001, 'Cursor não está aberto.');
		END IF;
	CLOSE c1;
END;

-- Quando se utiliza o FOR UPDATE, pode ser que alguma das tabelas que se quer trabalhar já estejam lockadas por outra sessão. Caso isso ocorra,
-- a sessão atual ficará aguardando a liberação do recurso para ser executada. Para evitar que a sessão fique esperando a liberação do recurso, é possível
-- utilizar a cláusula NOWAIT. Essa opção fará com que uma exceção seja lançada, informando que o recurso está em uso e deverá ser aguardado.
DECLARE
	CURSOR c1(cDepartment_id NUMBER) IS
		SELECT e.employee_id, e.first_name, d.department_id, d.department_name
			FROM employees e, departments d
		 WHERE e.department_id = d.department_id
		   AND e.department_id = cDepartment_id
		FOR UPDATE OF e.employee_id, d.department_id NOWAIT;
	r1 c1%ROWTYPE;
BEGIN
	OPEN c1(cDepartment_id => 90);
		IF(c1%ISOPEN) THEN
			LOOP
				FETCH c1 INTO r1;
				EXIT WHEN c1%NOTFOUND;
				dbms_output.PUT_LINE(r1.employee_id || ', ' || r1.first_name || ', ' || r1.department_name);
			END LOOP;
		ELSE
			RAISE_APPLICATION_ERROR(-20001, 'Cursor não está aberto.');
		END IF;
	CLOSE c1;
END;

-- Ao utilizar o FOR UPDATE, é possível utilizar o CURRENT OF, na cláusula WHERE. Essa opção utiliza o ROWID dos registros, contidos no cursor, garantindo performance.
-- Caso tenha mais de uma tabela na consulta, é necessário, obrigatoriamente, especificar as colunas no FOR UPDATE OF. 
-- Este recurso não funcionará caso utilize colunas de mais de uma tabela na cláusula OF, pois a consulta por ROWID é feita apenas em uma tabela. Portanto, deve-se utilizar apenas para uma tabela travada na cláusula OF.
-- Caso utilize dessa forma, o oracle não apresentará problemas, porém não executará qualquer alteração.;
DECLARE
	CURSOR c1 (cDepartment_id NUMBER) IS
		SELECT *
			FROM employees 
		 WHERE department_id = cDepartment_id
	  FOR UPDATE OF salary NOWAIT;
	r1 c1%ROWTYPE;
  registrosAfetados NUMBER DEFAULT 0;
BEGIN
	OPEN c1(cDepartment_id => 90);
		LOOP
			FETCH c1 INTO r1;
			EXIT WHEN c1%NOTFOUND;
			BEGIN
				UPDATE employees 
        SET    salary = 12000
				WHERE  CURRENT OF c1; 
        
        registrosAfetados := registrosAfetados + sql%ROWCOUNT;
        
				EXCEPTION 
					WHEN OTHERS THEN
            ROLLBACK;
						RAISE_APPLICATION_ERROR(-20001, 'Erro ao atualizar registro dos funcionários.');
			END;
		END LOOP;
    COMMIT;
    dbms_output.PUT_LINE(registrosAfetados || ' registros afetados.');
	CLOSE c1;
END;
-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- FUNÇÕES DE CONVERSÃO DE TEXTO

-- As funções INITCAP, LOWER E UPPER alteram o tamanho dos caracteres de um texto passado como parâmetro.
DECLARE
	vNome1 VARCHAR2(100) DEFAULT 'analista de sistemas';
	vNome2 VARCHAR2(100) DEFAULT 'PEDREIRO';
	vNome3 VARCHAR2(100) DEFAULT 'padeiro';
BEGIN
	dbms_output.PUT_LINE(INITCAP(vNome1));
	dbms_output.PUT_LINE(LOWER(vNome2));
	dbms_output.PUT_LINE(UPPER(vNome3));
END;

-- SUBSTR recupera parte do texto, recebendo como parâmetro o texto, o caractere de início e a quantidade de caracteres que serão retornados.
BEGIN
	FOR r1 IN (SELECT country_name FROM countries) LOOP
		dbms_output.PUT_LINE(r1.country_name || ' - ' || UPPER(SUBSTR(r1.country_name, 1, 2)));
	END LOOP;
END;

-- TO_CHAR converte um valor passado como parâmetro para texto, baseando-se em uma máscara passada como parâmetro.
DECLARE
	vSalary VARCHAR2(20);
BEGIN
	FOR r1 IN (SELECT first_name, salarY FROM employees WHERE commission_pct IS NOT NULL) LOOP
		vSalary := 'R$ ' || TO_CHAR(r1.salary, 'FM999G999D99');
		dbms_output.PUT_LINE(RPAD(r1.first_name, 10, ' ') || ' - ' || vSalary);
	END LOOP;
END;

-- INSTR  recupera a posição da primeira ocorrência encontrada do valor passado como parâmetro.
-- LENGTH recupera o tamanho de uma cadeia de caracteres.
DECLARE
	vNome VARCHAR(100) DEFAULT 'Paulo de Tarso Alves Nogueira';
BEGIN
	dbms_output.PUT_LINE('Tamanho do texto: ' || LENGTH(vNome));
	dbms_output.PUT_LINE('Posição do primeiro espaço: ' || INSTR(vNome, ' '));
	dbms_output.PUT_LINE('Posição do último espaço: ' || INSTR(vNome, ' ', -1));
END;
---------------------------------------

-- FUNÇÕES DE CÁLCULO

-- ROUND arredonda um valor baseando-se na regra matemática, passa-se as casass decimais.
-- FLOOR retorna o menor inteiro, menor ou igual ao valor, ou seja, arredonda pra baixo.
-- CEIL  retorna o menor inteiro, maior ou igual ao valor, ou seja, arredonda pra cima.
-- TRUNC retorna o valor inteiro original, sem arredondamento, desconsiderando casas decimais.
-- ABS   retorna o valor absoluto
-- SQRT  retorna a raiz quadrada
-- POWER retorna a potencialização de dois números, recebendo o valor e a base
-- SIGN retorna +1 se o valor for maior que 0, -1 se for menor e 0 se for igual. Recebe dois valores
DECLARE
	vNumero1 NUMBER(10,2) DEFAULT -5.5;
	vNumero2 NUMBER(10,2) DEFAULT -5.49;
	vNumero3 NUMBER(10,2) DEFAULT -5.51;
BEGIN
	dbms_output.PUT_LINE('Valor arredondado com ROUND: ' || ROUND(vNumero1,2) || ', ' || ROUND(vNumero2,2) || ', ' || ROUND(vNumero3,2));
	dbms_output.PUT_LINE('Valor arredondado com FLOOR: ' || FLOOR(vNumero1) || ', ' || FLOOR(vNumero2) || ', ' || FLOOR(vNumero3));
	dbms_output.PUT_LINE('Valor arredondado com CEIL: ' || CEIL(vNumero1) || ', ' || CEIL(vNumero2) || ', ' || CEIL(vNumero3));
	dbms_output.PUT_LINE('Valor truncado: ' || TRUNC(vNumero1) || ', ' || TRUNC(vNumero2) || ', ' || TRUNC(vNumero3));
	dbms_output.PUT_LINE('Valor absoluto: ' || ABS(vNumero1) || ', ' || ABS(vNumero2) || ', ' || ABS(vNumero3));
	dbms_output.PUT_LINE('Raiz Quadrada de 100: ' || SQRT(100));
	dbms_output.PUT_LINE('10 elevado a 3: ' || POWER(10,3));
	dbms_output.PUT_LINE('SIGN: ' || SIGN(-50));
END;
---------------------------------------

/* FUNÇÕES DE AGREGAÇÃO
	 Algumas regras devem ser seguidas:
	 - Todas as colunas envolvidas em select com agrupamento que não são funções de grupo devem ser adicionadas na cláusula GROUP BY. 
	 - Funções de agrupamento ignoram valores NULOS, portanto, é boa prática utilizar o NVL para substituir valores NULOS por 0.
*/
DECLARE
	vMedia VARCHAR2(20);
  vSoma  VARCHAR2(20);
	CURSOR c1 IS 
		SELECT 
			d.department_id, d.department_name,
		SUM(NVL(salary, 0)) soma_salario,
		AVG(NVL(salary, 0)) media_salario
	FROM 	employees e, departments d
	WHERE e.department_id = d.department_id
	GROUP BY d.department_id, d.department_name;
BEGIN
	FOR r1 IN c1 LOOP
    vSoma  := 'R$ ' || TO_CHAR(r1.soma_salario,  'FM999G999G999D00');
    vMedia := 'R$ ' || TO_CHAR(r1.media_salario, 'FM999G999G999D00');
		dbms_output.PUT_LINE(UPPER(r1.department_name) || ', sum: ' || vSoma || ', avg: ' || vMedia);
	END LOOP;
END;

-- COUNT retorna a contagem de valores
BEGIN
	FOR r1 IN (
		SELECT 
			e.department_id, d.department_name,
			COUNT(e.employee_id) qtde_func
		FROM  employees e, departments d
		WHERE e.department_id = d.department_id
		GROUP BY e.department_id, d.department_name
    ORDER BY e.department_id)
	LOOP	
		dbms_output.PUT_LINE(UPPER(r1.department_name) || ', Func: ' || r1.qtde);
	END LOOP;							
END;

BEGIN 
	FOR r1 IN (
		SELECT COUNT(e.employee_id) qtde, c.country_name
		FROM  employees e, departments d, locations l, countries c
		WHERE e.department_id = d.department_id
		AND   d.location_id   = l.location_id
		AND   l.country_id    = c.country_id
		GROUP BY c.country_name
		ORDER BY c.country_name)
	LOOP
		dbms_output.PUT_LINE(UPPER(r1.country_name) || ', func: ' || r1.qtde);
	END LOOP;
END;

-- MAX retorna o maior valor com base em um campo especificado
-- MIN retorna o menor valor com base em um campo especificado
-- AVG retorna a média
-- SUM retorna a soma
BEGIN
	FOR r1 IN(
		SELECT 
			e.department_id, d.department_name,
			COUNT(e.employee_id)  qtde_func,
			SUM(NVL(e.salary, 0)) sum_salary,
			AVG(NVL(e.salary, 0)) avg_salary,
			MAX(e.hire_date) max_hire_date,
			MIN(e.hire_date) min_hire_date
		 FROM employees e, departments d
		WHERE e.department_id = d.department_id
		GROUP BY e.department_id, d.department_name
		ORDER BY e.department_id)
	LOOP
		dbms_output.PUT_LINE(
			UPPER(r1.department_name) || ' - Func: ' || r1.qtde_func
			|| ', sum: ' || r1.sum_salary
		  || ', avg: ' || r1.avg_salary
			|| ', max: ' || r1.max_hire_date
			|| ', min: ' || r1.min_hire_date
		);
	END LOOP;
END;

-- A cláusula WHERE não permite utilizar funções de grupo para restringir os valores agrupados.
-- Quando trabalhamos com GROUP BY, é possível realizar esse filtro utilizando a cláusula HAVING.
BEGIN
	FOR r1 IN (
		SELECT d.department_name, COUNT(e.employee_id) qtde
			FROM employees e, departments d
		 WHERE e.department_id (+) = d.department_id
		 GROUP BY d.department_name
		 HAVING SUM(NVL(e.salary,0)) > 20000
        AND COUNT(e.employee_id) > 30
		 ORDER BY d.department_name)
  LOOP
		dbms_output.PUT_LINE(UPPER(r1.department_name) || ' - Func: ' || r1.qtde);
	END LOOP;
END;
---------------------------------------------------

-- FUNÇÕES PARA DATAS

SELECT SYSDATE FROM dual; -- SYSDATE retorna a data e hora atual de acordo com o servidor do banco de dados
SELECT CURRENT_DATE FROM dual; -- CURRENT_DATE retorna a data e hora atual de acordo com a zona do tempo da sessão do usuário logado
SELECT ADD_MONTHS(SYSDATE, 12) FROM dual; -- Adiciona meses à uma data
SELECT TRUNC(MONTHS_BETWEEN(SYSDATE, '15/01/2021')) FROM dual; -- Diferença de meses entre duas datas
SELECT NEXT_DAY(SYSDATE, 'SEXTA FEIRA') FROM dual; -- Próxima data a partir de uma data
SELECT SESSIONTIMEZONE FROM dual;

SELECT TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS') FROM dual;
SELECT TO_CHAR(CURRENT_DATE, 'DD/MM/RRRR HH24:MI:SS') FROM dual;

DECLARE
	vData NUMBER;
	vDiaDaSemana DATE;
	
	CURSOR cDateMonths IS
		SELECT first_name, hire_date
		FROM   employees
		WHERE  TO_CHAR(hire_date, 'MM') = TO_CHAR(SYSDATE, 'MM')
		ORDER  BY hire_date;
	r1 cDateMonths%ROWTYPE;
	
	CURSOR cGeral IS
		SELECT first_name, hire_date
		FROM   employees
		ORDER  BY hire_date;
	r2 cGeral%ROWTYPE;
BEGIN
	OPEN cDateMonths;
		LOOP
			FETCH cDateMonths INTO r1;
			EXIT  WHEN cDateMonths%NOTFOUND;
			vDiaDaSemana := NEXT_DAY(r1.hire_date, 'SEXTA FEIRA');
			dbms_output.PUT_LINE(RPAD(r1.first_name,13, ' ') || ', ' || r1.hire_date || ', ' || vDiaDaSemana);
		END LOOP;
	CLOSE cDateMonths;
	dbms_output.PUT_LINE('-------------------------------------------');
	
	OPEN cGeral;
		LOOP
			FETCH cGeral INTO r2;
			EXIT  WHEN cGeral%NOTFOUND;
			vData := TRUNC(MONTHS_BETWEEN(SYSDATE, r2.hire_date));
		dbms_output.PUT_LINE(RPAD(r2.first_name, 13, ' ') || ', ' || r2.hire_date || ', ' || vData);
		END LOOP;
	CLOSE cGeral;
	
	EXCEPTION
		WHEN OTHERS THEN
			dbms_output.PUT_LINE(SQLERRM);
END;
----

DECLARE
	vData    DATE;
	vNextDay DATE;
	CURSOR c1 IS
		SELECT first_name, hire_date FROM employees
		WHERE  TO_CHAR(hire_date, 'MM') = TO_CHAR(SYSDATE, 'MM')
		ORDER  BY hire_date;
	r1 c1%ROWTYPE;
BEGIN
	OPEN c1;
		LOOP
			FETCH c1 INTO r1;
			EXIT  WHEN c1%NOTFOUND;
			vData := TO_DATE(TO_CHAR(r1.hire_date, 'DD/MM/YYYY HH24:MI:SS'), 'DD/MM/YYYY HH24:MI:SS');
			vNextDay := NEXT_DAY(TO_DATE(TO_CHAR(r1.hire_date, 'DD/MM/YYYY HH24:MI:SS'), 'DD/MM/YYYY HH24:MI:SS'), 'SEXTA FEIRA');
			dbms_output.PUT_LINE(RPAD(r1.first_name, 13, ' ') || ', ' || vData || ', '|| vNextDay);
		END LOOP;
	CLOSE c1;
END;
----
-- ROUND arredonda para a 00:00:00 do dia atual para hora < 12 e para 00:00:00 do próximo dia para hora >=12
-- TRUNC arredonda para 00:00:00 do dia atual
-- ROUND MONTH arredonda a data para o primeiro dia do mês atual, caso dia até 15 e o primeiro dia do próximo mês, caso dia > 15.
-- ROUND YEAR arredonda a data para o primeiro dia do ano, caso mês < 7 e para o primeiro dia do próximo ano, caso mês >=7
-- TRUNC YEAR arredonda a data para o primeiro dia do ano
-- TRUNC MONTH arredonda a data para o primeiro dia do mes
BEGIN
	FOR r1 IN (
		SELECT first_name, hire_date 
		FROM   employees 
		WHERE  TO_CHAR(hire_date, 'MM') = TO_CHAR(SYSDATE, 'MM')
		ORDER BY hire_date)
	LOOP
		dbms_output.PUT_LINE(r1.hire_date || ' - ROUND YEAR: ' || r1.first_name || ', ' || ROUND(r1.hire_date, 'YEAR'));
		dbms_output.PUT_LINE(r1.hire_date || ' - ROUND MONTH: ' || r1.first_name || ', ' || ROUND(r1.hire_date, 'MONTH'));
		dbms_output.PUT_LINE(r1.hire_date || ' - TRUNC YEAR: ' || r1.first_name || ', ' || TRUNC(r1.hire_date, 'YEAR'));
		dbms_output.PUT_LINE(r1.hire_date || ' - TRUNC MONTH: ' || r1.first_name || ', ' || TRUNC(r1.hire_date, 'MONTH'));
	END LOOP;
END;

SELECT 
	ROUND(SYSDATE) round_,
	TRUNC(SYSDATE) trunc_,
	ROUND(SYSDATE, 'YEAR') round_year,
	ROUND(SYSDATE, 'MONTH') round_month,
	TRUNC(SYSDATE, 'YEAR') trunc_year,
	TRUNC(SYSDATE, 'MONTH') trunc_month,
	ROUND(TO_DATE('26/01/2022 11:59:59', 'DD/MM/YYYY HH24:MI:SS')) testa_data,
	ROUND(TO_DATE('26/01/2022 12:00:00', 'DD/MM/YYYY HH24:MI:SS')) testa_data2
FROM dual;

-- Exemplo escrevendo o dia da semana
BEGIN
	FOR r1 IN (
		SELECT first_name, hire_date
		  FROM employees
		 WHERE TO_CHAR(hire_date, 'mm') = TO_CHAR(SYSDATE, 'mm')
		 ORDER BY hire_date)
  LOOP
		dbms_output.PUT_LINE(r1.first_name || ', ' || TO_CHAR(r1.hire_date, 'DD/MM/YYYY') || ', ' || TO_CHAR(r1.hire_date, 'day'));
	END LOOP;
END;

-- Exemplo escrevendo a data por extenso
BEGIN
	FOR r1 IN (
		SELECT first_name, hire_date
		  FROM employees
		 WHERE TO_CHAR(hire_date, 'mm') = TO_CHAR(SYSDATE, 'mm')
		 ORDER BY hire_date)
  LOOP
		dbms_output.PUT_LINE('Belo Horizonte, ' || TO_CHAR(r1.hire_date, 'dd') || ' de ' || INITCAP(TO_CHAR(r1.hire_date, 'FMMONTH')) || ' de ' || TO_CHAR(r1.hire_date, 'yyyy'));
	END LOOP;
END;

BEGIN
	FOR r1 IN (
		SELECT first_name, hire_date
		  FROM employees
		 WHERE TO_CHAR(hire_date, 'mm') = TO_CHAR(SYSDATE, 'mm')
		 ORDER BY hire_date)
  LOOP
		dbms_output.PUT_LINE(TO_CHAR(r1.hire_date, '"Belo Horizonte", dd "de" FMMonth "de" YYYY'));
	END LOOP;
END;

-- ESSA EXPRESSÃO FUNCIONA DE FORMA ISOLADA, MAS NÃO ESTÁ FUNCIONANDO NO BLOCO ANÔNIMO... VERIFICAR DPS.
BEGIN
  FOR r1 IN (
    SELECT 
      COUNT(*) qtde,
      TO_CHAR(hire_date, 'mm') mes
    FROM  employees
    GROUP BY TO_CHAR(hire_date, 'mm')) 
  LOOP
    dbms_output.PUT_LINE('ADMITIDOS: ' || RPAD(r1.qtde, 2, 0) || ', MÊS: ' || r1.mes);
  END LOOP;
END;
---------------------------------------------------

-- FUNÇÕES DE CONVERSÃO
-- Algumas das funções utilizadas para conversão são TO_DATE, TO_CHAR. Ambas já foram utilizadas em exemplos acima.

BEGIN
  -- Exemplo de TO_DATE com formato RR e YY para ano.
	dbms_output.PUT_LINE(TO_CHAR(TRUNC(TO_DATE('260188', 'DDMMYY')), 'DD/MM/YYYY'));
	dbms_output.PUT_LINE(TO_CHAR(TRUNC(TO_DATE('260188', 'DDMMRR')), 'DD/MM/YYYY'));
END;

-- TO_NUMBER converte uma string para number, com base no formato que está especificado no banco de dados ou, quando quiser, seguindo o formato da máscara que deve ser passada no segundo parâmetro.
BEGIN
  dbms_output.PUT_LINE(TO_NUMBER('4.569.900,80', '999G999G999D00'));
END;

-- A função TO_NUMBER por si só não exibe os valores formatados em tela. Para isso é necessário utilizar o TO_CHAR.
-- É possível perceber a diferença na apresentação dos valores deste bloco para o anterior.
BEGIN
  dbms_output.PUT_LINE(TO_CHAR(TO_NUMBER('4.569.900,80', '999G999G999D00'), '999G999G999D00'));
END;

-- Exemplo convertendo o valor do salário para monetário
BEGIN
	FOR r1 IN(
		SELECT first_name, NVL(salary, 0) salary
		  FROM employees
		 WHERE TO_CHAR(hire_date, 'mm') = TO_CHAR(SYSDATE, 'mm')
		 ORDER BY salary)
  LOOP
		dbms_output.PUT_LINE(r1.first_name || ', R$ ' || TO_CHAR(r1.salary, 'fm999G999G999D00'));
	END LOOP;
END;
----------------------------------------------------

-- FUNÇÕES CONDICIONAIS 
-- São  utilizadas para decidir qual valor será exibido em uma coluna ou variável, mediante um teste condicional.

-- CASE permite uma funcionalidade similar a um IF-ELSE, porém, dentro de um comando SELECT
DECLARE
	CURSOR c1 IS
		SELECT 
			job_id,
			SUM(CASE 
						WHEN department_id = 10 THEN 
							salary
						ELSE 0
					END
			) department_10,
			SUM(CASE 	
						WHEN department_id = 20 THEN
							salary
						ELSE 0
					END
			) department_20,
			SUM(CASE 
						WHEN department_id = 30 THEN
							salary
						ELSE 0
					END
			) department_30,
			SUM(salary) total
		 FROM employees
    WHERE salary BETWEEN 3000 AND 10000
		GROUP BY job_id;
	r1 c1%ROWTYPE;
BEGIN
	OPEN c1;
		LOOP
			FETCH c1 INTO r1;
			EXIT WHEN c1%NOTFOUND;
			dbms_output.PUT_LINE(r1.job_id || ': 10 - ' || r1.department_10 || ', 20 - ' || r1.department_20 || ', 30 - ' || r1.department_30 || ', total - ' || r1.total);
		END LOOP;
	CLOSE c1;
END;

-- Segunda forma de utilizar o CASE WHEN
DECLARE
	CURSOR c1 IS 
		SELECT 
			first_name, TO_CHAR(hire_date, 'yyyy') ano,
			CASE
				WHEN TO_CHAR(hire_date, 'yyyy') = 2004 THEN 'Fundador'
				WHEN TO_CHAR(hire_date, 'yyyy') = 2005 THEN 'Primeiros funcionários'
				WHEN TO_CHAR(hire_date, 'yyyy') = 2006 THEN 'Segunda leva'
			ELSE
				'Novos contratos'
			END tipo
		FROM  employees 
		WHERE TO_CHAR(hire_date, 'mm') = TO_CHAR(SYSDATE, 'mm') 
		ORDER BY ano;
BEGIN
	FOR r1 IN c1 LOOP
		dbms_output.PUT_LINE(r1.first_name || ', ' || r1.ano || ', ' || r1.tipo);
	END LOOP;
END;

-- DECODE funciona de forma similar ao CASE, porém é menos intuitivo
DECLARE
	CURSOR c1 IS
		SELECT 
			job_id,
			SUM(DECODE(department_id, 10, salary, 0)) department_10,
			SUM(DECODE(department_id, 20, salary, 0)) department_20,
			SUM(DECODE(department_id, 30, salary, 0)) department_30,
			SUM(salary) total
		FROM  employees
		WHERE salary BETWEEN 3000 AND 10000
		GROUP BY job_id;
BEGIN
	FOR r1 IN c1 LOOP
		dbms_output.PUT_LINE(r1.job_id || ': 10 - ' || r1.department_10 || ', 20 - ' || r1.department_20 || ', 30 - ' || r1.department_30 || ', total - ' || r1.total);
	END LOOP;
END;

-- Segunda forma de usar o DECODE
DECLARE
	CURSOR c1 IS 
		SELECT 
			first_name, TO_CHAR(hire_date, 'yyyy') ano,
			DECODE(
				TO_CHAR(hire_date, 'yyyy'), 
				  2001, 'Fundador',
				  2004, 'Primeiras contratações',
				  2005, 'Segunda leva'
						  , 'Novos funcionários'
		  ) tipo					
		FROM  employees 
		WHERE TO_CHAR(hire_date, 'mm') = TO_CHAR(SYSDATE, 'mm') 
		ORDER BY ano;
BEGIN
	FOR r1 IN c1 LOOP
		dbms_output.PUT_LINE(r1.first_name || ', ' || r1.ano || ', ' || r1.tipo);
	END LOOP;
END;

-- NVL recebe dois parâmetros. Se o primeiro for nulo, retorna o segundo, caso contrário retorna o primeiro
DECLARE
	vSumCommission1 NUMBER;
	vSumCommission2 NUMBER;
	vSumCommission3 NUMBER;
BEGIN	
	SELECT SUM(salary + commission_pct) INTO vSumCommission1 FROM employees;
	SELECT SUM(salary + NVL(commission_pct, 0)) INTO vSumCommission2 FROM employees;
	SELECT SUM(NVL(salary, 0) + NVL(commission_pct, 0)) INTO vSumCommission3 FROM employees;
	
	dbms_output.PUT_LINE(vSumCommission1);
	dbms_output.PUT_LINE(vSumCommission2);
	dbms_output.PUT_LINE(vSumCommission3);
END;

-- GREATEST e LEAST retornam o maior e menor valor dentro de um conjunto de dados passados como parâmetro
DECLARE
	vMaiorLetra VARCHAR2(1);
	vMenorLetra VARCHAR2(1);
BEGIN
	SELECT GREATEST('A', 'b', 'c', 'z', 'Y', 'w', 'x') INTO vMaiorLetra FROM dual;
	SELECT LEAST('A', 'b', 'c', 'z', 'Y', 'w', 'x') INTO vMenorLetra FROM dual;
	
	dbms_output.PUT_LINE('Maior: ' || vMaiorLetra);
	dbms_output.PUT_LINE('Menor: ' || vMenorLetra);
END;

-- NULLIF retorna NULL caso os dois parâmetros sejam iguais e caso sejam direrentes, retorna o primeiro parâmetro
DECLARE
	vComparacao1 VARCHAR2(20);
	vComparacao2 VARCHAR2(20);
BEGIN
	SELECT DECODE(NULLIF('Abacaxi', 'Abacaxi'), NULL, 'Iguais', 'Diferentes') INTO vComparacao1 FROM dual;
	SELECT DECODE(NULLIF('abacaxi', 'Abacaxi'), NULL, 'Iguais', 'Diferentes') INTO vComparacao2 FROM dual;
	
	dbms_output.PUT_LINE('Comparação 1: ' || vcomparacao1);
	dbms_output.PUT_LINE('Comparação 2: ' || vComparacao2); 
END;
-------------------------------------------------------------------------

-- PROGRAMAS ARMAZENADOS
-- Podem ser procedures, functions triggers ou packages. A sua utilização fornece ganhos em rapidez, modularização e reutilização de código.
-- PROCEDURES e FUNCTIONS criadas dentro de BLOCOS ANÔNIMOS ou dentro de outras procedures e functions, não são precedidas do comando CREATE e não são armazenadas no banco de dados.
CREATE OR REPLACE PROCEDURE calculadora(vNumber1 NUMBER, pNumber1 NUMBER, vOperador VARCHAR2) IS
BEGIN
	BEGIN
		IF(vOperador = '+') THEN
			vResultado := vNumber1 + vNumber2;
			vImpressao := vNumber1 || '+' || vNumber2 || '=' || vResultado || '.';
		ELSIF(vOperador = '-') THEN
			IF(vNumber1 > vNumber2) THEN
				vResultado := vNumber1 - vNumber2;
				vImpressao := vNumber1 || '-' || vNumber2 || '=' || vResultado || '.';
			ELSE
				vResultado := vNumber2 - vNumber1;
				vImpressao := vNumber2 || '-' || vNumber1 || '=' || vResultado || '.';
			END IF;
		ELSIF(vOperador = '*') THEN
			vResultado := vNumber1 * vNumber2;
			vImpressao := vNumber1 || '*' || vNumber2 || '=' || vResultado || '.';
		ELSIF(vOperador = '/') THEN
			vResultado := vNumber1 / vNumber2;
			vImpressao := vNumber1 || '/' || vNumber2 || '=' || vResultado || '.';
		END IF;
		
		dbms_output.PUT_LINE(vImpressao);
		
		EXCEPTION 
			WHEN ZERO_DIVIDE THEN
				dbms_output.PUT_LINE('Não é permitido divisão por 0.');
			WHEN OTHERS THEN
				dbms_output.PUT_LINE('Erro ao efetuar cálculo: ' || SQLERRM);
	END;
END;

-- Exemplo de criação de função (VERIRICAR DPS)
-- O uso da cláusula REPLACE na criação de procedures e functions é importante pois garante que as permissões de acesso e as dependências com outros objetos sejam mantidas.
-- Caso exclua e crie novamente uma procedure ou function sem esta funcionalidade, será necessário dar todas as permissões à todos os usuários que utilizavam antes. 
CREATE OR REPLACE FUNCTION FNC_CALCULA_COMISSAO (pEmployeeId NUMBER) RETURN NUMBER IS
	vResultado  	 NUMBER DEFAULT 0;
	EMPLOYEE_NOT_FOUND_EXEPTION EXCEPTION;
	CURSOR c1 IS
		SELECT employee_id, salary, NVL(commission_pct, 0) commission
		  FROM employees
		 WHERE employee_id = pEmployeeId;
BEGIN
	BEGIN
		FOR r1 IN c1 LOOP
			IF(r1.employee_id IS NULL) THEN
				RAISE EMPLOYEE_NOT_FOUND_EXCEPTION;
			END IF;
			vResultado := r1.salary * r1.commission;
		END LOOP;
		
		RETURN vResultado;
	END;
	
	EXCEPTION 
		WHEN EMPLOYEE_NOT_FOUND_EXCEPTION THEN
			dbms_output.PUT_LINE('Funcionário de ID ' || pEmployeeId || ' não existe.');
		WHEN OTHERS THEN
			dbms_output.PUT_LINE('Erro ao calcular comissão para funcionário de ID ' || pEmployeeId || ': ' || SQLERRM);
END; 

-- Concedendo permissão para executar procedures e funções
GRANT EXECUTE ON PRC_CALCULADORA TO PUBLIC; -- Permissão global
GRANT EXECUTE ON FNC_CALCULA_COMISSAO TO TSQL; -- Permissão para usuário específico

-- Ao alterar um programa armazenado, as vezes pode ser necessário recompilá-lo.
ALTER PROCEDURE PRC_CALCULADORA COMPILE;
ALTER FUNCTION FNC_CALCULA_COMISSAO COMPILE;

-- É possível visualizar informações de um programa armazenado a partir do dicionário de dados Oracle ou através do DESCRIBE;
DESC PRC_CALCULADORA;
DESC FNC_CALCULA_COMISSAO;

-- Também é possível visualizar o código de um programa armazenado através das views USER_SOURCE, ALL_SOURCE ou DBA_SOURCE
COLUMN TEXT FORMAT A100;
SET PAGES 1000;
SELECT LINE, TEXT
FROM   ALL_SOURCE  WHERE NAME = 'PRC_CALCULADORA';
-----------

-- Parâmetros do tipo IN  não podem ser alterados, mas podem ser atribuídos à outras variáveis dentro do programa
-- Parâmetros do tipo OUT podem ter seus valores alterados dentro do programa, mas não recebem valores na passagem por parâmetro, pois apenas retornam valores.
-- Parâmetros IN OUT podem ser alterados e atribuídos à outras variáveis.
-- Por padrão, quando declaramos um parâmetro para um programa, ele é classificado como IN.
-- Parâmetros OUT podem ser atribuídos à variáveis que chamam a função ou procedure, podendo ter um ou mais retornos.

-- Exemplo IN, OUT, IN OUT
-- Vale observar que nesse exemplo, apesar de utilizar PROCEDURE, é obtido o retorno de dois valores, atribuídos às variáveis previamente definidas, passadas como parâmetro para a procedure.
DECLARE
  retorno1 VARCHAR2(10);
  retorno2 VARCHAR2(10);
	PROCEDURE prc_teste(param1 IN VARCHAR2, param2 IN OUT VARCHAR2, param3 IN OUT VARCHAR2) IS
		var1 VARCHAR2(10);
		var2 VARCHAR2(10);
		var3 VARCHAR2(10);
	BEGIN
	    var1 := param1;
		--param1 := 'Texto'; -- Inválido. Parâmetro IN não pode ser alterado
		
		param2 := 'Texto';
		  var2 := param2 || 'TESTE';
      dbms_output.PUT_LINE('VAR2: ' || var2);
		param3 := 'Text5';
		  var3 := param3 || 'TESTE';
      dbms_output.PUT_LINE('VAR3: ' || var3);
	END;
BEGIN
   prc_teste('Texto1', retorno1, retorno2);
   dbms_output.PUT_LINE(retorno1);
   dbms_output.PUT_LINE(retorno2);
END;

-- Para verificar as dependências entre os objetos de bancos de dados, utiliza-se a view ALL_DEPENDENCIES;
-- As dependências não são apenas entre procedures. Quando criamos um objeto no banco de dados, ele cria dependências com vários outros objetos necessários.
-- Quando criamos objetos cujas dependências (outros objetos) não foram criados, ou seja, fora da ordem, este fica invalidado.
-- Recompilar um objeto pode fazer com que ele seja validado.
SELECT name || ' -> ' || referenced_name || ' -> ' || referenced_type referencias
  FROM all_dependencies
 WHERE owner = 'HR'
   AND referenced_type = 'PROCEDURE'
 ORDER BY name;
----------------------------------------------------------------------------------------------

/* PACKAGES 
   - São utilizados para agrupamento de programas armazenados como procedures e functions
   - Podem ser utilizados como repositórios de códigos PL/SQL, declarações de variáveis e tipos de dados
	 - São utilizados como especificações de um package body
	 - É como se fosse uma interface. Os objetos criados em um package especification são visíveis para a implementação (body), enquanto os objetos
	   criados dentro de um package body não podem acessar diretamente os objetos criados em um especification
	 
	  ** Para recompilar, visualizar informações, erros e códigos de PACKAGES, utiliza-se os mesmos procedimentos realizados para PROCEDURES e FUNCTIONS
 */

CREATE OR REPLACE PACKAGE listagem IS
	CURSOR c1 IS
		SELECT 
			d.department_id,
			d.department_name,
			e.first_name,
			e.hire_date,
			e.salary
		FROM  departments d, employees e
		WHERE d.manager_id = e.employee_id
		ORDER BY d.department_name;
	
	TYPE tbGerenteType IS TABLE OF c1%ROWTYPE INDEX BY BINARY_INTEGER;
	tabelaGerente tbGerenteType;
	contador NUMBER;
	
	PROCEDURE prc_lista_gerente_por_depto;
END LISTAGEM;

CREATE OR REPLACE PACKAGE BODY listagem IS
	PROCEDURE prc_lista_gerente_por_depto IS
	BEGIN
		FOR r1 IN c1 LOOP
			tabelaGerente(r1.department_id) := r1;
		END LOOP;
		contador := tabelaGerente.FIRST;
		WHILE contador <= tabelaGerente.LAST LOOP
			dbms_output.PUT_LINE(
				'Dep: ' || tabelaGerente(contador).department_name 
				|| ' Gerente: ' || tabelaGerente(contador).first_name
				|| ' Data Admissão: ' || tabelaGerente(contador).hire_date
				|| ' Salário: R$ ' || TO_CHAR(tabelaGerente(contador).salary, 'FM99G999G990D00')
			);
			contador := tabelaGerente.next(contador);						
		END LOOP;
	END lista_gerente_por_depto;
END listagem;


-- EXEMPLO DE CRIAÇÃO DE PACKAGE PARA CÁLCULOS
CREATE OR REPLACE PACKAGE calculo IS
	FUNCTION somar(number1 NUMBER, number2 NUMBER) RETURN NUMBER;
	FUNCTION subtrair(number1 NUMBER, number2 NUMBER) RETURN NUMBER;
	FUNCTION multiplicar(number1 NUMBER, number2 NUMBER) RETURN NUMBER;
	FUNCTION dividir(number1 NUMBER, number2 NUMBER) RETURN NUMBER;
	FUNCTION exponenciar(number1 NUMBER, number2 NUMBER) RETURN NUMBER;
END calculo;

CREATE OR REPLACE PACKAGE BODY calculo IS
	resultado NUMBER DEFAULT NULL;
	
	PROCEDURE prc_mensagem(mensagem VARCHAR2) IS
	BEGIN
		dbms_output.PUT_LINE(mensagem);
	END prc_mensagem;
	
	FUNCTION somar(number1 NUMBER, number2 NUMBER) RETURN NUMBER IS
	BEGIN
		resultado := number1 + number2;
		prc_mensagem(number1 || ' + ' || number2 || ' = ' || resultado);
    RETURN resultado;
  END somar;
	
	FUNCTION subtrair(number1 NUMBER, number2 NUMBER) RETURN NUMBER IS
	BEGIN
		resultado := number1 - number2;
		IF(resultado < 0) THEN
			prc_mensagem('Resultado negativo : ' || resultado);
		END IF;
		prc_mensagem(number1 || ' - ' || number2 || ' = ' || resultado);
    RETURN resultado;
  END subtrair;
	
	FUNCTION multiplicar(number1 NUMBER, number2 NUMBER) RETURN NUMBER IS
	BEGIN
		resultado := number1 * number2;
		prc_mensagem(number1 || ' * ' || number2 || ' = ' || resultado);
    RETURN resultado;
  END multiplicar;
	
	FUNCTION dividir(number1 NUMBER, number2 NUMBER) RETURN NUMBER IS
	BEGIN
		IF(number2 = 0) THEN
			prc_mensagem('Não é possível dividir por 0.');
			RETURN NULL;
		END IF;
		resultado := number1 / number2;
		prc_mensagem(number1 || ' / ' || number2 || ' = ' || TO_CHAR(resultado, '9G999G990D00'));
    RETURN resultado;
  END dividir;
	
	FUNCTION exponenciar(number1 NUMBER, number2 NUMBER) RETURN NUMBER IS
	BEGIN
		resultado :=POWER(number1, number2);
		prc_mensagem(number1 || ' ^ ' || number2 || ' = ' || TO_CHAR(resultado, '9G999G990D00'));
    RETURN resultado;
  END exponenciar;
END calculo;
----------------------------------------------------------------------------------------

/* TRANSAÇÕES AUTÔNOMAS
	 Ao efetivar um comando de COMMIT ou ROLLBACK, o oracle irá efetivar tudo que estiver pendente na sessão. 
	 Isso significa que, em um programa que possui várias chamadas a comandos DML, ao executar um COMMIT ou ROLLBACK, os dados manipulados por um comando DML executado anteriormente
	 poderão ser efetivados erroneamente, pois o oracle irá efetivar tudo que estiver na sessão.
	 
	 Para evitar isso, as transações autônomas isolam as ações de determinados programas em uma sessão separada.
	 Elas devem ser informadas na declaração dos objetos como PROCEDURES, FUNCTIONS, BLOCOS ANÔNIMOS ou TRIGGERS.
	 Quando ocorre isso, o oracle abre uma nova sessão isolada apenas para executar aquele objeto, assim os COMMIT's e ROLLBACK's não surtirão efeito nos demais objetos. 
*/

-- Exemplo de transação autônoma.
-- Um ponto a se atentar é que SEMPRE que abrir uma transação autônoma, ELA DEVERÁ SER FECHADA. Caso não seja, ficará como uma sessão pendente, ocasionando erros.
DECLARE
	PROCEDURE prc_lista_dept IS
		PRAGMA AUTONOMOUS_TRANSACTION;
	BEGIN
		dbms_output.PUT_LINE('------ Lista departamentos -------');
		FOR i IN (SELECT * FROM departments ORDER BY department_id) LOOP
			dbms_output.PUT_LINE(i.department_id || ' - ' || i.department_name);
		END LOOP;
		COMMIT;
	END prc_lista_dept;
BEGIN
	INSERT INTO departments(department_id, department_name)
		VALUES (272, 'Dept_bixo');
		
	prc_lista_dept;
	prc_lista_dept;
  COMMIT;
  prc_lista_dept;
END;
-- No exemplo acima, a sessão autônoma contida dentro da procedure não foi influenciada pela sessão externa. Os dados contidos no INSERT não foram recuperados pela Sessão. 

-- Outro teste, dessa vez verificando os dados da sessão EXTERNA.
DECLARE
	max_departments_extern NUMBER;
	PROCEDURE prc_lista_dept IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		max_departments_intern NUMBER;
	BEGIN
		SELECT MAX(department_id) INTO max_departments_intern FROM departments;
		dbms_output.PUT_LINE('Max department intern: ' || max_departments_intern);
		COMMIT;
	END prc_lista_dept;
BEGIN
	SELECT MAX(department_id) INTO max_departments_extern FROM departments;
	dbms_output.PUT_LINE('Max department extern: ' || max_departments_extern);
	
	INSERT INTO departments(department_id, department_name)
		VALUES (273, 'Dept_bixo');
	
	SELECT MAX(department_id) INTO max_departments_extern FROM departments;
	dbms_output.PUT_LINE('Max department extern  before COMMIT and procedure: ' || max_departments_extern);
	
	prc_lista_dept;
  COMMIT;
	SELECT MAX(department_id) INTO max_departments_extern FROM departments;
	dbms_output.PUT_LINE('Max department extern  after COMMIT and procedure: ' || max_departments_extern);
	
  prc_lista_dept;
END;

-- Exemplo um pouco maior, interligando várias PROCEDURES
DECLARE
	PROCEDURE prc_lista_countries(execucao NUMBER) IS
	BEGIN	
		dbms_output.PUT_LINE('Executando PRC_LISTA_COUNTRIES ' || execucao);
		FOR r1 IN (
			SELECT country_id, country_name 
			  FROM countries 
			 WHERE region_id = 1
			 ORDER BY country_name DESC)
	  LOOP
			dbms_output.PUT_LINE(r1.country_id || ', ' || r1.country_name);
		END LOOP;
	END prc_lista_countries;
	
	PROCEDURE prc_insere_portugal IS
	  PRAGMA AUTONOMOUS_TRANSACTION;
	BEGIN
		prc_lista_countries(2);
		INSERT INTO countries VALUES ('PT', 'zzzZ', 1);
		COMMIT;
		prc_lista_countries(3);
	END prc_insere_portugal;
	
	PROCEDURE prc_insere_espanha IS
	BEGIN
		INSERT INTO countries VALUES('ES', 'zzz', 1);
		prc_lista_countries(1);
	
		prc_insere_portugal;
		ROLLBACK;
		prc_lista_countries(4);
	END prc_insere_espanha;
BEGIN
	prc_insere_espanha;
END;

DECLARE
	PROCEDURE prc_lista_countries(execucao NUMBER) IS
	BEGIN	
		dbms_output.PUT_LINE('Executando PRC_LISTA_COUNTRIES ' || execucao);
		FOR r1 IN (
			SELECT country_id, country_name 
			  FROM countries 
			 WHERE region_id = 1
			 ORDER BY country_name DESC)
	  LOOP
			dbms_output.PUT_LINE(r1.country_id || ', ' || r1.country_name);
		END LOOP;
	END prc_lista_countries;
BEGIN
	prc_lista_countries(1);
END;
--------------------------------------------------------------------------------------

/* TRIGGERS
	 Uma trigger executará uma ação de acordo com os eventos ocorridos em um banco de dados, INSERT, DELETE, UPDATE, TRUNCATE.
	 Existem triggers de bancos de dados e triggers de sistema. Triggers de bancos de dados são criadas pelo desenvolvedor e disparadas antes ou após um evento.
	 Uma trigger de tabela poderá ser executada uma única vez sempre que um evento for disparado ou uma vez para para cada linha afetada pelo evento.
	 
	 Uma trigger pode ser habilitada ou desabilitada. Quando está desabilitada, não será disparada por nenhum evento, mas continuará salva no banco de dados.
	 ALTER TRIGGER <nomeDaTrigger> ENABLE | DISABLE
	 
	 Também é possível habiiltar e desabilitar todas as triggers de uma tabela específica
	 ALTER TABLE <nomeDaTabela> DISABLE | ENABLE ALL TRIGGERS
	 
	 -- Triggers de linha para AFTER geram erros MUTANT TABLE, pois a execução do gatilho é feito depois da atualização.
*/

-- Trigger de tabela: Irá considerar todos os dados da tabela
CREATE TABLE auditoria_commission_employees(
	nr_registros NUMBER,
	sum_salary   NUMBER,
	sum_commission_paid NUMBER
);
DROP TABLE auditoria_commission_employees;

CREATE OR REPLACE TRIGGER trg_calcula_comissao 
AFTER INSERT OR DELETE OR UPDATE OF salary, commission_pct ON employees
DECLARE
	vNrEmployees    NUMBER DEFAULT 0;
	vSumSalary      NUMBER DEFAULT 0;
	vSumCommission  NUMBER DEFAULT 0;
	vNrRegistrosAud NUMBER DEFAULT 0;
	CURSOR c1 IS 
		SELECT 
			NVL(salary, 0) salary, 
			NVL(commission_pct, 0) commission
		FROM employees;
	r1 c1%ROWTYPE;
BEGIN
	OPEN c1;
		LOOP
			FETCH c1 INTO r1;
			EXIT WHEN c1%NOTFOUND;
			vSumSalary := vSumSalary + r1.salary;
			vSumCommission := vSumCommission + (r1.commission * r1.salary);
		END LOOP;
		vNrEmployees := c1%ROWCOUNT;
	CLOSE c1;
	SELECT COUNT(*) INTO vNrRegistrosAud FROM auditoria_commission_employees;
	
	IF(vNrRegistrosAud = 0) THEN
		INSERT INTO auditoria_commission_employees VALUES (vNrEmployees, vSumSalary, vNrRegistrosAud);
	ELSE 
		UPDATE auditoria_commission_employees 
		SET 
			nr_registros = vNrEmployees,
			sum_salary = vSumSalary,
			sum_commission_paid = vSumCommission;
	END IF;
END trg_calcula_comissao;

-- Trigger de linha: Dispara a trigger para cada linha afetada pelo comando DML.
-- Diferente da trigger de tabela, que atua sobre toda a tabela, independente do número de linhas afetadas, esta trigger irá operar apenas sobre os registros afetados.
CREATE TABLE tb_atualiza_historico_cargos(
	employee_id  NUMBER,
	job_anterior VARCHAR2(10),
	job_novo VARCHAR2(10),
	data_alteracao DATE,
	descricao VARCHAR2(200)
);

CREATE OR REPLACE TRIGGER atualiza_historico_cargos AFTER UPDATE ON employees
REFERENCING 
	OLD AS o 
	NEW AS n 
	FOR EACH ROW
BEGIN
	INSERT INTO tb_atualiza_historico_cargos VALUES(:n.employee_id, :v.job_id, :n.job_id, SYSDATE, 'Alteração de cargo ou função'); 
END;

-- Trigger de linha para alteração de valores antes da efetifação dos dados
-- Essa trigger irá calcular o valor a ser pago como comissão para cada empregado dos cargos de comissão.
-- Como é uma trigger de linha, a execução será feita apenas para as linhas afetadas pelo evento, todas elas.
CREATE OR REPLACE TRIGGER trg_atualiza_comissao
BEFORE INSERT OR UPDATE OF salary, commission_pct ON employees FOR EACH ROW WHEN (new.job_id = 'SA_MAN' OR new.job_id = 'SA_REP')
BEGIN
	:new.commission_paid := NVL(:new.commission_pct, 0) * NVL(:new.salary, 0);
END trg_atualiza_comissao;

-- PREDICADO de trigger, permitem controlar qual é o tipo de evento está sendo executado, insert, delete ou update.
-- Com isso, pode-se decidir qual ação será tomada de acordo com o retorno do predicado.
CREATE TABLE historico_alteracoes_departamentos(
	department_id NUMBER,
	data_historico DATE,
	descricao VARCHAR2(100)
);

CREATE OR REPLACE TRIGGER trg_atualiza_historico_dept 
AFTER INSERT OR DELETE OR UPDATE ON departments FOR EACH ROW
DECLARE
	vAcao VARCHAR2(100);
  vDepartment_id NUMBER DEFAULT :new.department_id;
BEGIN
	IF INSERTING THEN
		vAcao := 'INSERIDO';
	ELSIF DELETING THEN
    vAcao := 'EXCLUÍDO';
		vDepartment_id := :old.department_id;
	ELSIF UPDATING THEN
		vAcao := 'ATUALIZADO';
	END IF;
	
	INSERT INTO historico_alteracoes_departamentos
	VALUES (vDepartment_id, SYSDATE, 'Departamento foi ' || vAcao);
END trg_atualiza_historico_dept;

-- TRIGGER DE VIEW
CREATE VIEW view_employee_department AS
	SELECT e.employee_id, e.first_name, e.job_id, e.salary, d.department_name
	  FROM employees e, departments d
	 WHERE e.department_id = d.department_id
;

CREATE OR REPLACE TRIGGER trg_employee_department_view_manipula
	INSTEAD OF INSERT OR DELETE OR UPDATE ON view_employee_department
	REFERENCING new AS NEW OLD AS old
DECLARE
	CURSOR c1(cDepartment_id departments.department_id%TYPE) IS
		SELECT department_id, department_name
			FROM departments
		 WHERE department_id = vDepartment_id;
  CURSOR c2(cEmployee_id employees.employee_id%TYPE) IS
		SELECT employee_id, first_name
		  FROM employees
		 WHERE employee_id = cEmployee_id;
  vDepartment_id   departments.department_id%TYPE;
	vDepartment_name departments.department_name%TYPE;
  vEmployee_id   employees.employee_id%TYPE;
  vEmployee_name employees.first_name%TYPE; 
BEGIN	
	IF INSERTING THEN
		OPEN c1(:new.department_id);
		FETCH c1 INTO vDepartment_id, vDepartment_name;
		
		IF c1%NOTFOUND THEN
			INSERT INTO departments VALUES (:new.department_id, :new.department_name, NULL, NULL);
			dbms_output.PUT_LINE('Department ' || vDepartment_name || ' created.');
		ELSE
			dbms_output.PUT_LINE('Department ' || vDepartment_name || ' already exists.');
		END IF;
		
		OPEN c2(:new.employee_id);
		FETCH c2 INTO vEmployee_id, vEmployee_name;
		
		IF c2%NOTFOUND THEN
			INSERT INTO employees (employee_id, first_name, last_name, hire_date, job_id, salary, commission_pct) 
			VALUES (:new.employee_id, :new.first_name, :new.last_name, :new.hire_date, :new.job_id, :new.salary, :new.commission_pct);
			dbms_output.PUT_LINE('Employee ' || :new.first_name || ' created.');
		ELSE
			dbms_output.PUT_LINE('Employee ' || :new.first_name || ' already exists.');
		END IF;
	ELSIF UPDATING THEN
		OPEN c1(:new.department_id);
		FETCH c1 INTO vDepartment_id, vDepartment_name;
		
		IF c1%NOTFOUND THEN
			dbms_output.PUT_LINE('Department ' || :new.department_name || ' not exists.');
		ELSE
			UPDATE departments 
				 SET department_name = :new.department_name
			 WHERE department_id = :new.department_id;
			dbms_output.PUT_LINE('Department ' || :new.department_name || ' updated.');
		END IF;
		
		OPEN c2(:new.employee_id);
		FETCH c2 INTO vEmployee_id, vEmployee_name;
		
		IF c2%NOTFOUND THEN
			dbms_output.PUT_LINE('Employee ' || :new.employee_name || ' not exists.');
		ELSE
			UPDATE employees 
				 SET first_name = :new.first_name,
						 last_name  = :new.last_name,
						 hire_date  = :new.hire_date,
						 job_id 		= :new.job_id,
						 salary 		= :new.salary,
						 commission_pct = :new.commission_pct
			 WHERE employee_id = :new.employee_id;
			 dbms_output.PUT_LINE('Employee ' || :new.first_name || ' updated.');
		END IF;
		
	ELSIF DELETING THEN
		OPEN c1(:old.department_id);
		FETCH c1 INTO vDepartment_id, vDepartment_name;
		
		IF c1%NOTFOUND THEN
			DELETE FROM departments WHERE department_id = :old.department_id;
			dbms_output.PUT_LINE('Department ' || :old.department_name || ' deleted.');
		ELSE
			dbms_output.PUT_LINE('Department ' || :old.department_name || ' not exists.');
		END IF;
		
		OPEN c2(:old.employee_id);
		FETCH c2 INTO vEmployee_id, vEmployee_name;
		
		IF c2%NOTFOUND THEN
			DELETE FROM employees WHERE employee_id = :old.employee_id;
			dbms_output.PUT_LINE('Department ' || :old.employee_id || ' deleted.');
		ELSE
			dbms_output.PUT_LINE('Department ' || :old.employee_id || ' not exists.');
		END IF;
	END IF;
	
	CLOSE c2;
	CLOSE c1;
END trg_employee_department_view_manipula;
---------------------------------------------------------------------------------

/* PL/SQL TABLES - TABELAS HOMOGÊNEAS
   São estruturas de vetores tipados de acordo com o tipo de uma coluna de uma tabela específica.
   Como são armazenados em memória, fornecem maior velocidade na consulta dos dados.
   São definidas com o TYPE e só ocupam a memória quando um objeto ou variável deste tipo é de fato instanciado.   
   
   Além dos tipos de colunas, também é possível criar tabelas homogêneas a partir de %ROWTYPE de tabelas e cursores.
   Dessa forma, não se cria um único array de vários tipos, mas sim vários arrays em uma mesma PL/SQL TABLE.
*/
DECLARE
  TYPE tpDepartment_id IS TABLE OF departments.department_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tpDepartment_name IS TABLE OF departments.department_name%TYPE INDEX BY BINARY_INTEGER;
  TYPE tpDepartment_manager IS TABLE OF departments.manager_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tpDepartment_location IS TABLE OF departments.location_id%TYPE INDEX BY BINARY_INTEGER;
  idx BINARY_INTEGER DEFAULT 0;
 
  tbDepartments   tpDepartment_id;
  tbDeptNames     tpDepartment_name;
  tbDeptManagers  tpDepartment_manager;
  tbDeptLocations tpDepartment_location;
BEGIN
  FOR r1 IN (SELECT * FROM departments) LOOP
    idx := idx + 1;
    tbDepartments(idx)   := r1.department_id;
    tbDeptNames(idx)     := r1.department_name;
    tbDeptManagers(idx)  := r1.manager_id;
    tbDeptlocations(idx) := r1.location_id;
  END LOOP;
  
  FOR i IN 1..tbDepartments.LAST LOOP
    dbms_output.PUT_LINE(tbDepartments(i) || ' - ' || tbDeptNames(i) || ', ' || tbDeptManagers(i) || ', ' || tbDeptLocations(i));
  END LOOP;
END;

-- Exemplo de criação de vetor a partir de cursor
DECLARE
  CURSOR c1 IS 
    SELECT d.department_id,
           d.department_name,
           e.first_name,
           l.street_address
      FROM departments d, employees e, locations l
     WHERE d.manager_id  = e.employee_id
       AND d.location_id = l.location_id
     ORDER BY d.department_name;
  TYPE typeDept IS TABLE OF c1%ROWTYPE INDEX BY BINARY_INTEGER;
  idx BINARY_INTEGER DEFAULT 0;
  tbDepartments typeDept;
BEGIN
  FOR r1 IN c1 LOOP
    tbDepartments(r1.department_id) := r1;
  END LOOP;
  
  idx := tbDepartments.FIRST;
  WHILE idx <= tbDepartments.LAST LOOP
    dbms_output.PUT_LINE(
      tbDepartments(idx).department_id || ' - ' ||
      tbDepartments(idx).department_name || ', ' ||
      tbDepartments(idx).first_name || ', ' ||
      tbDepartments(idx).street_address
    );
    idx := tbDepartments.NEXT(idx);
  END LOOP;
  dbms_output.PUT_LINE(tbDepartments.COUNT);
END;

-- Exemplo de criação de vetor a partir de uma tabela
DECLARE 
  TYPE typeDept IS TABLE OF departments%ROWTYPE INDEX BY BINARY_INTEGER;
  tbDepartments typeDept;
  idx BINARY_INTEGER DEFAULT 0;
BEGIN
  FOR r1 IN (SELECT * FROM departments) LOOP -- Populando a PL/SQL TABLE
    idx := idx + 1;
    tbDepartments(idx) := r1;
  END LOOP;
  
  FOR i IN 1..tbDepartments.LAST LOOP
    dbms_output.PUT_LINE(
      tbDepartments(i).department_id || ' - ' ||
      tbDepartments(i).department_name || ', ' || 
      tbDepartments(i).manager_id || ', ' ||
      tbDepartments(i).location_id
    );
  END LOOP;
  dbms_output.PUT_LINE('----------------------------');
  
  idx := tbDepartments.FIRST;
  WHILE idx <= tbDepartments.LAST LOOP
    dbms_output.PUT_LINE(
      tbDepartments(idx).department_id || ' - ' ||
      tbDepartments(idx).department_name || ', ' || 
      tbDepartments(idx).manager_id || ', ' ||
      tbDepartments(idx).location_id
    );
    idx := tbDepartments.NEXT(idx);
  END LOOP;
END;
----------------------------------------------------------
/* PL/SQL RECORDS - Estruturas heterogênicas
   Diferente das PL/SQL tables, que nos permite criar uma única estrutura de um tipo de dado especificado,
	 esse objeto permite criar uma estrutura composta por diversos tipos de dados.
	 Um detalhe importante é que uma PL/SQL RECORD por si só, armazena apenas um registro, enquanto PL/SQL TABLES armazenam vários registros.
	 Ambas podem ser utilizadas em conjunto para adquirir um melhor resultado.
*/

-- Exemplo utilizando apenas o TYPE RECORD
DECLARE
	TYPE tpDept IS RECORD (
		department_id   NUMBER, 
		department_name VARCHAR2(25), 
		manager_id			NUMBER,
		location_id 		NUMBER
	);
	tbDepartments tpDept;
BEGIN
	SELECT * INTO tbDepartments
	  FROM departments
   WHERE department_id = 40;
    
  dbms_output.PUT_LINE(
    tbDepartments.department_id || ' - ' ||
    tbDepartments.department_name || ', ' || 
    tbDepartments.manager_id || ', ' ||
    tbDepartments.location_id
  );
END;

-- Exemplo de PLSQL RECORD em conjunto com PLSQL TABLE
DECLARE
	TYPE tpDeptRecord IS RECORD (
		department_id   NUMBER(4),
		department_name VARCHAR2(30),
		manager_id 			NUMBER(6),
		location_id 		NUMBER(4)
	);
	TYPE tpDeptTable IS TABLE OF departments%ROWTYPE INDEX BY BINARY_INTEGER;
	tbDepartments tpDeptTable;
	idx BINARY_INTEGER DEFAULT 0;
	
	CURSOR c1 IS SELECT * FROM departments;
	TYPE tpDeptTableCursor IS TABLE OF c1%ROWTYPE INDEX BY BINARY_INTEGER;
	tbDepartmentsCursor tpDeptTableCursor;
BEGIN
	FOR r1 IN (SELECT * FROM departments) LOOP -- Populando sem cursor
		idx := idx + 1;
		tbDepartments(idx) := r1;
	END LOOP;
	
	idx := tbDepartments.FIRST;
	WHILE idx <= tbDepartments.LAST LOOP
		dbms_output.PUT_LINE(
			tbDepartments(idx).department_id || ' - ' ||
			tbDepartments(idx).department_name || ', ' || 
			tbDepartments(idx).manager_id || ', ' ||
			tbDepartments(idx).location_id
		);
		idx := tbDepartments.NEXT(idx);
	END LOOP;
	dbms_output.PUT_LINE('---------------------------------');
	
	FOR r1 IN c1 LOOP -- Populando com cursor
		tbDepartmentsCursor(r1.department_id) := r1;
	END LOOP;
	
	idx := tbDepartmentsCursor.FIRST;
	WHILE idx <= tbDepartmentsCursor.LAST LOOP
		dbms_output.PUT_LINE(
			tbDepartmentsCursor(idx).department_id || ' - ' ||
			tbDepartmentsCursor(idx).department_name || ', ' || 
			tbDepartmentsCursor(idx).manager_id || ', ' ||
			tbDepartmentsCursor(idx).location_id
		);
		idx := tbDepartmentsCursor.NEXT(idx);
	END LOOP;
	
	/* O CURSOR DESSA FORMA NÃO FUNCIONA. TEM QUE UTILIZAR O LAÇO WHILE
    
		FOR i IN tbDepartmentsCursor...tbDepartmentsCursor.LAST LOOP
      dbms_output.PUT_LINE(
        tbDepartmentsCursor(i).department_id || ' - ' ||
        tbDepartmentsCursor(i).department_name || ', ' || 
        tbDepartmentsCursor(i).manager_id || ', ' ||
        tbDepartmentsCursor(i).location_id
        );
    END LOOP;
  */  
END;
-----------------------------------------------------------------

/* PACOTE UTL_FILE
	 Para as versões mais antigas do Oracle era necessário configurar as permissões em nivel de servidor para definir quais diretórios poderiam ser acessados 
	 e manipulados por este pacote. Tal configuração requeria a parada do sistema e alterações nos parâmetros do sistema, exigindo conhecimentos específicos de DBA.
	 Atualmente, é possível criar um objeto DIRECTORY, que aponta para um diretório no servidor, para utilização dos arquivos.
	
	 É necessário ter permissão para utilizar o pacote UTL_FILE;
	 Para criar um diretório é necessário que o usuário tenha permissão CREATE ANY DIRECTORY e quando ele cria este diretório, automaticamente garante permissão de leitura e escrita.
	 O usuário OWNER do diretório também pode dar permissões de leitura e gravação para outros usuários: 
*/

GRANT CREATE ANY DIRECTORY TO HR -- Comando utilizado como DBA
CREATE OR REPLACE DIRECTORY dir_principal AS 'C:\Users\prcp1329500\Documents\pessoal\diretorio_livro';
GRANT READ, WRITE ON DIRECTORY dir_principal TO HR; -- Comando utilizado como DBA
GRANT EXECUTE ON UTL_FILE TO HR;

-- Exemplo de escrita de arquivo com base nos dados de uma tabela, separando os dados por ponto-vírgula
DECLARE
	CURSOR c1 IS
		SELECT e.employee_id,
					 e.first_name,
					 e.salary,
					 d.department_name,
					 j.job_title
			FROM employees e, departments d, jobs j
		 WHERE e.department_id = d.department_id
			 AND e.job_id = j.job_id
		 ORDER BY d.department_name;
  r1 c1%ROWTYPE;
	meu_arquivo utl_file.FILE_TYPE;
BEGIN
	meu_arquivo := utl_file.FOPEN('C:\Users\prcp1329500\Documents\pessoal\diretorio_livro', 'empregados.txt', 'W');
	OPEN c1;
		LOOP
			FETCH c1 INTO r1;
			EXIT WHEN c1%NOTFOUND;
			utl_file.PUT_LINE(meu_arquivo, 
				r1.employee_id 		 || ';' ||
			  r1.first_name 		 || ';' ||
				r1.salary					 || ';' ||
				r1.department_name || ';' ||
				r1.job_title
			);															 
		END LOOP;
	CLOSE c1;
	utl_file.FCLOSE(meu_arquivo);
	
	EXCEPTION 
		WHEN utl_file.INVALID_PATH THEN
			utl_file.FCLOSE(meu_arquivo);
			dbms_output.PUT_LINE('Caminho ou nome do arquivo inválido.');
		WHEN utl_file.INVALID_MODE THEN
			utl_file.FCLOSE(meu_arquivo);
			dbms_output.PUT_LINE('Modo de abertura inválido.');
		WHEN OTHERS THEN
			dbms_output.PUT_LINE('Erro ao escrever no arquivo: ' || SQLERRM);
END;            

-- Tabela para teste de importação de arquivo
CREATE TABLE tb_importa_employee_livro AS
  SELECT e.employee_id,
         e.first_name,
         e.salary,
         d.department_name,
         j.job_title
    FROM employees e, departments d, jobs j
   WHERE e.department_id = d.department_id
     AND e.job_id = j.job_id
   ORDER BY e.first_name;
	 
-- Exemplo teste de leitura e importação de arquivo
DECLARE
	meu_arquivo utl_file.FILE_TYPE;
	linha 			VARCHAR2(32000);
	
	vEmployee_id 		 tb_importa_employee_livro.employee_id%TYPE;
	vFirst_name  		 tb_importa_employee_livro.first_name%TYPE;
	vSalary 		 		 tb_importa_employee_livro.salary%TYPE;
	vJobTitle			 	 tb_importa_employee_livro.job_title%TYPE;
	vDepartment_name tb_importa_employee_livro.department_name%TYPE;
BEGIN	
		meu_arquivo := utl_file.FOPEN('DIR_PRINCIPAL', 'empregados.txt', 'r');
		LOOP
			utl_file.GET_LINE(meu_arquivo, linha);
			EXIT WHEN linha IS NULL;
			
			vEmployee_id := RTRIM(SUBSTR(linha, 1, (INSTR(linha, ';', 1, 1) - 1)));
			vFirst_name  := RTRIM(SUBSTR(linha, (INSTR(linha, ';', 1, 1) + 1)
                                        , (INSTR(linha, ';', 1, 2) - 1) -
                                          (INSTR(linha, ';', 1, 1)))); 
      vSalary := RTRIM(SUBSTR(linha, (INSTR(linha, ';', 1, 2) + 1)
                                   , (INSTR(linha, ';', 1, 3) - 1) -
                                     (INSTR(linha, ';', 1, 2))));
      vJobTitle := RTRIM(SUBSTR(linha, (INSTR(linha, ';', 1, 3) + 1)
                                     , (INSTR(linha, ';', 1, 4) - 1) -
                                       (INSTR(linha, ';', 1, 3))));
      vDepartment_name := RTRIM(SUBSTR(linha, (INSTR(linha, ';', 1, 4) + 1)));
  
			dbms_output.PUT_LINE(
        'ID: '   || vEmployee_id || ' - ' ||
        'Nome: ' || vFirst_name  || ', '  ||
        'Salario: R$ ' || TO_CHAR(vSalary, 'FM9G999G099D00') || ', ' ||
        'Departamento: ' || vDepartment_name || ', ' ||
        'Cargo: ' || vJobTitle || '.'
      );
		END LOOP;
		utl_file.FCLOSE(meu_arquivo);
    
    EXCEPTION
      WHEN utl_file.INVALID_PATH THEN
        utl_file.FCLOSE(meu_arquivo);
        dbms_output.PUT_LINE('Caminho ou nome do arquivo inválidos.');  
      WHEN utl_file.INVALID_MODE THEN
        utl_file.FCLOSE(meu_arquivo);
        dbms_output.PUT_LINE('Módulo inválido.');
      WHEN NO_DATA_FOUND THEN
        utl_file.FCLOSE(meu_arquivo);
        dbms_output.PUT_LINE('Nenhum registro encontrado');
      WHEN OTHERS THEN
        utl_file.FCLOSE(meu_arquivo);
        dbms_output.PUT_LINE('Erro ao ler arquivo: ' || SQLERRM);
END;

-- Exemplo de criação da arquivos com o tamanho das colunas fixo.
DECLARE
	CURSOR c1 IS 
		SELECT e.employee_id,
					 e.first_name, 
					 e.salary,
					 d.department_name, 
					 j.job_title
			FROM employees e, departments d, jobs j
		 WHERE e.department_id = d.department_id
		   AND e.job_id = j.job_id
		 ORDER BY e.first_name;
	meu_arquivo utl_file.FILE_TYPE;
BEGIN
	meu_arquivo := utl_file.FOPEN('DIR_PRINCIPAL', 'empregados2.txt', 'w');
	FOR r1 IN c1 LOOP
		utl_file.PUT_LINE(meu_arquivo,
			LPAD(r1.employee_id, 6, 0)   			|| 
			RPAD(r1.first_name, 20, ' ') 			||
			LPAD(r1.salary, 8, 0)			   			||
			RPAD(r1.department_name, 30, ' ') ||
			RPAD(r1.job_title, 35, ' ')
		);
	END LOOP;
	utl_file.FCLOSE(meu_arquivo);
	
	EXCEPTION 
		WHEN utl_file.INVALID_PATH THEN
			utl_file.FCLOSE(meu_arquivo);
			dbms_output.PUT_LINE('Caminho ou nome do arquivo estão inválidos.');
		WHEN utl_file.INVALID_MODE THEN
			utl_file.FCLOSE(meu_arquivo);
			dbms_output.PUT_LINE('Modo inválido para escrita do arquivo.');
		WHEN OTHERS THEN
			utl_file.FCLOSE(meu_arquivo);
			dbms_output.PUT_LINE('Erro ao escrever no arquivo: ' || SQLERRM);
END;

-- Exemplo de leitura de arquivo com tamanho predefinido
-- Exemplo de leitura de arquivo com tamanho predefinido
DECLARE	
	meu_arquivo utl_file.FILE_TYPE;
	linha VARCHAR2(1000);
	
	vEmployee_id		 tb_importa_employee_livro.employee_id%TYPE;
	vFirst_name  		 tb_importa_employee_livro.first_name%TYPE;
	vSalary 		 	 	 tb_importa_employee_livro.salary%TYPE;
	vDepartment_name tb_importa_employee_livro.department_name%TYPE;
	vJob_title			 tb_importa_employee_livro.job_title%TYPE;
BEGIN
	meu_arquivo := utl_file.FOPEN('DIR_PRINCIPAL', 'employees2.txt', 'r');
  LOOP
    utl_file.GET_LINE(meu_arquivo, linha);
    EXIT WHEN linha IS NULL;
    
    vEmployee_id     := TO_NUMBER(TRIM(SUBSTR(linha, 1,6)));
    vFirst_name      := TRIM(SUBSTR(linha, 7, 20));
    vSalary          := TO_NUMBER(TO_CHAR(TRIM(SUBSTR(linha, 27,8)), 'FM9G999G099D00'), '9G999G099D00');
    vDepartment_name := TRIM(SUBSTR(linha, 35, 30));
    vJob_title       := TRIM(SUBSTR(linha, 65, 35));
    
    dbms_output.PUT_LINE(
      'ID: '   || vEmployee_id || ', ' ||
      'Name: ' || vFirst_name  || ', ' ||
      'Salary: ' || vSalary    || ', ' ||
      'Depart: ' || vDepartment_name || ', ' ||
      'Cargo: '  || vJob_title      
    );
    
    /* A parte de inserir os dados não está funcionando. Verificar depois
        BEGIN
          INSERT INTO tb_importa_employee_livro (employee_id, first_name, salary, department_name, job_title)
          VALUES (vEmployee_id, vFirst_name, vSalary, vDepartment_id, vJob_title);
          COMMIT;
          
          EXCEPTION 
            WHEN OTHERS THEN
              ROLLBACK;
              dbms_output.PUT_LINE('Erro ao inserir dados na tabela.');
        END;  
  */    
  END LOOP;
  utl_file.FCLOSE(meu_arquivo);
  
  EXCEPTION 
    WHEN utl_file.INVALID_PATH THEN
      utl_file.FCLOSE(meu_arquivo);
      dbms_output.PUT_LINE('Caminho ou nome do arquivo estão incorretos.');
    WHEN utl_file.INVALID_MODE THEN
      utl_file.FCLOSE(meu_arquivo);
      dbms_output.PUT_LINE('Mode errado para leitura de arquivo.');
    WHEN NO_DATA_FOUND THEN
      utl_file.FCLOSE(meu_arquivo);
      dbms_output.PUT_LINE('Leitura completa.');
    WHEN OTHERS THEN
      utl_file.FCLOSE(meu_arquivo);
      dbms_output.PUT_LINE('Erro ao ler arquivo: ' || SQLERRM);
END;
------------------------------------------------------------------------------------

/* SQL DINÂMICO
   Utilizado quando há a necessidade de construir comandos específicos de acordo com situações específicas em um programa.
   Em resumo, executa QUERIES construídas a partir de STRINGS, contendo o corpo do código que será executado.
   É executado a partir do comando EXECUTE IMMEDIATE, precedido pelo nome da variável que armazena o SQL, seguido dos parâmetros que serão utilizados,
   sendo esses, identificados por variáveis do tipo BIND.
   
   SQL DINÂMICO só será utilizado em tempo de execução.
*/

-- Exemplo de INSERT utilizando uma variável como recipiente de código SQL.
DECLARE
  vInsert_employees   VARCHAR2(4000);
  vInsert_departments VARCHAR2(4000);
  
  vEmployee_id tb_importa_employee_livro.employee_id%TYPE;
  vFirst_name  tb_importa_employee_livro.first_name%TYPE;
  vSalary      tb_importa_employee_livro.salary%TYPE;
  vJob_title   tb_importa_employee_livro.job_title%TYPE;
  vDepartment_name tb_importa_employee_livro.department_name%TYPE;
BEGIN
  vEmployee_id := 1;
  vFirst_name := 'Paulo';
  vSalary := 6850;
  vJob_title := 'Analista de sistemas';
  vDepartment_name := 'Plano de saúde';
  
  vInsert_employees   := 'INSERT INTO tb_importa_employee_livro
                            VALUES (:vEmployee_id, :vFirst_name, :vSalary, :vJob_title, :vDepartment_name)';
  vInsert_departments := 'INSERT INTO departments
                            VALUES (:department_id, :department_name, :manager_id, :location_id)';
                          
  -- Executa a SQL contida na String, passando como parâmetro as variáveis na cláusula USING.
  EXECUTE IMMEDIATE vInsert_employees USING vEmployee_id, vFirst_name, vSalary, vJob_title, vDepartment_name;
  COMMIT;
  
  -- Executa a SQL contida na String, passando os valores diretamente na cláusula USING
  EXECUTE IMMEDIATE vInsert_departments USING 300, 'Dept_teste', 101, 1000;
  
  -- Executa a SQL contida na String e os valores para os parâmetros serão informados dinamicamente, no momento da execução da query.
  EXECUTE IMMEDIATE vInsert_departments USING :1, :2, :3, :4;
  ROLLBACK;
END;

-- Exemplos de UPDATE utilizando STRING LITERAL. O valor utilizado como parâmetro é passado logo após a chamada da procedure
BEGIN 
  EXECUTE IMMEDIATE 'UPDATE tb_importa_employee_livro
                        SET salary = 29000
                      WHERE employee_id = :employee_id' USING 1;
  COMMIT; 
END;

-- Exemplo de DELETE utilizando STRING LITERAL. O valor para o parâmetro será definido dinamicamente em tempo de execução
BEGIN
  EXECUTE IMMEDIATE 'DELETE FROM tb_importa_employee_livro
                     WHERE employee_id = :employee_id' USING :1;
  COMMIT;
END;  

-- Exemplo de alteração de tabelas
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE tb_importa_employee
                     MODIFY department_name NUMBER(10) NOT NULL';
  EXECUTE IMMEDIATE 'ALTER TABLE tb_importa_employee
                     RENAME TO tb_importa_employee_livro';
END;

-- Com SQL DINÂMICO também é possível retornar informações provenientes de comandos SQL
DECLARE
  vAtualiza_department VARCHAR2(2000);
  vDepartment_name     departments.department_name%TYPE;
  vManager             departments.manager_id%TYPE;
  vLocation            departments.location_id%TYPE;
BEGIN
  vAtualiza_department := 'UPDATE departments 
                              SET location_id = :1
                            WHERE department_id = :2
                            RETURNING department_name, location_id INTO :3, :4';  
  EXECUTE IMMEDIATE vAtualiza_department USING 1000, 150, OUT vDepartment_name, OUT vLocation;
  ROLLBACK;
  dbms_output.PUT_LINE(vDepartment_name);
  dbms_output.PUT_LINE(vLocation);
END

-- Exemplo da criação de uma função com o uso do comando DELETE
DECLARE
  linhasExcluidas NUMBER;
  FUNCTION rows_deleted (table_name IN VARCHAR2, condition IN VARCHAR2) RETURN INTEGER AS
	BEGIN
		EXECUTE IMMEDIATE 'DELETE FROM ' || table_name || ' ' ||
											'WHERE ' || condition;
		RETURN SQL%ROWCOUNT;		
	END rows_deleted;
BEGIN
	linhasExcluidas := rows_deleted('employees', 'employee_id = 105');
	dbms_output.PUT_LINE('Linhas excluídas: ' || linhasExcluidas);
	COMMIT;
  
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			dbms_output.PUT_LINE('Erro ao apagar funcionário: ' || SQLERRM);
END;

-- Exemplo de PROCEDURE executada através de SQL DINÂMICO
CREATE OR REPLACE PROCEDURE make_dept (department_id IN NUMBER, department_name IN VARCHAR2, manager_id IN NUMBER, location_id IN NUMBER, status IN OUT VARCHAR2) IS
	BEGIN
		INSERT INTO departments VALUES (department_id, department_name, manager_id, location_id);
		status := 'OK';
		COMMIT;
   
		EXCEPTION
			WHEN OTHERS THEN
				ROLLBACK;
				status := 'Erro ao inserir departamento: ' || SQLERRM;
END make_dept;

DECLARE
  vInsere_department VARCHAR2(2000);
	vStatus 		  		 VARCHAR2(4000);
	vDepartment_id 	 departments.department_id%TYPE DEFAULT 300;
	vDepartment_name departments.department_name%TYPE DEFAULT 'Teste';
	vManager_id			 departments.manager_id%TYPE DEFAULT 101;
	vLocation_id 		 departments.location_id%TYPE DEFAULT 1000;
BEGIN	
  vInsere_department := 'BEGIN make_dept (:a, :b, :c, :d, :e); END;';
	EXECUTE IMMEDIATE vInsere_department USING vDepartment_id, vDepartment_name, vManager_id, vLocation_id, IN OUT vStatus;
  
  IF(vStatus = 'OK') THEN
    dbms_output.PUT_LINE('Departamento inserido com sucesso.');
  ELSE 
    dbms_output.PUT_LINE(vStatus);
  END IF;  
END;

-- REF CURSORES são cursores que não estão vinculados à uma estrutura de tabela, como é o caso dos cursores comuns.
-- Sendo assim, eles podem ser utilizados várias vezes durante a execução de um programa e para consultas diferentes.
-- Não armazenam o valor apontado pelo cursor em memória, serve apenas como ponteiro.
DECLARE
	TYPE refCursorType IS REF CURSOR;
	cursorEmployees    refCursorType;
	
	first_name employees.first_name%TYPE;
	salary 		 employees.salary%TYPE DEFAULT 1000;
BEGIN
	OPEN cursorEmployees FOR
		'SELECT first_name, salary FROM employees WHERE salary > :1' USING salary;
	  LOOP
			FETCH cursorEmployees INTO first_name, salary;
			EXIT WHEN cursorEmployees%NOTFOUND;
			
			dbms_output.PUT_LINE(first_name || ', R$ ' || TO_CHAR(salary, 'fm9G999G099D00')); 
		END LOOP;
		
		EXCEPTION 
			WHEN OTHERS THEN
				dbms_output.PUT_LINE(SQLERRM);
	CLOSE cursorEmployees;
END;

-- Também é possível definir o SQL em uma variável para o REF Cursor
DECLARE
	TYPE refCursor IS REF CURSOR;
	dadoCursor  refCursor;
	employeeRec employees%ROWTYPE;
	sql_stmt    VARCHAR2(1000);
	vFilter 			VARCHAR2(20) DEFAULT 'IT_PROG';
BEGIN
	sql_stmt := 'SELECT e.employee_id,
											e.first_name,
											j.job_title,
											e.salary									
								 FROM employees e, jobs j
								WHERE e.job_id = :1
								  AND e.job_id = j.job_id';
	OPEN dadoCursor FOR sql_stmt USING vFilter;
		LOOP
			FETCH dadoCursor INTO employeeRec;
			EXIT WHEN dadoCursor%NOTFOUND;
			
			dbms_output.PUT_LINE(
				'ID: '    || employeeRec.employee_id || ', ' ||
				'Nome: '  || employeeRec.first_name  || ', ' ||
				'Cargo:	' || employeeRec.job_title   || ', ' ||
				'Salario: R$ ' || TO_CHAR(employeeRec.salary, 'fm9G999G099D00')
			);
		END LOOP;
	CLOSE dadoCursor;
	
	EXCEPTION
		WHEN OTHERS THEN
			dbms_output.PUT_LINE(SQLERRM);
END;

