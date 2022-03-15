/* A package DMBS_SCHEDULER possui um conjunto de funções e procedimentos que permitem o agendar jobs, de acordo com uma agenda.
 - Componentes da package
   Program: Coleção de metadados sobre o qual será executado pelo Schedular
	          Os tipos de programas podem ser PLSQL_BLOCK, STORED_PROCEDURE ou EXECUTABLE	
   Schedule: A agenda, que especifica data e momento da execução de um progam, tal como o período de intervalo e número de repetições.
   Job: É a tarefa que será executada, que deverá ser vinculada à um programa e agenda.	 
	      Um JOB só poderá ser executado se o programa vinculado à ele estiver com o status habilitado.
 * De forma bem resumida, uma tarefa agendada basicamente é um PROGRAM que contém as informações de um JOB
   que será executado N vezes, conforme os parâmetros defindos em um SCHEDULE.
*/

-- Para que um usuário possa criar JOBS, é necessário uma das permissões abaixo:
GRANT CREATE JOB TO hr;
GRANT CREATE ANY JOB TO hr;

-- Ao criar um programa, por padrão seu status é DISABLE, ou seja, o atributo ENABLED é FALSE. 
-- Para defini-lo como habilitado no momento da sua definição, basta passar como parâmetro o campo ENABLED como TRUE. Abaixo a sintaxe para criação de um PROGRAM
dbms_scheduler.CREATE_PROGRAM(
	program_name   VARCHAR2,
	program_type   VARCHAR2,
	program_action VARCHAR2,
	number_of_arguments BINARY_INTEGER DEFAULT 0,
	enabled BOOLEAN,
	comments VARCHAR2 DEFAULT NULL
);

-- Também é possível habilitar ou desabilitar um PROGRAM através de procedures do próprio pacote DBMS_SCHEDULER, passando como parâmetro o nome do PROGRAM.
dbms_scheduler.ENABLE(program_name);
dbms_scheduler.DISABLE(program_name);

-- Para dropar um PROGRAM, é possível passar opcionalmente um segundo parâmetro, FORCE, como true ou false. 
-- Esse parâmetro, caso seja TRUE, removerá o PROGRAM mesmo que ele esteja sendo referenciado ou vinculado à um job ou agenda.
dbms_scheduler.DROP_PROGRAM(program_name, FALSE);
--------------------------------------------

-- Tabelas e PROCEDURES para exemplos
CREATE TABLE agenda_job(
	agenda_id INTEGER,
	data_exec DATE
);

CREATE SEQUENCE agenda_job_seq 
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE
NOMAXVALUE;

CREATE OR REPLACE PROCEDURE prc_insere_agenda IS
BEGIN
	INSERT INTO hr.agenda_job
	VALUES (hr.agenda_job_seq.NEXTVAL, SYSDATE);
	COMMIT;
END;

-- Program que deverá ser vinculado ao JOB
BEGIN
	dbms_scheduler.CREATE_PROGRAM(
		program_name   => 'HR.INSERE_NOVA_AGENDA',
		program_action => 'HR.PRC_INSERE_AGENDA',
		program_type   => 'STORED_PROCEDURE',
		number_of_arguments => 0,
		enabled => TRUE,
		comments => 'Programa que insere um novo lançamento na tabela de agendamento.'
	);
END;
---------------------------------------------

-- SINTAXE para criação de uma agenda
dbms_scheduler.CREATE_SCHEDULE(
	schedule_name   IN VARCHAR2,
	start_date      IN TIMESTAMP WITH TIMEZONE DEFAULT NULL,
	repeat_interval IN VARCHAR2,
	end_date		    IN TIMESTAMP WITH TIMEZONE DEFAULT NULL,
	comments IN VARCHAR2 DEFAULT NULL
);

/* O parâmetro REPEAT_INTERVAL é composto por 3 etapas:
 1° Frequência (YEARLY, MONTHLY, WEEKLY, DAILY, HOURLY, MINUTELY, SECONDLY)
 2° Intervalo de repetição (Número de 1 a 99)
 3° Frequência (BYMONTH, BYWEEKNO, BYYEARDAY, BYMONTHDAY, BYDAY, BYHOUR, BYMINUTE, BYSECOND) */

-- Exemplo de SCHEDULE que irá repetir mensalmente, no dia 20.
BEGIN
  dbms_scheduler.CREATE_SCHEDULE(
	schedule_name   => 'HR.LANCA_AGENDA_MENSALMENTE_NO_DIA_20',
	start_date 		  => SYSTIMESTAMP,
	repeat_interval => 'FREQ=MONTHLY;BYMONTHDAY=20',
	comments => 'Efetua o lançamento do agendamento mensalmente.',
  end_date => NULL
);

-- Exemplo de SCHEDULE que irá repetir a cada 60 dias
dbms_scheduler.CREATE_SCHEDULE(
	schedule_name   => 'HR.LANCA_AGENDA_A_CADA_60_DIAS',
	start_date 		  => SYSTIMESTAMP,
	repeat_interval => 'FREQ=DAILY;INTERVAL=60',
	comments => 'Efetua o lançamento do agendamento mensalmente.',
	end_date => NULL
);

-- Exemplo de SCHEDULE que irá repetir a cada 1 minuto
BEGIN
  dbms_scheduler.CREATE_SCHEDULE(
    schedule_name   => 'HR.LANCA_AGENDA_POR_MINUTO',
    start_date 	    => SYSTIMESTAMP,
    repeat_interval => 'FREQ=MINUTELY;INTERVAL=1',
    comments => 'Efetua o lançamento do agendamento a cada minuto.',
    end_date => NULL
  );
END;

-- Assim como um PROGRAM, a mesma sintaxe é utilizada para REMOVER um SCHEDULE
dbms_scheduler.DROP_SCHEDULE(
	schedule_name => 'HR.LANCA_AGENDA_A_CADA_60_DIAS', 
	force 				=> FALSE
);
------------------------------------------------

-- SINTAXE para criação de um JOB, quando já existe um PROGRAM e um SCHEDULE criados.
dbms_scheduler.CREATE_JOB(
	job_name 	 	  IN VARCHAR2,
	program_name  IN VARCHAR2,
	schedule_name IN VARCHAR2,
	enabled  			IN BOOLEAN,
	auto_drop 		IN BOOLEAN,
	comments 			IN VARCHAR2,
	job_style			IN VARCHAR2
);

-- Quando não temos PROGRAM e SCHEDULE definidos, é possível criar um JOB passando todas as definições
dbms_scheduler.CREATE_JOB(
	job_name 						IN VARCHAR2,
	program_type 				IN VARCHAR2,
	program_action 			IN VARCHAR2,
	number_of_arguments IN PLS_INTEGER DEFAULT 0,
	start_date 					IN TIMESTAMP WITH TIMEZONE DEFAULT NULL,
	repeat_interval 		IN VARCHAR2,
	end_date 						IN TIMESTAMP WITH TIMEZONE DEFAULT NULL
);

-- Interromper a execução do JOB
dbms_scheduler.STOP_JOB(job_name => , force => TRUE);

-- Visões - JOBS
USER_SCHEDULER_JOB_ARGS; -- Argumentos configurados para todos os JOBS
USER_SCHEDULER_JOB_LOG;  -- Informações de logs de todos os jobs
USER_SCHEDULER_JOB_RUN_DETAILS; -- Detalhes de execuções de jobs
USER_SCHEDULER_JOBS; -- Lista de jobs agendados

-- Criando um JOB
dbms_scheduler.CREATE_JOB(
	job_name 		  => 'HR.JOB_NOVA_AGENDA',
	program_name  => 'HR.INSERE_NOVA_AGENDA',
	schedule_name => 'HR.LANCA_AGENDA_POR_MINUTO',
	enabled 			=> TRUE,
	auto_drop 		=> FALSE, -- REMOVE O DROP APÓS A EXECUÇÃO
	job_style 		=> 'REGULAR',
	comments 		  => 'Tarefa que será executada para o lançamento na tabela agenda_job'
);

SELECT agenda_id,TO_CHAR(data_exec, 'DD/MM/YYYY HH24:MI:SS') data_exec FROM agenda_job order by agenda_id;

dbms_scheduler.STOP_JOB( -- Necessário privilégios especiais para usar esse comando
	job_name => 'HR.JOB_NOVA_AGENDA',
	force => TRUE
);
