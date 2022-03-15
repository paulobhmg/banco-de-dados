/* Criar TYPES no PLSQL permite armazenar em variáveis valores homogêneos ou heterogêneos, com base
 nos dados de uma ou mais tabelas, permitindo criar uma lista a partir de um ou vários tipos de dados distintos. */
 
-- Dados do tipo RECORD, também conhecidos como tabelas heterogêneas são estruturas criadas pelo próprio desenvolvedor, capazes
-- de armazenar vários dados distintos, como colunas de tabelas.

DECLARE
	TYPE employee_record_type IS RECORD (
		employee_id employees.employee_id%TYPE,
		first_name  employees.first_name%TYPE,
		salary      employees.salary%TYPE,
		job_id 	    employees.job_id%TYPE
	);
	empRec employee_record_type;
	empCod employees.employee_id%TYPE DEFAULT &id;
BEGIN
	SELECT employee_id, first_name, salary, job_id
	  INTO empRec.employee_id, empRec.first_name, empRec.salary, empRec.job_id
		FROM employees
	 WHERE employee_id = empCod;
  dbms_output.PUT_LINE(empRec.employee_id || ' - ' || empRec.first_name || ', ' || empRec.salary || ', ' || empRec.job_id);
	
	EXCEPTION 
		WHEN no_data_found THEN
			dbms_output.PUT_LINE('ID não cadastrado.');
		WHEN OTHERS THEN
			dbms_output.PUT_LINE(SQLERRM);
END;

-- Também é possível criar um RECORD a partir de uma tabela ou cursor já definidos, utilizando o atributo %ROWTYPE
-- Dessa forma, não há a necessidade de criar um TYPE e em seguida uma variável desse TYPE, pois o ROWTYPE é inferido automaticamente.
DECLARE
	vEmployee_id employees.employee_id%TYPE DEFAULT &emp;
	CURSOR c1 IS
		SELECT employee_id, first_name, salary, job_id
		  FROM employees
		 WHERE employee_id = vEmployee_id;
	er employees%ROWTYPE;
	cr c1%ROWTYPE;
BEGIN
  -- Um tipo RECORD permite armazenar apenas um registro, enquanto um cursor armazena vários valores, baseado na sua definição.
	OPEN c1;
		FETCH c1 INTO cr;
	CLOSE c1;
	 
	dbms_output.PUT_LINE('Rowtype cursor:');
	dbms_output.PUT_LINE(cr.employee_id || ' - ' || cr.first_name || ', ' || cr.salary || ', ' || cr.job_id);
	dbms_output.PUT_LINE('-------');
	dbms_output.NEW_LINE;
	
	SELECT *
		INTO er 
		FROM employees
	 WHERE employee_id = vEmployee_id;
	 '
	dbms_output.PUT_LINE('Rowtype table:');
	dbms_output.PUT_LINE(er.employee_id || ' - ' || er.first_name || ', ' || er.salary || ', ' || er.job_id);
	dbms_output.PUT_LINE('-------');
	dbms_output.NEW_LINE;
	
	EXCEPTION 
	WHEN no_data_found THEN
		dbms_output.PUT_LINE('ID não existe.');
	WHEN OTHERS THEN
		dbms_output.PUT_LINE(SQLERRM);	
END;
----------------------------------------------------------------------------

/* COLLECTIONS são estruturas utilizadas para gerenciamento de múltiplas linhas de dados, armazenados na memória.
 São vetores de uma dimensão, utilizados para manipulação dos dados armazenados no banco de dados.
 As collections podem ser de 3 tipos: ASSOCIATIVE ARRAY, NESTED ARRAY e VETOR */

/* ASSOCIATIVE ARRAYS 
 - São arrays de tipos de dados oracle que podem ser indexados por valores numéricos ou de texto.
 - Utiliza-se o índice para atribuição do valor (não utiliza EXTEND).
 - É obrigatório o uso do INDEX BY na sua declaração.
 - É válido observar que um TYPE não pode ser usado como referência. É necessário criar um objeto que seja do tipo TYPE definido previamente, e este sim, será utilizado no bloco BEGIN. 
 
 ** Diferente das estruturas do tipo RECORD, um Array permite armazenar uma lista de um único tipo, sendo necessário a criação de várias listas, uma para cada tipo de dado. */

DECLARE
	CURSOR c1 IS 
    SELECT employee_id, first_name 
      FROM employees
     ORDER BY employee_id;
	TYPE tabelaDeCodigosType IS TABLE OF employees.employee_id%TYPE INDEX BY BINARY_INTEGER;
	TYPE tabelaDeNomesType   IS TABLE OF employees.first_name%TYPE INDEX BY BINARY_INTEGER;
	tabelaDeCodigos tabelaDeCodigosType;
	tabelaDeNomes   tabelaDeNomesType;
	i BINARY_INTEGER DEFAULT 0;
BEGIN
	FOR r1 IN c1 LOOP
		i := i + 1;
		tabelaDeCodigos(i) := r1.employee_id;
		tabelaDeNomes(i) := r1.first_name;
	END LOOP;
	
	FOR j IN 1..i LOOP
		dbms_output.PUT_LINE(tabelaDeCodigos(j) || ' - ' || tabelaDeNomes(j));
	END LOOP;
	
	EXCEPTION
		WHEN OTHERS THEN 
			dbms_output.PUT_LINE(SQLERRM);
END;

/* ARRAY ASSOCIATIVO DE RECORDS
 Para resolver a limitação que temos para os ARRAY e para os RECORD's há a possibilidade de utilizá-los em conjunto, criando um ARRAY DE RECORD.
 Dessa forma, é possível criar listas de estruturas heterogêneas.*/

DECLARE
	TYPE employee_record_type IS RECORD (
		employee_id employees.employee_id%TYPE,
		first_name  employees.first_name%TYPE,
		salary      employees.salary%TYPE,
		job_id 	    employees.job_id%TYPE
	);
	TYPE employee_record_list_type IS TABLE OF employee_record_type INDEX BY BINARY_INTEGER;
	empTab   employee_record_list_type;
	contador NUMBER DEFAULT 0;
BEGIN
  -- Uma das formas de popular um ARRAY DE RECORDS é através de um LOOP, atribuindo à cada índice do array, o registro contido no ponteiro apontado pelo cursor do laço.
	FOR r1 IN (SELECT employee_id, first_name, salary, job_id FROM employees) LOOP
	  contador := contador + 1;
		empTab(contador) := r1;
	END LOOP;
	FOR i IN empTab.FIRST..empTab.LAST LOOP
		dbms_output.PUT_LINE(empTab(i).employee_id || ' - ' || empTab(i).first_name || ', ' || empTab(i).salary || ', ' || empTab(i).job_id);
	END LOOP;
	
	EXCEPTION
		WHEN OTHERS THEN
			dbms_output.PUT_LINE(SQLERRM);
END;

-- A cláusula BULK COLLECT permite armazenar em um ARRAY ASSOCIATIVO DE RECORDS, os dados contidos em um SELECT
-- Isso elimina o uso de LOOPs e cursores para popular um array, como no exemplo acima.
DECLARE
	TYPE employee_record_type IS RECORD (
		employee_id employees.employee_id%TYPE,
		first_name  employees.first_name%TYPE,
		salary      employees.salary%TYPE,
		job_id 	    employees.job_id%TYPE
	);
	TYPE employee_record_table IS TABLE OF employee_record_type INDEX BY BINARY_INTEGER;
	empTab employee_record_table;
BEGIN
	SELECT employee_id, first_name, salary, job_id 
	BULK COLLECT INTO empTab FROM employees ORDER BY employee_id;
	
	FOR i IN empTab.FIRST..empTab.LAST LOOP
		dbms_output.PUT_LINE(empTab(i).employee_id || ' - ' || empTab(i).first_name || ', ' || empTab(i).salary || ', ' || empTab(i).job_id);
	END LOOP;
END;
----------------------------------

/* NESTED TABLES é um array similar ao ASSOCIATIVO, porém com algumas peculiaridades:
 - Não recebe INDEX BY na sua declaração
 - Pode ser armazenado em uma tabela do banco de dados, embora não seja recomendado (Arrays associativos armazenam dados APENAS em memória)

 ** Deve ser inicializado logo no momento da sua declaração, como um objeto vazio.
 ** O objeto vazio será aquele definido como TYPE, em sua declaração.
 ** Para adicionar um novo valor, deve-se obrigatoriamente utilizar o método EXTEND. 
    Ao utilizar o EXTEND, adiciona um novo espaço no array, para então atribuir de fato um novo valor à posição estendida. */
		
DECLARE
	TYPE id_table 				IS TABLE OF employees.employee_id%TYPE;
	TYPE first_name_table IS TABLE OF employees.first_name%TYPE;
	listaDeCodigos id_table := id_table();
	listaDeNomes   first_name_table := first_name_table();
	i NUMBER DEFAULT 1;
BEGIN
	FOR r1 IN (SELECT employee_id, first_name FROM employees ORDER BY employee_id) LOOP
	  listaDeCodigos.EXTEND;
		listaDeCodigos(i) := r1.employee_id;
		listaDeNomes.EXTEND();
		listaDeNomes(i) := r1.first_name;
		i := i +1;
	END LOOP;
	FOR r1 IN 1..listaDeCodigos.COUNT LOOP
		dbms_output.PUT_LINE(listaDeCodigos(r1) || ' - ' || listaDeNomes(r1));
	END LOOP;
END;

-- De forma similar ao array associativo, a forma mais simples de populá-lo é utilizando o BULK COLLECT, 
-- fazendo com que os registros armazenados no SELECT sejam inseridos na coleção. Dessa forma também se evita a utilização do método EXTEND.
DECLARE
	TYPE employee_record_type IS RECORD (
		employee_id employees.employee_id%TYPE,
		first_name  employees.first_name%TYPE,
		salary      employees.salary%TYPE,
		job_id			employees.job_id%TYPE
	);
	TYPE employee_record_table IS TABLE OF employee_record_type;
  empTab employee_record_table := employee_record_table(); -- Lembrando que inicializa-se com o TIPO de dado criado.
BEGIN
	SELECT employee_id, first_name, salary, job_id 
	BULK COLLECT INTO empTab FROM employees
	ORDER BY employee_id;
	
	FOR i IN empTab.FIRST..empTab.LAST LOOP
		dbms_output.PUT_LINE(empTab(i).employee_id || ' - ' || empTab(i).first_name || ', ' || empTab(i).salary || ', ' || empTab(i).job_id);
	END LOOP;
END;
----------------------------------



-- É possível controlar Collections a partir de métodos (Pesquisar exemplos e aplicabilidade).
