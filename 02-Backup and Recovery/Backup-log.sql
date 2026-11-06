/*
==============================================================
 Name           : Backup Log
 Description    : Lista bancos sem backup Full/Log dentro do limite
 Category       : 02-Backup and Recovery
 Version SQL    : SQL Server 2008 R2+
 Permissions    : Leitura no msdb e sys.databases
 Parameters     : @LimiteFull (horas), @LimiteLog (horas)
 Impact         : Creates a file on disk and frees up reusable space in the log. 
                  Only works under the FULL or BULK_LOGGED recovery model, provided a full backup has been performed.
 Author/Date    : [DBA Felipe Xavier] - [30-10-2025]
==============================================================
*/
DECLARE @Database   SYSNAME       = N'database_name';  --database name
DECLARE @File NVARCHAR(500) = N'[path].trn'; -- path to backup file on a disk

BACKUP LOG @Database
  TO DISK = @File
  WITH INIT, COMPRESSION, STATS = 15;
GO
