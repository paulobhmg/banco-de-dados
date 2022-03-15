/* Pacote UTL_FILE - Leitura e escrita de arquivos. 
 - Os arquivos ficam salvos no sistema operacional onde encontra-se o servidor do banco de dados
 - Essa package é muito utilizada quando há a necessidade de ler tabelas e gerar arquivos de texto ou vice versa, sendo bastante útil em integrações entre sistemas,
   possibilitando fazer a carga de tabelas, a partir da leitura dos arquivos.

 - É necessário criar uma pasta no sistema operacional do CLIENT para manipulação de arquivos e para que o ORACLE possa utilizar esse diretório
   é necessário criar um DIRECTORY e passar o caminho do diretório para manipulação dos dados 

 ** O diretório deverá ser criado pelo DBA passado as permissões de leitura e escrita para um usuário específico. 
*/
	 
-- Como DBA, criar um diretório e dar permissão para o usuário HR
CREATE OR REPLACE DIRECTORY plsql_directory AS 'C:\Users\prcp1329500\Documents\pessoal\plsql_especialista\arquivos';
GRANT READ, WRITE ON DIRECTORY plsql_directory TO hr;

-- Exemplo de rotina para escrita em arquivo
DECLARE
	vFile  utl_file.FILE_TYPE;
	CURSOR employeesC IS
		SELECT employee_id, 
					 first_name,
					 salary,
					 job_id 
			FROM employees
		 ORDER BY employee_id;
BEGIN
	vFile := utl_file.FOPEN('PLSQL_DIRECTORY', 'employees.txt', 'w', 32767);
	FOR r1 IN employeesC LOOP
		utl_file.PUT_LINE(vFile, 
			TO_CHAR(r1.employee_id, 'FM009') || ';' ||
			RPAD(r1.first_name, 10, ' ') || ';' ||
			TO_CHAR(r1.salary, 'FM0000000000') || ';' ||
			RPAD(r1.job_id, 10, ' ')
		);							
	END LOOP;
	utl_file.FCLOSE(vFile);
	dbms_output.PUT_LINE('Dados escritos com sucesso');
	
	EXCEPTION
		WHEN utl_file.INVALID_PATH THEN
			utl_file.FCLOSE(vFile);
			dbms_output.PUT_LINE('Diretório inválido');
		WHEN utl_file.INVALID_OPERATION THEN
			utl_file.FCLOSE(vFile);
			dbms_output.PUT_LINE('Operação inválida');
		WHEN utl_file.WRITE_ERROR THEN
			utl_file.FCLOSE(vFile);
			dbms_output.PUT_LINE('Erro na gravação do arquivo');
		WHEN utl_file.INVALID_MODE THEN
			utl_file.FCLOSE(vFile);
			dbms_output.PUT_LINE('Erro no modo selecionado');
		WHEN OTHERS THEN 
			utl_file.FCLOSE(vFile);
			dbms_output.PUT_LINE('Erro: ' || SQLERRM);
END;
----------------------------

-- Exemplo de leitura de arquivo
DECLARE
	vFile    utl_file.FILE_TYPE;
	registro VARCHAR2(400); 
BEGIN
	vFile := utl_file.FOPEN('PLSQL_DIRECTORY', 'employees.txt', 'r', 32767);
	LOOP
		utl_file.GET_LINE(vFile, registro);
		dbms_output.PUT_LINE(registro);
	END LOOP;
	utl_file.FCLOSE(vFile);
	
	EXCEPTION 
		WHEN utl_file.INVALID_PATH THEN
			utl_file.FCLOSE(vFile);
			dbms_output.PUT_LINE('Path inválido.');
		WHEN utl_file.INVALID_OPERATION THEN
			utl_file.FCLOSE(vFile);
			dbms_output.PUT_LINE('Operação inválida.');
		WHEN NO_DATA_FOUND THEN
			utl_file.FCLOSE(vFile);
			dbms_output.PUT_LINE('Fim da leitura.');
		WHEN utl_file.INVALID_MODE THEN
			utl_file.FCLOSE(vFile);
			dbms_output.PUT_LINE('Modo inválido.');
		WHEN OTHERS THEN
			utl_file.FCLOSE(vFile);
			dbms_output.PUT_LINE('Erro: ' || SQLERRM);
END;

-- Exemplo de leitura separando os registros por ';'
DECLARE
	vFile    utl_file.FILE_TYPE;
	vEmpId   employees.employee_id%TYPE;
	vName 	 employees.first_name%TYPE;
	vSalary  employees.salary%TYPE;
	vjobId	 employees.job_id%TYPE;
	registro VARCHAR2(400);
BEGIN
	vFile := utl_file.FOPEN('PLSQL_DIRECTORY', 'employees.txt', 'r', 32767);
	LOOP
		utl_file.GET_LINE(vFile, registro);
		vEmpId := TO_NUMBER(SUBSTR(registro, 1, INSTR(registro, ';', 1) -1));
    vName  := TRIM(SUBSTR(registro, (INSTR(registro, ';', 1, 1) + 1), 
                                    (INSTR(registro, ';', 1, 2) -1) - (INSTR(registro, ';', 1, 1))));
    vSalary := TO_NUMBER(SUBSTR(registro, (INSTR(registro, ';', 1, 2) + 1),
                                          (INSTR(registro, ';', 1, 3) - 1) - (INSTR(registro, ';', 1, 2))));
    vJobId := TRIM(SUBSTR(registro, (INSTR(registro, ';', 1, 3) + 1)));
		dbms_output.PUT_LINE(vEmpId || ' - ' || vName || ', R$ ' || TO_CHAR(vSalary, 'fm99G999G999D00') || ', ' || vJobId);
	END LOOP;
	utl_file.FCLOSE(vFile);
	
	EXCEPTION 
		WHEN utl_file.INVALID_PATH THEN
			utl_file.FCLOSE(vFile);
			dbms_output.PUT_LINE('Path inválido.');
		WHEN utl_file.INVALID_OPERATION THEN
			utl_file.FCLOSE(vFile);
			dbms_output.PUT_LINE('Operação inválida.');
		WHEN NO_DATA_FOUND THEN
			utl_file.FCLOSE(vFile);
			dbms_output.PUT_LINE('Fim da leitura.');
		WHEN utl_file.INVALID_MODE THEN
			utl_file.FCLOSE(vFile);
			dbms_output.PUT_LINE('Modo inválido.');
		WHEN OTHERS THEN
			utl_file.FCLOSE(vFile);
			dbms_output.PUT_LINE('Erro: ' || SQLERRM);
END;
