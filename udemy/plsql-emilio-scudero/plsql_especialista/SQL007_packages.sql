/* PACKAGES DE BANCOS DE DADOS
 - São utilizados para agrupar conjuntos de variáveis (globais), procedures, functions e triggers para realização de tarefas comuns, permitindo modularizar sistemas 
	 e o compartilhamento e reutilização de código por outros programas.
 - São compostos por PACKAGE ESPECIFICATION e PACKAGE BODY, sendo que a especificação é a interface pública, enquanto o corpo é a implementação do que está contido na interface.
 - Um package especification pode existir sem um body, porém, para a criação de um body, obrigatoriamente deve existir um specification, ao qual este fará referência.
 - Criar packages é uma forma de encapsulamento dos dados. Tudo que está definido no ESPECIFICATION é público, e o que está definido no BODY é privado. Sendo assim,
   objetos e tipos de dados definidos diretamente no BODY somente poderão ser acessados de dentro do pacote, ou seja, poderão ser referenciados apenas pelos componentes definidos dentro do body.
	 De forma contrária, o que é definido no ESPECIFICATION poderá ser acessado publicamente. */
	
-- CRIAÇÃO DO PACKAGE SPECIFICATION
CREATE OR REPLACE PACKAGE employee_package IS
	PROCEDURE prc_lista_funcionarios;
	FUNCTION fnc_calcula_comissao(pEmployee_id NUMBER) RETURN NUMBER;
	FUNCTION fnc_get_salario_empregado(pEmployee_id NUMBER) RETURN NUMBER;
END employee_package;

-- CRIAÇÃO DO PACKAGE BODY: IMPLEMENTA O SPECIFICATION
CREATE OR REPLACE PACKAGE BODY employee_package IS
	PROCEDURE prc_lista_funcionarios IS
		CURSOR c1 IS  -- Lembrar de testar essa procedure depois com REF CURSOR.
			SELECT e.employee_id, e.first_name, 
						 d.department_name, 
						 e.job_id, 
						 e.salary
				FROM employees e, departments d
			 WHERE e.department_id = d.department_id
			 ORDER BY d.department_name, e.first_name;
	BEGIN
		FOR r1 IN c1 LOOP
			dbms_output.PUT_LINE(r1.employee_id || ' - ' || r1.first_name || ', ' || r1.department_name || ', ' || r1.job_id || ', ' || r1.salary);
		END LOOP;

		EXCEPTION
			WHEN no_data_found THEN
				RAISE_APPLICATION_ERROR(-20001, 'Nenhum empregado encontrado');
			WHEN OTHERS THEN
				RAISE_APPLICATION_ERROR(-20002, 'Erro ao consultar empregados.');
	END prc_lista_funcionarios;
	--------------------------

	FUNCTION fnc_calcula_comissao(pEmployee_id NUMBER) RETURN NUMBER IS
		vSalary 	  NUMBER;
		vCommission NUMBER;
	BEGIN
		SELECT NVL(salary, 0), NVL(commission_pct, 0)
			INTO vSalary, vCommission
			FROM employees
		 WHERE employee_id = pEmployee_id;
		 RETURN vSalary * vCommission;

		EXCEPTION
			WHEN no_data_found THEN
				RAISE_APPLICATION_ERROR(-20001, 'Nenhum empregado encontrado');
			WHEN OTHERS THEN
				RAISE_APPLICATION_ERROR(-20002, 'Erro ao consultar empregados.');		
	END fnc_calcula_comissao;
	-------------------------

	FUNCTION fnc_get_salario_empregado(pEmployee_id NUMBER) RETURN NUMBER IS
		vSalario NUMBER;
	BEGIN
		SELECT salary INTO vSalario
			FROM employees
		 WHERE employee_id = pEmployee_id;
		RETURN vSalario;

		EXCEPTION
			WHEN no_data_found THEN
				RAISE_APPLICATION_ERROR(-20001, 'Nenhum empregado encontrado');
			WHEN OTHERS THEN
				RAISE_APPLICATION_ERROR(-20002, 'Erro ao consultar empregados.');	
	END fnc_get_salario_empregado;
	
-- Antes de o Oracle executar QUALQUER componente do PACKAGE BODY, primeiro ele irá executar o que está definido entre o BEGIN e END da package.
-- Essa funcionalidade permite inicializar variáveis ou executar procedimentos uma única vez, na inicialização da PACKAGE.
BEGIN
	-- Código a ser executado antes da primeira execução de qualquer procedimento da package.
END employee_package;

-- Referenciando os componentes de um PACKAGE
DECLARE
  vSalary NUMBER;
BEGIN
  vSalary := employee_package.fnc_calcula_comissao(3000);
  dbms_output.PUT_LINE(vSalary);
	
  employee_package.prc_lista_funcionarios;

  vSalary := employee_package.fnc_get_salario_empregado(173);
  dbms_output.PUT_LINE(vSalary);
END;
------------------------

-- Recompilar uma package
ALTER PACKAGE employee_package COMPILE SPECIFICATION;
ALTER PACKAGE employee_package COMPILE BODY;

-- Remover uma package
DROP PACKAGE BODY employee_package; -- Remove apenas o body
DROP PACKAGE employee_package; -- Remove specification e body


/* VANTAGENS do uso de PACKAGES 
 - Agrupamento de procedures e funções relacionadas;
 - Modularização da aplicação, permitindo dividir a complexidade do código;
 - Permite a criação de identificadores globais, para uso durante toda a sessão;
 - Performance: Toda a package é colocada na memória a partir do momento em que algum componente é referenciado na na sessão, diminuindo o acesso em disco;
 - Melhor gerenciamento de procedures, funções e triggers, pois estarão armazenadas no mesmo lugar;
 - Gerenciamento de segurança mais simples: Apenas quem tem permissão pode executar procedures e funções. Inclusive, é possível dar permissão de EXECUTE na package inteira; */
