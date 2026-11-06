/*
==============================================================
 Name           : check-databases-without-recent-backup
 Description    : Lista bancos sem backup Full/Log dentro do limite
 Category       : 02-Backup and Recovery
 Version SQL    : SQL Server 2008 R2+
 Permissions    : Leitura no msdb e sys.databases
 Parameters     : @Database, @File
 Impact         : Read-only, no risk
 Author/Date    : [DBA Felipe Xavier] - [01-11-2026]
==============================================================
*/

DECLARE @Database   SYSNAME       = N'nome_do_banco'; --database name
DECLARE @File NVARCHAR(500) = N'C:\Backup\nome_do_banco_DIFF.bak'; -- path to backup on disk

BACKUP DATABASE @Database
  TO DISK = @File
  WITH DIFFERENTIAL, INIT, COMPRESSION, STATS = 15, CHECKSUM;
GO
