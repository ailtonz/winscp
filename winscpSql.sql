-- ######################
-- CONFIGURAÇÕES
-- ######################
--,@Cmd                                 VARCHAR(500)='winscp.com /script=WinSCP.cfg'
declare @return_value      INT
,@AppName                       VARCHAR(255)='winscp.com'
,@Filename                      VARCHAR(255)='WinSCP.cfg'
,@Path                          VARCHAR(255)='C:\app\WinSCP\'
,@PathWorking              		VARCHAR(255)='\\0.0.0.0\e\sftp_files\FTP_User\LOTES\'
,@Cmd                           VARCHAR(500)=''
,@sUserName                     VARCHAR(255)='Transitorio_FTP'
,@sUserPassword                 VARCHAR(255)='2Uku*?guytq.!'
,@sServerIP                     VARCHAR(255)='ftp.dominio.com:990'
,@sServerPath              		VARCHAR(255)='/Transitorio'
,@sFile                         VARCHAR(255)='*.*'

-- ######################
-- ARQUIVOS DE SAIDA
-- ######################
declare --@bat             varchar(2000)='winscp.com /script=WinSCP.cfg'
@cfg                       varchar(2000)='
option batch abort
option confirm off
option transfer binary
open ftps://sUserName:sUserPassword@sServerIP/ -passive=on

cd sServerPath

lcd sPath\

get sFile

mv sFile /Transitorio/bkp/

close
exit'

set @cfg=replace(@cfg,'sUserName',@sUserName)
set @cfg=replace(@cfg,'sUserPassword',@sUserPassword)
set @cfg=replace(@cfg,'sServerIP',@sServerIP)
set @cfg=replace(@cfg,'sServerPath',@sServerPath)
set @cfg=replace(@cfg,'sFile',@sFile)
set @cfg=replace(@cfg,'sPath',@PathWorking)

-- Criação de comando
EXEC   @return_value = [ADM].[spWriteStringToFile]
			@String = @cfg,
			@Path = @Path,
			@Filename = @Filename

SET @Cmd = @Path +'\'+ @AppName + ' /script='+@Path +'\'+@Filename

-- Saida em console para analise
-- print @Cmd

-- Execução da aplicação
EXEC xp_cmdshell @Cmd


/*** Procedure auxiliar para saida de arquivo

alter PROCEDURE spWriteStringToFile
 (
@String Varchar(max), --8000 in SQL Server 2000
@Path VARCHAR(255),
@Filename VARCHAR(100)

--
)
AS
DECLARE  @objFileSystem int
        ,@objTextStream int,
		@objErrorObject int,
		@strErrorMessage Varchar(1000),
	    @Command varchar(1000),
	    @hr int,
		@fileAndPath varchar(80)

set nocount on

select @strErrorMessage='opening the File System Object'
EXECUTE @hr = sp_OACreate  'Scripting.FileSystemObject' , @objFileSystem OUT

Select @FileAndPath=@path+'\'+@filename
if @HR=0 Select @objErrorObject=@objFileSystem , @strErrorMessage='Creating file "'+@FileAndPath+'"'
if @HR=0 execute @hr = sp_OAMethod   @objFileSystem   , 'CreateTextFile'
	, @objTextStream OUT, @FileAndPath,2,True

if @HR=0 Select @objErrorObject=@objTextStream, 
	@strErrorMessage='writing to the file "'+@FileAndPath+'"'
if @HR=0 execute @hr = sp_OAMethod  @objTextStream, 'Write', Null, @String

if @HR=0 Select @objErrorObject=@objTextStream, @strErrorMessage='closing the file "'+@FileAndPath+'"'
if @HR=0 execute @hr = sp_OAMethod  @objTextStream, 'Close'

if @hr<>0
	begin
	Declare 
		@Source varchar(255),
		@Description Varchar(255),
		@Helpfile Varchar(255),
		@HelpID int
	
	EXECUTE sp_OAGetErrorInfo  @objErrorObject, 
		@source output,@Description output,@Helpfile output,@HelpID output
	Select @strErrorMessage='Error whilst '
			+coalesce(@strErrorMessage,'doing something')
			+', '+coalesce(@Description,'')
	raiserror (@strErrorMessage,16,1)
	end
EXECUTE  sp_OADestroy @objTextStream
EXECUTE sp_OADestroy @objFileSystem

*/