/*
==============================================================
 Name           : check-databases-without-recent-backup
 Description    : Lista bancos sem backup Full/Log dentro do limite
 Category       : 02-Backup and Recovery
 Version SQL    : SQL Server 2008 R2+
 Permissions    : Leitura no msdb e sys.databases
 Parameters     : @LimiteFull (horas), @LimiteLog (horas)
 Impact         : Somente leitura, sem risco
 Author/Date    : [DBA Felipe Xavier] - [30-10-2025]
==============================================================
*/
DECLARE @Database   SYSNAME       = N'nome_do_banco'; -- database name
DECLARE @File NVARCHAR(500) = N'[path].bak'; -- path to backupo file on a disk

BACKUP DATABASE @Database
  TO DISK = @File
  WITH INIT, COMPRESSION, STATS = 15, CHECKSUM;
GO
