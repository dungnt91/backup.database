IF OBJECT_ID(N'[dbo].delete_filebak') IS NOT NULL
	DROP PROCEDURE [dbo].delete_filebak
GO

create proc delete_filebak
   @DatabaseName varchar(max),												-- Database Backup
   @BackupPath   varchar(max)												-- Thư mục Backup dữ liệu
as
begin

   declare @SQLText nvarchar(200)											-- Lệnh backup database
   declare @cmdpath nvarchar(200)											-- Lệnh tạo thư mục theo ngày
   declare @bkdate varchar(100) = convert(varchar, getdate(), 104)			-- Ngày backup dữ liệu
   declare @Bkpath varchar(100)												-- Thư mục backup dữ liệu
   begin
	  set @BackupPath = @BackupPath + '\' + @DatabaseName + '\' + @bkdate + '\' + @DatabaseName + '.bak'

      set @SQLText= 'del '+ @BackupPath
   end
   exec xp_cmdshell @SQLText
end

--exec delete_filebak 'test','D:\Backups'