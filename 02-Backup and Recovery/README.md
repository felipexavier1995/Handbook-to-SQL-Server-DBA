# 02 - Backup and Recovery

T-SQL scripts for **backing up, verifying, and restoring** SQL Server databases.
Each script has a standard header describing its purpose, required permissions, and impact on the environment.

> ⚠️ **Warning:** scripts marked "No" in the *Read-only?* column create files, overwrite databases, or change a database's state. Read the script header and test in a non-production environment before running.

---

## Script index

### Backup

| Script | Description | Read-only? |
|---|---|---|
| [backup-full.sql](backup-full.sql) | Full backup with compression and checksum | No (`INIT` overwrites the file) |
| [backup-full-dynamic-name.sql](backup-full-dynamic-name.sql) | Full backup with date and time in the file name | No (creates a new file on each run) |
| [backup-differential.sql](backup-differential.sql) | Differential backup (requires a prior full backup) | No |
| [backup-log.sql](backup-log.sql) | Transaction log backup (FULL or BULK_LOGGED recovery model) | No (frees reusable log space) |
| [backup-tail-log.sql](backup-tail-log.sql) | Tail-log backup before restoring over an existing database | No ⚠️ leaves the database in `RESTORING` |

### Verification

| Script | Description | Read-only? |
|---|---|---|
| [check-databases-without-recent-backup.sql](check-databases-without-recent-backup.sql) | Lists databases with no full or log backup within the defined threshold | Yes |
| [restore-backup-history.sql](restore-backup-history.sql) | Recent backups with file paths and restore history | Yes |
| [restore-inspect-backup-file.sql](restore-inspect-backup-file.sql) | `HEADERONLY`, `FILELISTONLY`, and `VERIFYONLY` for a backup file | Yes |

### Restore

| Script | Description | Read-only? |
|---|---|---|
| [restore-full.sql](restore-full.sql) | Full backup restore with file relocation (`MOVE`) | No ⚠️ uses `REPLACE` |
| [restore-full-diff-log-chain.sql](restore-full-diff-log-chain.sql) | Full restore chain: full + differential + logs | No ⚠️ uses `REPLACE` |
| [restore-point-in-time.sql](restore-point-in-time.sql) | Restore to a specific point in time (`STOPAT`) | No ⚠️ uses `REPLACE` |

---

## Recommended restore workflow

1. **Identify the backup chain:** `restore-backup-history.sql`
2. **Validate the files and get the logical file names:** `restore-inspect-backup-file.sql`
3. **Preserve the latest transactions** (only if restoring over an existing database): `backup-tail-log.sql`
4. **Restore**, depending on the scenario:
   - Full backup only: `restore-full.sql`
   - Full + differential + logs: `restore-full-diff-log-chain.sql`
   - Return to a specific moment (e.g., before an accidental `DELETE`): `restore-point-in-time.sql`
5. **Validate the restored database** (preferably under a different name) before replacing the original.

---

## Before you run

- Adjust the variables at the top of each script (`@Banco`, `@Arquivo`, `@Pasta`, etc.).
- Make sure the SQL Server service account has read/write permission on the backup and data folders.
- Backup compression depends on the SQL Server edition (or on `backup compression default` being enabled).
- With `STOPAT`, the time you provide is the **server's** time, not your machine's.
- In chained restores, every step uses `NORECOVERY` except the last one. If you forget the final `RECOVERY`, the database stays in `RESTORING` and can be brought online with:

  ```sql
  RESTORE DATABASE [database_name] WITH RECOVERY;
  ```

- The scripts were written for SQL Server 2008 R2 or later, but still need to be validated in each environment.

---

## Minimum permissions

| Operation | Permission |
|---|---|
| Backup | `db_backupoperator` on the database, or `sysadmin` |
| Restore | `dbcreator` or `sysadmin` |
| History queries | Read access to `msdb` and `sys.databases` |

---

## Pending

- [ ] Email alert for databases without recent backups (SQL Agent job + `sp_send_dbmail`)
- [ ] Script to bring a database out of `RESTORING` (troubleshooting)
- [ ] Validate all scripts in a lab environment
