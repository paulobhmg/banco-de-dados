/* GERENCIAMENTO DE DEPENDÊNCIAS EM OBJETOS
 - As dependências podem ser DIRETAS, quando fazem referência direta ao objeto, ou INDIRETA, quando depende de um objeto através de ouro objeto.
 - No sentido de ambiente, podem ser LOCAIS, quando a dependência é entre objetos do mesmo banco de dados, ou REMOTAS, quando a dependência é entre objetos de bancos de dados distintos.
 
 ** É altamente recomendável SEMPRE que houver alteração em objetos (procedures, functions), recompilar e verificar todas as dependências daquele objeto
    a fim de evitar erros na execução dos programas devido à invalidez dos objetos.
	
 ** As dependências diretas e indiretas podem ser visualizadas nas views USER_DEPENDENCIES, ALL_DEPENDENCIES e DBA_DEPENDENCIES  */
 
-- Este comando analisa apenas as dependências DIRETAS entre objetos.
SELECT name, -- nome do objeto dependência
			 type, -- tipo do objeto dependência
			 referenced_name,  -- nome do objeto ao qual o objeto faz referência
			 referenced_owner, -- nome do dono do objeto
			 referenced_type   -- tipo do objeto ao qual este objeto depende
  FROM user_dependencies
 WHERE referenced_owner = 'HR'
   AND referenced_type = 'TABLE'
 ORDER BY type, referenced_name;
 
-- Listagem de todas as dependências, com hierarquia
SELECT *  
  FROM user_dependencies
 START WITH referenced_name = 'EMPLOYEES' 
        AND referenced_type = 'TABLE'
 CONNECT BY PRIOR name = referenced_type 
              AND type = referenced_type;
							
-- A visão USER_OBJECTS permite também visualizar se um objeto está com status inválido
SELECT object_name,
       object_type,
       created,
       timestamp,
       last_ddl_time,
       status
  FROM user_objects
 ORDER BY object_type, object_name;
----------------------------------------

/* DEBUGANDO PROCEDURES E FUNCTIONS
 - Necessário GRANT dos privilégios: DEBUG CONNECT SESSION e DEBUG ANY PROCEDURE
 - O usuário deverá ser o OWNER ou possuir privilégio EXECUTE para efetuar debug
 - A procedure ou function a ser debugada deve ser compilada para DEBUG. */
 
-- Ainda, para as versões do Oracle a partir da 12c é necessário configurar o acesso ao JDWP, quando utilizamos DEBUG's JAVA.
BEGIN
	dbms_network_acl_admin.APPEND_HOST_ACE(
		host => '127.0.0.1',
		lower_port => NULL,
		upper_port => NULL,
		ace => xs$ace_type(
      privilege_list => xs$name_list('jdwp'),
      principal_name => 'hr',
      principal_type => xs_acl.ptype_db));
END;
 
 