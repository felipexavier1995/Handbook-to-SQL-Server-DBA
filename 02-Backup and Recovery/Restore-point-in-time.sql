/*
==============================================================
 Nome        : restore-point-in-time
 Descrição   : Restore até um ponto no tempo (STOPAT), por exemplo
               imediatamente antes de um DELETE/UPDATE acidental
 Categoria   : 02-Backup and Recovery
 Versão SQL  : SQL Server 2008 R2+
 Permissões  : sysadmin ou dbcreator
 Parâmetros  : @Banco, @PontoNoTempo, arquivos da cadeia
 Impacto     : SUBSTITUI o banco de destino (REPLACE).
               Exige modelo FULL (ou BULK_LOGGED sem operações bulk
               no intervalo) e a cadeia de logs sem falhas.
               Recomendado restaurar com outro nome e validar antes.
 Autor/Data  : [seu nome] - [data]
==============================================================
*/
DECLARE @Banco        SYSNAME  = N'nome_do_banco_restaurado';
DECLARE @PontoNoTempo DATETIME = '2026-11-06 14:30:00';  -- horário do servidor

-- 1) FULL
RESTORE DATABASE @Banco
  FROM DISK = N'C:\Backup\nome_do_banco_FULL.bak'
  WITH NORECOVERY, REPLACE, STATS = 10;

-- 2) DIFERENCIAL (opcional)
RESTORE DATABASE @Banco
  FROM DISK = N'C:\Backup\nome_do_banco_DIFF.bak'
  WITH NORECOVERY, STATS = 10;

-- 3) LOGs anteriores ao ponto desejado
RESTORE LOG @Banco
  FROM DISK = N'C:\Backup\nome_do_banco_LOG_01.trn'
  WITH NORECOVERY, STATS = 10;

-- 4) LOG que contém o ponto desejado: para em @PontoNoTempo e abre o banco
RESTORE LOG @Banco
  FROM DISK = N'C:\Backup\nome_do_banco_LOG_02.trn'
  WITH STOPAT = @PontoNoTempo, RECOVERY, STATS = 10;
GO
