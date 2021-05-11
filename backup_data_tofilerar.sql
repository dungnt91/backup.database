IF OBJECT_ID(N'[dbo].backup_data_tofilerar') IS NOT NULL
	DROP PROCEDURE [dbo].backup_data_tofilerar
GO

create proc backup_data_tofilerar
   @DatabaseName varchar(max),												-- Database Backup
   @BackupPath   varchar(max),												-- Thư mục Backup dữ liệu
   @FileSize	 int,														-- Số lương size Backup
   @intDate		 int = 15														-- Số ngày khai báo
as
begin

   declare @SQLText nvarchar(max)											-- Lệnh backup database
   declare @CompressionCommand varchar(5000)								-- Lệnh nén thành file rar
   declare @cmdpath nvarchar(200)											-- Lệnh tạo thư mục theo ngày
   declare @cmdrmpath nvarchar(200)											-- Lệnh xóa thư mục theo ngày
   declare @bkdate varchar(100) = convert(varchar, getdate(), 104)			-- Ngày backup dữ liệu
   declare @rmdate varchar(100) = convert(varchar, getdate() - @intDate, 104)-- Xóa file dữ liệu theo số ngày khai báo
   declare @Bkpath varchar(100)
   declare @Bkrm   varchar(100)
   begin
	  set @BackupPath = @BackupPath + '\' + @DatabaseName + '\'

	  set @Bkpath = @BackupPath + '\' + @bkdate
	  set @cmdpath	  = 'MD ' +@Bkpath

	  set @Bkrm = @BackupPath + '\' + @rmdate
	  set @cmdrmpath  = 'RMDIR ' +@Bkrm + ' /S /Q'

      set @SQLText= 'Backup database [' + @DatabaseName + '] to disk ='''+@Bkpath + '\' + @DatabaseName + '.bak'' with compression,copy_only'
      set @CompressionCommand='"C:\Program Files\WinRAR\rar.exe" a -v'+Convert(varchar,@FileSize)+'M ' + @Bkpath + '\' + @DatabaseName +'.rar '+ @Bkpath + '\'+@DatabaseName + '.bak'
   end
   exec xp_cmdshell @cmdpath
   exec sp_executesql @SQLText
   exec xp_cmdshell @CompressionCommand
   exec xp_cmdshell @cmdrmpath, no_output
end

---- To allow advanced options to be changed.  
--EXECUTE sp_configure 'show advanced options', 1;  
--GO  
---- To update the currently configured value for advanced options.  
--RECONFIGURE;  
--GO  
---- To enable the feature.  
--EXECUTE sp_configure 'xp_cmdshell', 1;  
--GO  
---- To update the currently configured value for this feature.  
--RECONFIGURE;  
--GO

--exec backup_data_tofilerar 'test','D:\Backups',1