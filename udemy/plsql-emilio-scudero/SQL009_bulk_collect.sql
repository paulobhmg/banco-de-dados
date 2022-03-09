/* BULK COLLECT
 - Quando utilizamos PL/SQL em conjunto com comandos SQL, existe a chamada CONTEXT SWITCH (troca de contexto).
 - Isso ocorre pois os comandos PLSQL são executados pela PLSQL Engine, enquanto os comandos SQL são executados pela SQL Engine.
 - Tendo isso em mente, sempre que um bloco PLSQL encontra um comando SQL, envia o contexto para a SQL engine, que por sua vez,
   após executar o comando SQL, retorna o contexto para a PLSQL Engine.
 - Tal troca de contexto pode onerar a performance do banco de dados.
 
 - Para maximizar a performance, temos a cláusula BULK COLLECT, que permite armazenar TODOS os registros contidos em um SELECT
   em uma Collection, sem a necessidade de criar LOOPS, abrir e fechar cursores e executar diretos comandos SQL. 
 
 ** Ao utilizar o BULK COLLECT, é necessário se atentar ao tamanho da tabela que está sendo utilizada, pois caso utilize tabelas
    muito grandes, que vão retornar vários dados, pode ocasionar no uso excessivo da memória e talvez uma parada no sistema. */
 

-- Utilizando o BULK COLLECT para Collections do tipo ASSOCIATIVE ARRAYS - PLSQL/TABLES - Indexadas by BINARY_INTEGER 
DECLARE
  TYPE employees_record_type IS RECORD (
    employee_id employees.employee_id%TYPE,
    first_name  employees.first_name%TYPE,
    salary      employees.salary%TYPE
  );
  TYPE employee_record_table_type IS TABLE OF employees_record_type INDEX BY BINARY_INTEGER;
  employees_table employee_record_table_type;
BEGIN
  SELECT employee_id,
         first_name,
         salary
    BULK COLLECT INTO employees_table
    FROM employees
   ORDER BY employee_id;
   
  FOR i IN employees_table.FIRST..employees_table.LAST LOOP
    dbms_output.PUT_LINE(employees_table(i).employee_id || ', ' || employees_table(i).first_name || ', ' || employees_table(i).salary);
  END LOOP;
END;

-- Utilizando o BULK COLLECT para Collections do tipo NESTED TABLE
DECLARE
  TYPE employees_record_type IS RECORD(
    employee_id employees.employee_id%TYPE,
    first_name  employees.first_name%TYPE,
    salary      employees.salary%TYPE
  );
  TYPE   employees_record_table_type IS TABLE OF employees_record_type;
  empTab employees_record_table_type := employees_record_table_type();
BEGIN
  SELECT employee_id, first_name, salary
    BULK COLLECT INTO empTab
    FROM employees
   ORDER BY employee_id;
   
  FOR i IN empTab.FIRST..empTab.LAST LOOP
    dbms_output.PUT_LINE(empTab(i).employee_id || ', ' || empTab(i).first_name || ', ' || empTab(i).salary);
  END LOOP;
END;

-- Exemplo do uso de NESTED TABLE sem o uso de BULK COLLECT - Nesse caso, Devem ser inicializados e para populá-los, é necessário usar o EXTEND para alocar um novo espaço
DECLARE
  TYPE employees_record_type IS RECORD(
    employee_id employees.employee_id%TYPE,
    first_name  employees.first_name%TYPE,
    salary      employees.salary%TYPE
  );
  TYPE   employees_record_table_type IS TABLE OF employees_record_type;
  empTab employees_record_table_type := employees_record_table_type();
  i NUMBER DEFAULT 1;
BEGIN
  FOR r1 IN (SELECT employee_id, first_name, salary FROM employees ORDER BY employee_id) LOOP
    empTab.EXTEND;
    empTab(i) := r1;
    i := i + 1;
  END LOOP;
  
  FOR i IN empTab.FIRST..empTab.LAST LOOP
    dbms_output.PUT_LINE(empTab(i).employee_id || ', ' || empTab(i).first_name || ', ' || empTab(i).salary);
  END LOOP;
END;

-- Utilizando BULK COLLECT para VARRAY - Deve ser informado um tamanho para o VARRAY
DECLARE
  TYPE employees_record_type IS RECORD(
    employee_id employees.employee_id%TYPE,
    first_name  employees.first_name%TYPE,
    salary      employees.salary%TYPE
  );
  TYPE employees_record_table_type IS VARRAY (200) OF employees_record_type;
  empTab employees_record_table_type := employees_record_table_type();
BEGIN
  SELECT employee_id, first_name, salary
    BULK COLLECT INTO empTab
    FROM employees
   ORDER BY employee_id DESC;
  
  FOR i IN empTab.FIRST..empTab.LAST LOOP
    dbms_output.PUT_LINE(empTab(i).employee_id || ', ' || empTab(i).first_name || ', ' || empTab(i).salary);
  END LOOP;
END;

-- MÉTODOS PARA COLLECTIONS
Collection.EXISTS(n) -- Retorna se existe elemento N na collection
Collection.COUNT; -- Retorna quantidade de registro da collection
Collection.FIRST -- Retorna o índice do primeiro elemento da collection - NULL para collections vazias
Collection.LAST -- Retorna o índice do último elemento da collection - NULL para collections vazias
Collection.LIMIT -- Só se aplica para VARRAY - Retorna o limite da Collection
Collection.PRIOR(n) -- Retorna o número do índice anterior a N
Collection.NEXT(n) -- Retorna o número do índice posterior a N
Collection.EXTEND -- Aloca uma ocorrência para o ARRAY (NESTED TABLE e VARRAY)
Collection.TRIM(n) -- Apenas para NESTED TABLE Remove o último elemento da collection caso não passe N. Se passar N, remove N elementos do fim da collection
Collection.DELETE -- Deleta todos os elementos da COLLECTION
Collection.DELETE(n) -- Deleta ocorrência de index n
Collection.DELETE(n, j) -- Deleta elementos de n a J, inclusive n e j. se aplica apenas a associative array e nested table.
