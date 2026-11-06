/*
==============================================================
 Name           : check-databases-without-recent-backup
 Description    : Lista bancos sem backup Full/Log dentro do limite
 Category       : 02-Backup and Recovery
 Version SQL    : SQL Server 2008 R2+
 Permissions    : Leitura no msdb e sys.databases
 Parameters     : @LimiteFull (horas), @LimiteLog (horas)
 Impact         : Somente leitura, sem risco
 Author/Date    : [DBA Felipe Xavier] - [28-10-2025]
==============================================================
*/
DECLARE @LimiteFull INT = 24;
DECLARE @LimiteLog  INT = 2;

SELECT
    db.name AS [Banco de Dados],
    db.recovery_model_desc AS [Recovery Mode],
    MAX(CASE WHEN bs.type = 'D' THEN bs.backup_finish_date END) AS [Most recent Full],
    MAX(CASE WHEN bs.type = 'I' THEN bs.backup_finish_date END) AS [Most recent Differential],
    MAX(CASE WHEN bs.type = 'L' THEN bs.backup_finish_date END) AS [Most recent Log],
    CASE
        WHEN MAX(CASE WHEN bs.type = 'D' THEN bs.backup_finish_date END) IS NULL
            THEN 'NEVER PERFORMED FULL - CRITICAL'
        WHEN DATEDIFF(HOUR, MAX(CASE WHEN bs.type = 'D' THEN bs.backup_finish_date END), GETDATE()) > @LimiteFull
            THEN 'FULL LATE'
        WHEN db.recovery_model_desc = 'FULL'
             AND MAX(CASE WHEN bs.type = 'L' THEN bs.backup_finish_date END) IS NULL
            THEN 'NEVER PERFORMED LOG - CRITICAL'
        WHEN db.recovery_model_desc = 'FULL'
             AND DATEDIFF(HOUR, MAX(CASE WHEN bs.type = 'L' THEN bs.backup_finish_date END), GETDATE()) > @LimiteLog
            THEN 'LOG OVERDUE'
        ELSE 'OK'
    END AS [Status]
FROM sys.databases db
LEFT JOIN msdb.dbo.backupset bs ON db.name = bs.database_name
WHERE db.name <> 'tempdb'
  AND db.state_desc = 'ONLINE'
GROUP BY db.name, db.recovery_model_desc
ORDER BY db.name;
GO
