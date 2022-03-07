/* ESTRUTURA DE CONTROLE IF THEN ELSE ELIF 
 - Permitem controlar o fluxo ou ordem de execução de código de acordo com uma condição passada como parâmetro
 - É importante atentar-se ao utilizar expressões com valor NULL no bloco IF, pois essas expressões retornam FALSO como resultado do teste lógico.
 */

ACCEPT pDepartmentId PROMPT 'Informe o código do departamento: ';
DECLARE
  vPercentual   NUMBER(5,2);
  vDepartmentId departments.department_id%TYPE := &pDepartmentId;
BEGIN
  IF vDepartmentId = 90 THEN
    vPercentual := 30;
  ELSIF vDepartmentId = 60 THEN
		vPercentual := 20;
	ELSE 
		vPercentual := 10;
  END IF;
  dbms_output.PUT_LINE('Percentual: ' || vPercentual);
  
  UPDATE employees
     SET salary = salary * (1 + vPercentual / 100)
   WHERE department_id = vDepartmentId; 
   dbms_output.PUT_LINE('Salários alterados: ' || sql%ROWCOUNT);
  COMMIT;
END;
SELECT * FROM employees WHERE department_id = 90;

/* ESTRUTURA DE CONTROLE CASE WHEN
 - Similar à estrutura IF, permite alterar o fluxo da aplicação com base no teste de uma ou mais expressões. */
 
-- FORMA 1: Avaliando o valor da expressão
ACCEPT pDepartmentId PROMPT 'ID do departamento: ';

DECLARE
  vDepartmentId departments.department_id%TYPE := &pDepartmentId;
BEGIN
  CASE vDepartmentId
    WHEN 60 THEN
      dbms_output.PUT_LINE('Departmento de TI');
    WHEN 70 THEN
      dbms_output.PUT_LINE('Departamento de relações públicas');
    WHEN 80 THEN
      dbms_output.PUT_LINE('Departamento de vendas');
    ELSE
      dbms_output.PUT_LINE('Departamento qualquer');
  END CASE;
END;

-- FORMA 2: Avaliando várias 
ACCEPT pDepartmentId PROMPT 'ID do departamento: ';

DECLARE
  vDepartmentId departments.department_id%TYPE := &pDepartmentId;
BEGIN
  CASE 
    WHEN vDepartmentId = 10 OR vDepartmentId = 40 THEN
      dbms_output.PUT_LINE('Setor administrativo');
    WHEN vDepartmentId = 60 OR vDepartmentId = 70 THEN
      dbms_output.PUT_LINE('Setor tecnológico');
    WHEN vDepartmentId = 90 OR vDepartmentId = 130 THEN
      dbms_output.PUT_LINE('Setor executivo');
    ELSE
      dbms_output.PUT_LINE('Setor qualquer');
  END CASE;
END;
-------------------------------------------------------------------

/* ESTRUTURAS DE REPETIÇÃO permitem executar um ou mais comandos, repetidas vezes, até que determinada condição seja
   atingida ou que encontre um comando para finalização daquele bloco. */

-- LOOP: É o mais simples, porém necessita de atenção quanto à condição para saída do LOOP e incremento de varáveis, a fim de evitar repetições infinitas.
DECLARE
	vNumero NUMBER := 1;
	vLimite NUMBER DEFAULT &pLimite;
BEGIN
	LOOP
		EXIT WHEN vNumero > vLimite;
		dbms_output.PUT_LINE(vNumero);
		vNumero := vNumero + 1;		
	END LOOP;
END;

-- FOR LOOP: É mais seguro que o anterior, pois cria um índice automático, controlado pelo próprio laço, que será executado N vezes.
DECLARE
  vInicio INTEGER(3) DEFAULT &inicio;
	vLimite NUMBER(3) := &pLimite;
BEGIN
	FOR i IN vInicio..vLimite LOOP
		dbms_output.PUT_LINE(i);
	END LOOP;
END;

-- Esse LOOP permite também reverter a ordem de incremento. Ao utilizar o reverse, deve-se ter bastante atenção para não inverter os parâmetros.
-- A ordem dos parâmetros deve ser a mesma, a diferença é que o loop será executado de frente pra trás, ou de forma decrescente.
DECLARE
	vInicio INTEGER(3) DEFAULT &inicio;
	vLimite NUMBER(3) := &pLimite;
BEGIN
	FOR i IN REVERSE vInicio..vLimite LOOP
		dbms_output.PUT_LINE(i);
	END LOOP;
END;

-- WHILE LOOP: É o mais clássico. Neste, uma variável de controle deverá ser declarada antes de entrar no LOOP e incrementada dentro dele.
-- Assim como o LOOP simples, este requer atenção quanto à condição para saída do LOOP e o incremento da variável de controle, a fim de evitar loop infinito.

DECLARE
	vNumero INTEGER(3) DEFAULT 1;
	vLimite NUMBER(3) := &pLimite;
BEGIN
	WHILE vNumero <= vLimite LOOP
		dbms_output.PUT_LINE(vNumero);
		vNumero := vNumero + 1;
	END LOOP;
END;

-- Assim como nos outros LOOPS, é possível utilizar o EXIT WHEN para finalizar o laço.
DECLARE
	vNumero INTEGER(3) DEFAULT 1;
	vLimite NUMBER(3) := &pLimite;
BEGIN
	WHILE TRUE LOOP
		EXIT WHEN vNumero > vLimite;
		dbms_output.PUT_LINE(vNumero);
		vNumero := vNumero + 1;
	END LOOP;
END;

-- Neste LOOP não temos o REVERSE. Para fazer com que o loop execute de forma contrária, é necessário utilizar a lógica mesmo.
DECLARE
	vNumero INTEGER(3) DEFAULT &pNumero;
	vLimite NUMBER(3) := &pLimite;
BEGIN
	WHILE vNumero >= vLimite LOOP
		dbms_output.PUT_LINE(vNumero);
		vNumero := vNumero -1;
	END LOOP;
END;

-- É possível ainda aninhar vários LOOPs de forma encadeada, permitindo sair de um LOOP, ou até todos os loops, caso estejam nomeados por labels.
DECLARE
	vTotal NUMBER(38) DEFAULT 1;
BEGIN
  -- Neste primeiro exemplo, não saímos do loop por condição predefinida
	FOR i IN 1..8 LOOP
		dbms_output.PUT_LINE('I: ' || i || ' - Total: ' || vTotal);
		FOR j IN 1..8 LOOP 
			dbms_output.PUT_LINE('J: ' || j || ' - Total: ' || vTotal);
			vTotal := vTotal * 2;
		END LOOP;
	END LOOP;
	dbms_output.PUT_LINE('Total Final: ' || vTotal);
END;

DECLARE
	vTotal NUMBER(38) DEFAULT 1;
BEGIN
  -- Neste segundo exemplo, será definido um valor limite, que fará com que ao atingir determinado valor, encerre os dois LOOPs.
	-- Vale ressaltar que o EXIT LOOP1 fará com que saia imediatamente do LOOP interno e também do LOOP externo, neste caso, LOOP1.
	<<LOOP1>>
	FOR i IN 1..8 LOOP
		dbms_output.PUT_LINE('I: ' || i || ' - Total: ' || vTotal);
		<<LOOP2>>
		FOR j IN 1..8 LOOP 
			EXIT LOOP1 WHEN vTotal > 15000000;
			dbms_output.PUT_LINE('J: ' || j || ' - Total: ' || vTotal);
			vTotal := vTotal * 2;
		END LOOP;
	END LOOP;
	dbms_output.PUT_LINE('Total Final: ' || vTotal);
END;