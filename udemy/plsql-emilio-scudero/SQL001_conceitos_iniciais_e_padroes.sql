/* Características iniciais da linguagem PLSQL (Sessões 01 até 07)
 - É uma linguagem procedural que permite a utilização de comandos SQL para manipulação dos dados.
 - Propriedade da Oracle, ou seja, só está disponível nos produtos Oracle.
 - Simples e fácil de aprender, permitindo também a construção de programas complexos e poderosos.
 - Estende as capacidades e funcionalidades do SQL, fornecendo ferramentas de desenvolvimento, utilizadas também em outras linguagens de programação.
 
 - Em um bloco PLSQL, comandos SQL são executados pelo SQL Statement Executor, enquanto os comandos PLSQL são executados pelo PROCEDURAL STATEMENT EXECUTOR.
 - Ambos estão contidos no PLSQL ENGINE, existente nos bancos de dados Oracle ou ferramentas Oracle como Oracle Forms e Oracle report.
 
	A execução de BLOCOS PLSQL, seja como blocos anônimos, procedures, functions ou triggers, fornece melhor performance para o banco de dados,
	visto que reduz o tráfego na rede, com a diminuição do número de requisições para recuperar informações do banco de dados.
	
	Outro benefício é a integração de dados, pois programas armazenados diretamente no banco de dados podem ser acessados através de outros programas,
	Por exemplo, podem haver pacotes armazenados diretamente no banco de dados, que podem ser acessados pelo Oracle Forms e Oracle Report.
	
	Outra característica que vigora quando utiliza-se programas armazenados é a segurança, tendo em vista que não há a necessidade de dar permissões
	de execução de comandos SELECT's ou comandos DML, necessitando dar permissão apenas para o programa armazenado.
*/

/* Entendendo um BLOCO ANÔNIMO 
 - Contém a sessão DECLARE, opcionalmente utilizada, para declaração de variáveis, tipos de dados, cursores.
 - Sessão BEGIN - END, onde as operações de bancos de dados são utilizadas de fato
 - Opcionalmente e altamente recomendável, a sessão EXCEPTION, utilizada DENTRO DA SESSÃO BEGIN, ao final e antes do END, para tratamento de erros
*/
DECLARE
	vTexto VARCHAR(100);
BEGIN
	vTexto := 'Bem vindo ao PLSQL, bixão! Manda um Hello World aí, pra não ter erro!!';
	dbms_output.PUT_LINE(vTexto);
	
	EXCEPTION 
		WHEN OTHERS THEN
		dbms_output.PUT_LINE(SQLERRM);
END;

DECLARE 
	vNumero1 NUMBER(11,2) := 500;
	vNumero2 NUMBER(11,2) := 400;
	vSoma		 NUMBER(11,2);
BEGIN
	vSoma := vNumero1 + vNumero2;
	dbms_output.PUT_LINE(vSoma);
	EXCEPTION
		WHEN OTHERS THEN
			dbms_output.PUT_LINE(SQLERRM);
END;

-- As variáveis permitem alocar em memória, temporariamente, valores para manipulação dos programas PLSQL.
-- São definidas através do uso de IDENTIFICADORES, que devem possuir no máximo 30 caracteres e não podem utilizar identificadores predefinidos do ORACLE.
DECLARE
  data1 DATE;
  data2 DATE;
  data3 DATE;
  data4 DATE;
  booleano  BOOLEAN;
BEGIN
  data1 := TO_DATE('17/08/2021');
  data2 := TO_DATE('17/08/21');
  
  data3 := '17/08/2021';
  data4 := '17/08/21';
  
  booleano := TRUE;
  
  dbms_output.PUT_LINE(data1);
  dbms_output.PUT_LINE(data2);
  dbms_output.PUT_LINE(data3);
  dbms_output.PUT_LINE(data4);
  IF booleano THEN
    dbms_output.PUT_LINE('true');
  ELSE
    dbms_output.PUT_LINE('false');
  END IF;  
END;

-- De forma similar às variáveis, CONSTANTES também são definidas através do uso de IDENTIFICADORES, e tem as mesmas regras para nomenclatura.
-- A diferença entre elas é que uma constante não tem seu valor alterado durante a execução do programa.
DECLARE
	VPI CONSTANT NUMBER(38, 15) := 3.1415953515682;
BEGIN
	dbms_output.PUT_LINE(vPI);
  
  -- Não é possível atribuir novo valor à constante. A operação abaixo irá ocasionar erro.
  VPI := 10;
  dbms_output.PUT_LINE(VPI);
END;

/* TIPOS DE DADOS EM PLSQL*/

-- NUMBER: Valores numéricos que podem ou não ter casas decimais, limitando-se ao número máximo de 38 dígitos.
number1 NUMBER(8,2) := 10.3;
number2 NUMBER(11) 	:= 11; -- Valores inteiros.

-- LONG: Strings de caractere
longText LONG := 'Texto com long';

-- LONG RAW: Valores binários (documentos, arquivos, imagens, vídeos)
-- Valores binários não podem ser armazenados em variáveis, portanto devem ser convertidos para RAW.
longRaw  LONG RAW := HEXTORAW('43'||'41'||'52');

-- ROWID: Endereço lógico de uma linha de uma tabela (Tem o tamanho de 18 caracteres)
vRowID ROWID;

-- DATE: Data completa, contendo hora, minuto e segundo
vData1 DATE := SYSDATE;
vData2 DATE := '17/08/2022';

-- TIMESTAMP: Também armazena data, porém a precisão dos segundos após o decimal é até 9 dídigos maior;
vData3 TIMESTAMP := SYSTIMESTAMP;
vData4 TIMESTAMP(3) := SYSTIMESTAMP;

-- TIMESTAMP WITH TIME ZONE: Data armazenada com o TIMEZONE do banco de dados
vData5 TIMESTAMP := TIMESTAMP WITH TIME ZONE;

-- TIMESTAMP WHITH LOCAL TIME ZONE: Data armazenada com o TIMEZONE do ClIENT 
vData6 TIMESTAMP WITH LOCAL TIME ZONE := SYSTIMESTAMP;

-- BINARY_INTEGER: Armazena números inteiros, com performance melhor do que NUMBER, pois gasta apenas 4bytes, armazenando menos espaço e memória
num1Binary BINARY_INTEGER := 14;

-- BINARY_DOUBLE(64 bits) e BINARY_FLOAT (32 bits): Utiliza menos espaço e memória e utiliza a notação de ponto flutuante, diferente do NUMBER que utiliza a notação decimal.
DECLARE
  num1 NUMBER(8,2) := 8.2;
  num2 DOUBLE(8,2) := 10.2;
  num3 FLOAT(5,2) := 10.3;
  num4 BINARY_FLOAT  := 10.82;
  num5 BINARY_DOUBLE := 11.323;
BEGIN
  dbms_output.PUT_LINE(num1);
  dbms_output.PUT_LINE(num2);
  dbms_output.PUT_LINE(num3);
  dbms_output.PUT_LINE(num4);
  dbms_output.PUT_LINE(num5);
END;  

-- É possível definir uma variável por referência, através do atributo %TYPE, de qualquer tipo de dados
vDepartment_id departments.department_id%TYPE;
vEmployee_name employees.first_name%TYPE;

-- Variáveis do tipo BIND são utilizadas externamente ao bloco PLSQL e são utilizadas para passagem de parâmetros.
-- São declaradas externamente ao BLOCO PLSQL que irá utilizá-la, podendo também serem declaradas ou ter seu valor atribuído em tempo de execução.
VARIABLE vBind1 NUMBER;
VARIABLE vBind2 NUMBER;
BEGIN
	:vBind1 := 10 + 20 + 30 + 40;
	:vBind2 := &vBind2;
	dbms_output.PUT_LINE('Soma: ' || :vBind1);
	dbms_output.PUT_LINE('vBind2: ' || :vBind2);
	dbms_output.PUT_LINE('Quem está escrevendo? ' || '&vSubstituicao');
END;

/* Existem algumas regras de limitação de escopo no que tange a declaração e utilização das variáveis.
 - Um bloco poderá ter um ou mais sub blocos e cada sub bloco poderá ter sua declaração de variáveis independente.
 - As variáveis tem seu escopo visível apenas no bloco em que foi declarada e nos blocos filhos.
 - Variáveis declaradas em um bloco INTERNO não podem ser acessadas de um bloco externo, pois seu ciclo de vida é encerrado na finalização do bloco interno.
*/

DECLARE
	vBloco1 VARCHAR2(30) := 'Variável bloco 1';
BEGIN
	dbms_output.PUT_LINE('Bloco 1: ' || vBloco1);
	
	DECLARE
		vBloco2 VARCHAR2(30) := 'Variável bloco 2';
	BEGIN
		dbms_output.PUT_LINE('Referenciando bloco 1 dentro do bloco 2: ' || vBloco1);
		dbms_output.PUT_LINE('Bloco 2: ' || vBloco2);
	END;
	
	dbms_output.PUT_LINE('Fim do bloco 1: ' || vBloco1);
	
	-- Esta linha ocasiona erro, pois a variável de bloco 2 não está visível no bloco externo.
	-- dbms_output.PUT_LINE('Variável bloco 2: ' || vBloco2);
	
	EXCEPTION 
		WHEN OTHERS THEN
			dbms_output.PUT_LINE(SQLERRM);
END;

-- Observar os padrões de desenvolvimento, como identação e nomenclaturas de variáveis, com prefixos para cada tipo e palavras chave.