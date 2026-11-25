-- Đổi tên bảng cho cơ sở dữ liệu đã tạo bằng phiên bản cũ.
USE [PCMComputerDB];
GO

SET XACT_ABORT ON;

DECLARE @Bang TABLE (TenCu SYSNAME NOT NULL, TenMoi SYSNAME NOT NULL);
INSERT INTO @Bang (TenCu, TenMoi)
VALUES
    (N'Users', N'TAIKHOAN'),
    (N'Categories', N'DANHMUC'),
    (N'Products', N'SANPHAM'),
    (N'Promotions', N'KHUYENMAI'),
    (N'Orders', N'DONHANG'),
    (N'OrderDetails', N'CHITIETDONHANG'),
    (N'OrderStatusHistory', N'LICHSUTRANGTHAIDONHANG'),
    (N'Contacts', N'LIENHE');

BEGIN TRY
    BEGIN TRANSACTION;

    IF EXISTS (
        SELECT 1 FROM @Bang
        WHERE (OBJECT_ID(N'dbo.' + TenCu, N'U') IS NULL AND OBJECT_ID(N'dbo.' + TenMoi, N'U') IS NULL)
           OR (OBJECT_ID(N'dbo.' + TenCu, N'U') IS NOT NULL AND OBJECT_ID(N'dbo.' + TenMoi) IS NOT NULL)
    )
        THROW 50001, N'Thiếu bảng hoặc trùng tên bảng. Không thể đổi tên bảng.', 1;

    DECLARE @TenCu SYSNAME, @TenMoi SYSNAME, @TenDayDu NVARCHAR(257);
    DECLARE ds_bang CURSOR LOCAL STATIC FOR
        SELECT TenCu, TenMoi FROM @Bang WHERE OBJECT_ID(N'dbo.' + TenCu, N'U') IS NOT NULL;

    OPEN ds_bang;
    FETCH NEXT FROM ds_bang INTO @TenCu, @TenMoi;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @TenDayDu = N'dbo.' + QUOTENAME(@TenCu);
        EXEC sys.sp_rename @objname = @TenDayDu, @newname = @TenMoi, @objtype = N'OBJECT';
        FETCH NEXT FROM ds_bang INTO @TenCu, @TenMoi;
    END
    CLOSE ds_bang;
    DEALLOCATE ds_bang;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
