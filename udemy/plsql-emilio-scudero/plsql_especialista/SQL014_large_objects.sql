/* LARGE OBJECTS são utilizados para armazenar objetos grandes no banco de dados e permitem armazenar dados desestruturados.
 - Dados desestruturados podem ser imagens, vídeos, sons, áudios, arquivos PDF, arquivos de texto.
 - Os LOBS podem ser acessados por linguagens externas como JAVA, PHP, PYTHON.
 
 ** Categoria dos LOBS:
  - Internos: Estão armazenados no banco de dados. As transações e COMMITs efetuados irão alterar seu status no banco de dados.
		- CLOB:  Caracter Large Object: Armazenam strings de caracteres. Textos grandes, com base na lingua configurada no banco de dados.
		- NCLOB: Variante do CLOB, permitindo armazenar strings de várias linguas diferentes (Conjunto de caracteres universal)
		- BLOB:  Binary Large Objects: Armazenam dados binários: Arquivos, fotos, vídeos.
	
	- Externos: Não estão armazenados no banco de dados, contendo apenas um ponteiro apontando para o caminho onde está armazenado em disco. Não participam das transações de bancos de dados.
		- BFILES: Arquivo externo binário - Armazena uma referência à um arquivo binário.
		
 ** LOBS não podem ser utilizados em CLUSTER TABLESPACE
    NÃO podem ser utilizados para o comando Analyse
		Não podem ser utilizados para VARRAY
		Não podem ser utilizados em cláusulas GROUP BY, ORDER BY, SELECT DISTINCT, JOIN, FUNÇÕES DE AGREGAÇÃO
		
 ** Quando referenciamos um LOB INTERNO, o oracle trás um LOB LOCATOR, ou seja, um ponteiro que aponta para a localização atual do LOB.
 ** O locator associado à um LOB EXTERNO é o BFILE LOCATOR. */ 

 
 
 **** Ver o conteúdo sobre esse assunto quando houver necessidade prática de utilização.