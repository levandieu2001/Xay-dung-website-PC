-- ============================================================================
-- CƠ SỞ DỮ LIỆU: PCMComputerDB (Hệ thống Website Bán Máy Tính và Linh Kiện)
-- Hệ quản trị CSDL: Microsoft SQL Server (.\SQLEXPRESS)
-- Bám sát tài liệu đặc tả: Website-Laptop-Linh-Kien.docx (FR01 - FR16, UC01 - UC16)
-- ============================================================================

USE master;
GO

IF DB_ID(N'PCMComputerDB') IS NULL
    EXEC(N'CREATE DATABASE [PCMComputerDB]');
GO

USE [PCMComputerDB];
GO

SET XACT_ABORT ON;
GO

-- Nâng cấp cơ sở dữ liệu đang có bằng cách đổi tên tại chỗ.
IF EXISTS (SELECT 1 FROM sys.tables WHERE schema_id = SCHEMA_ID(N'dbo'))
BEGIN
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

    DECLARE @Cot TABLE (TenBang SYSNAME, TenCu SYSNAME, TenMoi SYSNAME);
    INSERT INTO @Cot (TenBang, TenCu, TenMoi)
    VALUES
        (N'TAIKHOAN', N'UserId', N'ID_TAIKHOAN'),
        (N'TAIKHOAN', N'Username', N'TEN_DANG_NHAP'),
        (N'TAIKHOAN', N'PasswordHash', N'MA_BAM_MAT_KHAU'),
        (N'TAIKHOAN', N'FullName', N'HO_TEN'),
        (N'TAIKHOAN', N'Email', N'THU_DIEN_TU'),
        (N'TAIKHOAN', N'Phone', N'SO_DIEN_THOAI'),
        (N'TAIKHOAN', N'Address', N'DIA_CHI'),
        (N'TAIKHOAN', N'Role', N'VAI_TRO'),
        (N'TAIKHOAN', N'IsLocked', N'BI_KHOA'),
        (N'TAIKHOAN', N'CreatedAt', N'NGAY_TAO'),
        (N'DANHMUC', N'CategoryId', N'ID_DANHMUC'),
        (N'DANHMUC', N'CategoryName', N'TEN_DANH_MUC'),
        (N'DANHMUC', N'Slug', N'TEN_RUT_GON'),
        (N'DANHMUC', N'PageUrl', N'DUONG_DAN_TRANG'),
        (N'DANHMUC', N'IconPath', N'DUONG_DAN_BIEU_TUONG'),
        (N'DANHMUC', N'Description', N'MO_TA'),
        (N'DANHMUC', N'DisplayOrder', N'THU_TU_HIEN_THI'),
        (N'DANHMUC', N'IsActive', N'DANG_HOAT_DONG'),
        (N'SANPHAM', N'ProductId', N'ID_SANPHAM'),
        (N'SANPHAM', N'ProductCode', N'MA_SAN_PHAM'),
        (N'SANPHAM', N'ProductName', N'TEN_SAN_PHAM'),
        (N'SANPHAM', N'CategoryId', N'ID_DANHMUC'),
        (N'SANPHAM', N'Brand', N'THUONG_HIEU'),
        (N'SANPHAM', N'OldPrice', N'GIA_CU'),
        (N'SANPHAM', N'Price', N'GIA_BAN'),
        (N'SANPHAM', N'StockQuantity', N'SO_LUONG_TON'),
        (N'SANPHAM', N'WarrantyMonths', N'SO_THANG_BAO_HANH'),
        (N'SANPHAM', N'ImageUrl', N'DUONG_DAN_ANH'),
        (N'SANPHAM', N'Specifications', N'THONG_SO_KY_THUAT'),
        (N'SANPHAM', N'Description', N'MO_TA'),
        (N'SANPHAM', N'PromoCount', N'SO_UU_DAI'),
        (N'SANPHAM', N'IsDeal', N'GIA_SOC'),
        (N'SANPHAM', N'SoldCount', N'SO_LUONG_DA_BAN'),
        (N'SANPHAM', N'Status', N'TRANG_THAI'),
        (N'SANPHAM', N'CreatedAt', N'NGAY_TAO'),
        (N'KHUYENMAI', N'PromotionId', N'ID_KHUYENMAI'),
        (N'KHUYENMAI', N'PromotionName', N'TEN_KHUYEN_MAI'),
        (N'KHUYENMAI', N'VoucherCode', N'MA_GIAM_GIA'),
        (N'KHUYENMAI', N'DiscountType', N'LOAI_GIAM_GIA'),
        (N'KHUYENMAI', N'DiscountValue', N'MUC_GIAM_GIA'),
        (N'KHUYENMAI', N'MinOrderAmount', N'GIA_TRI_DON_TOI_THIEU'),
        (N'KHUYENMAI', N'MaxDiscountAmount', N'MUC_GIAM_TOI_DA'),
        (N'KHUYENMAI', N'UsageLimit', N'GIOI_HAN_SU_DUNG'),
        (N'KHUYENMAI', N'UsedCount', N'SO_LUOT_DA_DUNG'),
        (N'KHUYENMAI', N'StartDate', N'NGAY_BAT_DAU'),
        (N'KHUYENMAI', N'EndDate', N'NGAY_KET_THUC'),
        (N'KHUYENMAI', N'Description', N'MO_TA'),
        (N'KHUYENMAI', N'IsActive', N'DANG_HOAT_DONG'),
        (N'DONHANG', N'OrderId', N'ID_DONHANG'),
        (N'DONHANG', N'OrderCode', N'MA_DON_HANG'),
        (N'DONHANG', N'UserId', N'ID_TAIKHOAN'),
        (N'DONHANG', N'ReceiverName', N'TEN_NGUOI_NHAN'),
        (N'DONHANG', N'ReceiverPhone', N'DIEN_THOAI_NGUOI_NHAN'),
        (N'DONHANG', N'ShippingAddress', N'DIA_CHI_GIAO_HANG'),
        (N'DONHANG', N'Note', N'GHI_CHU'),
        (N'DONHANG', N'PaymentMethod', N'PHUONG_THUC_THANH_TOAN'),
        (N'DONHANG', N'SubTotal', N'TAM_TINH'),
        (N'DONHANG', N'VoucherCode', N'MA_GIAM_GIA'),
        (N'DONHANG', N'DiscountAmount', N'SO_TIEN_GIAM'),
        (N'DONHANG', N'TotalAmount', N'TONG_TIEN'),
        (N'DONHANG', N'OrderStatus', N'TRANG_THAI_DON_HANG'),
        (N'DONHANG', N'CreatedAt', N'NGAY_TAO'),
        (N'DONHANG', N'UpdatedAt', N'NGAY_CAP_NHAT'),
        (N'CHITIETDONHANG', N'OrderDetailId', N'ID_CHITIETDONHANG'),
        (N'CHITIETDONHANG', N'OrderId', N'ID_DONHANG'),
        (N'CHITIETDONHANG', N'ProductId', N'ID_SANPHAM'),
        (N'CHITIETDONHANG', N'ProductCode', N'MA_SAN_PHAM'),
        (N'CHITIETDONHANG', N'ProductName', N'TEN_SAN_PHAM'),
        (N'CHITIETDONHANG', N'ImageUrl', N'DUONG_DAN_ANH'),
        (N'CHITIETDONHANG', N'UnitPrice', N'DON_GIA'),
        (N'CHITIETDONHANG', N'Quantity', N'SO_LUONG'),
        (N'CHITIETDONHANG', N'LineTotal', N'THANH_TIEN'),
        (N'LICHSUTRANGTHAIDONHANG', N'HistoryId', N'ID_LICHSU'),
        (N'LICHSUTRANGTHAIDONHANG', N'OrderId', N'ID_DONHANG'),
        (N'LICHSUTRANGTHAIDONHANG', N'Status', N'TRANG_THAI'),
        (N'LICHSUTRANGTHAIDONHANG', N'Note', N'GHI_CHU'),
        (N'LICHSUTRANGTHAIDONHANG', N'UpdatedBy', N'NGUOI_CAP_NHAT'),
        (N'LICHSUTRANGTHAIDONHANG', N'UpdatedAt', N'NGAY_CAP_NHAT'),
        (N'LIENHE', N'ContactId', N'ID_LIENHE'),
        (N'LIENHE', N'FullName', N'HO_TEN'),
        (N'LIENHE', N'Phone', N'SO_DIEN_THOAI'),
        (N'LIENHE', N'Email', N'THU_DIEN_TU'),
        (N'LIENHE', N'Title', N'TIEU_DE'),
        (N'LIENHE', N'Content', N'NOI_DUNG'),
        (N'LIENHE', N'CreatedAt', N'NGAY_TAO'),
        (N'LIENHE', N'IsResolved', N'DA_XU_LY');

    DECLARE @RangBuoc TABLE (TenBang SYSNAME, TenCu SYSNAME, TenMoi SYSNAME);
    INSERT INTO @RangBuoc (TenBang, TenCu, TenMoi)
    VALUES
        (N'TAIKHOAN', N'DF_Users_Role', N'DF_TAIKHOAN_VAI_TRO'),
        (N'TAIKHOAN', N'DF_Users_IsLocked', N'DF_TAIKHOAN_BI_KHOA'),
        (N'TAIKHOAN', N'DF_Users_CreatedAt', N'DF_TAIKHOAN_NGAY_TAO'),
        (N'TAIKHOAN', N'CK_Users_Role', N'CK_TAIKHOAN_VAI_TRO'),
        (N'DANHMUC', N'DF_Categories_Order', N'DF_DANHMUC_THU_TU_HIEN_THI'),
        (N'DANHMUC', N'DF_Categories_IsActive', N'DF_DANHMUC_DANG_HOAT_DONG'),
        (N'SANPHAM', N'DF_Products_OldPrice', N'DF_SANPHAM_GIA_CU'),
        (N'SANPHAM', N'DF_Products_Stock', N'DF_SANPHAM_SO_LUONG_TON'),
        (N'SANPHAM', N'DF_Products_Warranty', N'DF_SANPHAM_BAO_HANH'),
        (N'SANPHAM', N'DF_Products_PromoCount', N'DF_SANPHAM_SO_UU_DAI'),
        (N'SANPHAM', N'DF_Products_IsDeal', N'DF_SANPHAM_GIA_SOC'),
        (N'SANPHAM', N'DF_Products_SoldCount', N'DF_SANPHAM_SO_LUONG_DA_BAN'),
        (N'SANPHAM', N'DF_Products_Status', N'DF_SANPHAM_TRANG_THAI'),
        (N'SANPHAM', N'DF_Products_CreatedAt', N'DF_SANPHAM_NGAY_TAO'),
        (N'SANPHAM', N'FK_Products_Categories', N'FK_SANPHAM_DANHMUC'),
        (N'SANPHAM', N'CK_Products_Price', N'CK_SANPHAM_GIA_BAN'),
        (N'SANPHAM', N'CK_Products_Stock', N'CK_SANPHAM_SO_LUONG_TON'),
        (N'KHUYENMAI', N'DF_Promotions_MinOrder', N'DF_KHUYENMAI_DON_TOI_THIEU'),
        (N'KHUYENMAI', N'DF_Promotions_MaxDiscount', N'DF_KHUYENMAI_GIAM_TOI_DA'),
        (N'KHUYENMAI', N'DF_Promotions_Limit', N'DF_KHUYENMAI_GIOI_HAN'),
        (N'KHUYENMAI', N'DF_Promotions_Used', N'DF_KHUYENMAI_LUOT_DA_DUNG'),
        (N'KHUYENMAI', N'DF_Promotions_IsActive', N'DF_KHUYENMAI_DANG_HOAT_DONG'),
        (N'KHUYENMAI', N'CK_Promotions_Type', N'CK_KHUYENMAI_LOAI_GIAM'),
        (N'KHUYENMAI', N'CK_Promotions_Dates', N'CK_KHUYENMAI_THOI_HAN'),
        (N'KHUYENMAI', N'CK_Promotions_Value', N'CK_KHUYENMAI_MUC_GIAM'),
        (N'DONHANG', N'DF_Orders_Payment', N'DF_DONHANG_THANH_TOAN'),
        (N'DONHANG', N'DF_Orders_Discount', N'DF_DONHANG_GIAM_GIA'),
        (N'DONHANG', N'DF_Orders_Status', N'DF_DONHANG_TRANG_THAI'),
        (N'DONHANG', N'DF_Orders_CreatedAt', N'DF_DONHANG_NGAY_TAO'),
        (N'DONHANG', N'DF_Orders_UpdatedAt', N'DF_DONHANG_NGAY_CAP_NHAT'),
        (N'DONHANG', N'FK_Orders_Users', N'FK_DONHANG_TAIKHOAN'),
        (N'CHITIETDONHANG', N'FK_OrderDetails_Orders', N'FK_CHITIETDONHANG_DONHANG'),
        (N'CHITIETDONHANG', N'FK_OrderDetails_Products', N'FK_CHITIETDONHANG_SANPHAM'),
        (N'CHITIETDONHANG', N'CK_OrderDetails_Qty', N'CK_CHITIETDONHANG_SO_LUONG'),
        (N'LICHSUTRANGTHAIDONHANG', N'DF_OrderHistory_At', N'DF_LICHSUTRANGTHAIDONHANG_NGAY_CAP_NHAT'),
        (N'LICHSUTRANGTHAIDONHANG', N'FK_OrderHistory_Orders', N'FK_LICHSUTRANGTHAIDONHANG_DONHANG'),
        (N'LIENHE', N'DF_Contacts_CreatedAt', N'DF_LIENHE_NGAY_TAO'),
        (N'LIENHE', N'DF_Contacts_Resolved', N'DF_LIENHE_DA_XU_LY');

    BEGIN TRY
        BEGIN TRANSACTION;

        IF EXISTS (
            SELECT 1 FROM @Bang
            WHERE (OBJECT_ID(N'dbo.' + TenCu, N'U') IS NULL AND OBJECT_ID(N'dbo.' + TenMoi, N'U') IS NULL)
               OR (OBJECT_ID(N'dbo.' + TenCu, N'U') IS NOT NULL AND OBJECT_ID(N'dbo.' + TenMoi) IS NOT NULL)
        )
            THROW 50001, N'Thiếu bảng hoặc trùng tên bảng. Không thể đổi tên bảng.', 1;

        DECLARE @TenCu SYSNAME, @TenMoi SYSNAME, @TenDayDu NVARCHAR(776);
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

        IF EXISTS (
            SELECT 1 FROM @Cot
            WHERE (COL_LENGTH(N'dbo.' + TenBang, TenCu) IS NULL AND COL_LENGTH(N'dbo.' + TenBang, TenMoi) IS NULL)
               OR (COL_LENGTH(N'dbo.' + TenBang, TenCu) IS NOT NULL AND COL_LENGTH(N'dbo.' + TenBang, TenMoi) IS NOT NULL)
        )
            THROW 50002, N'Thiếu cột hoặc trùng tên cột. Không thể đổi tên lược đồ.', 1;

        DECLARE @TenBang SYSNAME, @Lenh NVARCHAR(MAX);
        DECLARE @KiemTra TABLE (TenBang SYSNAME, TenCu SYSNAME, TenMoi SYSNAME, DaTat BIT, ChuaKiemTra BIT);
        INSERT INTO @KiemTra (TenBang, TenCu, TenMoi, DaTat, ChuaKiemTra)
            SELECT r.TenBang, r.TenCu, r.TenMoi, c.is_disabled, c.is_not_trusted
            FROM @RangBuoc r
            INNER JOIN sys.check_constraints c
                ON c.object_id = OBJECT_ID(N'dbo.' + r.TenCu)
               AND c.parent_object_id = OBJECT_ID(N'dbo.' + r.TenBang, N'U');

        -- SQL Server yêu cầu gỡ ràng buộc CHECK trước khi đổi tên cột mà nó tham chiếu.
        DECLARE ds_kiem_tra_cu CURSOR LOCAL STATIC FOR SELECT TenBang, TenCu FROM @KiemTra;
        OPEN ds_kiem_tra_cu;
        FETCH NEXT FROM ds_kiem_tra_cu INTO @TenBang, @TenCu;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @Lenh = N'ALTER TABLE dbo.' + QUOTENAME(@TenBang) + N' DROP CONSTRAINT ' + QUOTENAME(@TenCu);
            EXEC sys.sp_executesql @Lenh;
            FETCH NEXT FROM ds_kiem_tra_cu INTO @TenBang, @TenCu;
        END
        CLOSE ds_kiem_tra_cu;
        DEALLOCATE ds_kiem_tra_cu;

        DECLARE ds_cot CURSOR LOCAL STATIC FOR
            SELECT TenBang, TenCu, TenMoi FROM @Cot WHERE COL_LENGTH(N'dbo.' + TenBang, TenCu) IS NOT NULL;
        OPEN ds_cot;
        FETCH NEXT FROM ds_cot INTO @TenBang, @TenCu, @TenMoi;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @TenDayDu = N'dbo.' + QUOTENAME(@TenBang) + N'.' + QUOTENAME(@TenCu);
            EXEC sys.sp_rename @objname = @TenDayDu, @newname = @TenMoi, @objtype = N'COLUMN';
            FETCH NEXT FROM ds_cot INTO @TenBang, @TenCu, @TenMoi;
        END
        CLOSE ds_cot;
        DEALLOCATE ds_cot;

        DECLARE ds_rang_buoc CURSOR LOCAL STATIC FOR
            SELECT r.TenCu, r.TenMoi
            FROM @RangBuoc r
            INNER JOIN sys.objects o
                ON o.object_id = OBJECT_ID(N'dbo.' + r.TenCu)
               AND o.parent_object_id = OBJECT_ID(N'dbo.' + r.TenBang, N'U');
        OPEN ds_rang_buoc;
        FETCH NEXT FROM ds_rang_buoc INTO @TenCu, @TenMoi;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @TenDayDu = N'dbo.' + QUOTENAME(@TenCu);
            EXEC sys.sp_rename @objname = @TenDayDu, @newname = @TenMoi, @objtype = N'OBJECT';
            FETCH NEXT FROM ds_rang_buoc INTO @TenCu, @TenMoi;
        END
        CLOSE ds_rang_buoc;
        DEALLOCATE ds_rang_buoc;

        DECLARE @DinhNghia TABLE (Ten SYSNAME, BieuThuc NVARCHAR(500));
        INSERT INTO @DinhNghia (Ten, BieuThuc)
        VALUES
            (N'CK_TAIKHOAN_VAI_TRO', N'(VAI_TRO IN (''Admin'', ''Staff'', ''Customer''))'),
            (N'CK_SANPHAM_GIA_BAN', N'(GIA_BAN >= 0 AND GIA_CU >= 0)'),
            (N'CK_SANPHAM_SO_LUONG_TON', N'(SO_LUONG_TON >= 0)'),
            (N'CK_KHUYENMAI_LOAI_GIAM', N'(LOAI_GIAM_GIA IN (''PERCENT'', ''AMOUNT''))'),
            (N'CK_KHUYENMAI_THOI_HAN', N'(NGAY_KET_THUC >= NGAY_BAT_DAU)'),
            (N'CK_KHUYENMAI_MUC_GIAM', N'( (LOAI_GIAM_GIA = ''PERCENT'' AND MUC_GIAM_GIA > 0 AND MUC_GIAM_GIA <= 100) OR (LOAI_GIAM_GIA = ''AMOUNT'' AND MUC_GIAM_GIA > 0) )'),
            (N'CK_CHITIETDONHANG_SO_LUONG', N'(SO_LUONG > 0)');

        DECLARE @BieuThuc NVARCHAR(500), @DaTat BIT, @ChuaKiemTra BIT;
        DECLARE ds_kiem_tra_moi CURSOR LOCAL STATIC FOR
            SELECT k.TenBang, k.TenMoi, d.BieuThuc, k.DaTat, k.ChuaKiemTra
            FROM @KiemTra k INNER JOIN @DinhNghia d ON d.Ten = k.TenMoi;
        OPEN ds_kiem_tra_moi;
        FETCH NEXT FROM ds_kiem_tra_moi INTO @TenBang, @TenMoi, @BieuThuc, @DaTat, @ChuaKiemTra;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @Lenh = N'ALTER TABLE dbo.' + QUOTENAME(@TenBang)
                + CASE WHEN @ChuaKiemTra = 1 THEN N' WITH NOCHECK' ELSE N' WITH CHECK' END
                + N' ADD CONSTRAINT ' + QUOTENAME(@TenMoi) + N' CHECK ' + @BieuThuc;
            EXEC sys.sp_executesql @Lenh;
            IF @DaTat = 1
            BEGIN
                SET @Lenh = N'ALTER TABLE dbo.' + QUOTENAME(@TenBang) + N' NOCHECK CONSTRAINT ' + QUOTENAME(@TenMoi);
                EXEC sys.sp_executesql @Lenh;
            END
            FETCH NEXT FROM ds_kiem_tra_moi INTO @TenBang, @TenMoi, @BieuThuc, @DaTat, @ChuaKiemTra;
        END
        CLOSE ds_kiem_tra_moi;
        DEALLOCATE ds_kiem_tra_moi;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- Chỉ tạo bảng và nạp dữ liệu mẫu khi cơ sở dữ liệu trống.
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE schema_id = SCHEMA_ID(N'dbo'))
BEGIN
BEGIN TRY
    BEGIN TRANSACTION;

-- ============================================================================
-- 1. BẢNG TAIKHOAN (Quản lý tài khoản & phân quyền - UC01, UC02, UC12, UC15)
-- ============================================================================
CREATE TABLE dbo.TAIKHOAN (
    ID_TAIKHOAN INT IDENTITY(1,1) PRIMARY KEY, -- Mã tài khoản
    TEN_DANG_NHAP NVARCHAR(50) NOT NULL UNIQUE, -- Tên đăng nhập
    MA_BAM_MAT_KHAU NVARCHAR(128) NOT NULL, -- Mã băm mật khẩu
    HO_TEN NVARCHAR(100) NOT NULL, -- Họ và tên
    THU_DIEN_TU NVARCHAR(100) NOT NULL UNIQUE, -- Địa chỉ thư điện tử
    SO_DIEN_THOAI NVARCHAR(20) NOT NULL, -- Số điện thoại
    DIA_CHI NVARCHAR(255) NULL, -- Địa chỉ
    VAI_TRO NVARCHAR(20) NOT NULL CONSTRAINT DF_TAIKHOAN_VAI_TRO DEFAULT ('Customer'), -- Vai trò: quản trị viên, nhân viên hoặc khách hàng
    BI_KHOA BIT NOT NULL CONSTRAINT DF_TAIKHOAN_BI_KHOA DEFAULT (0), -- Tài khoản bị khóa
    NGAY_TAO DATETIME NOT NULL CONSTRAINT DF_TAIKHOAN_NGAY_TAO DEFAULT (GETDATE()), -- Thời điểm tạo tài khoản
    CONSTRAINT CK_TAIKHOAN_VAI_TRO CHECK (VAI_TRO IN ('Admin', 'Staff', 'Customer'))
);

-- ============================================================================
-- 2. BẢNG DANHMUC (Quản lý danh mục máy tính & linh kiện - UC03, UC10)
-- ============================================================================
CREATE TABLE dbo.DANHMUC (
    ID_DANHMUC INT IDENTITY(1,1) PRIMARY KEY, -- Mã danh mục
    TEN_DANH_MUC NVARCHAR(100) NOT NULL UNIQUE, -- Tên danh mục
    TEN_RUT_GON NVARCHAR(50) NOT NULL UNIQUE, -- Tên rút gọn dùng trong đường dẫn
    DUONG_DAN_TRANG NVARCHAR(100) NULL, -- Đường dẫn trang danh mục
    DUONG_DAN_BIEU_TUONG NVARCHAR(255) NULL, -- Đường dẫn biểu tượng
    MO_TA NVARCHAR(500) NULL, -- Mô tả danh mục
    THU_TU_HIEN_THI INT NOT NULL CONSTRAINT DF_DANHMUC_THU_TU_HIEN_THI DEFAULT (1), -- Thứ tự hiển thị
    DANG_HOAT_DONG BIT NOT NULL CONSTRAINT DF_DANHMUC_DANG_HOAT_DONG DEFAULT (1) -- Danh mục đang hoạt động
);

-- ============================================================================
-- 3. BẢNG SANPHAM (Quản lý máy tính & linh kiện - UC03, UC04, UC05, UC09)
-- ============================================================================
CREATE TABLE dbo.SANPHAM (
    ID_SANPHAM INT IDENTITY(1,1) PRIMARY KEY, -- Mã định danh sản phẩm
    MA_SAN_PHAM NVARCHAR(30) NOT NULL UNIQUE, -- Mã hàng
    TEN_SAN_PHAM NVARCHAR(250) NOT NULL, -- Tên sản phẩm
    ID_DANHMUC INT NOT NULL, -- Mã danh mục
    THUONG_HIEU NVARCHAR(50) NOT NULL, -- Thương hiệu
    GIA_CU DECIMAL(18,0) NOT NULL CONSTRAINT DF_SANPHAM_GIA_CU DEFAULT (0), -- Giá cũ
    GIA_BAN DECIMAL(18,0) NOT NULL, -- Giá bán hiện tại
    SO_LUONG_TON INT NOT NULL CONSTRAINT DF_SANPHAM_SO_LUONG_TON DEFAULT (0), -- Số lượng tồn kho
    SO_THANG_BAO_HANH INT NOT NULL CONSTRAINT DF_SANPHAM_BAO_HANH DEFAULT (24), -- Số tháng bảo hành
    DUONG_DAN_ANH NVARCHAR(255) NOT NULL, -- Đường dẫn ảnh
    THONG_SO_KY_THUAT NVARCHAR(MAX) NULL, -- Thông số kỹ thuật, phân cách bằng dấu gạch đứng
    MO_TA NVARCHAR(MAX) NULL, -- Mô tả sản phẩm
    SO_UU_DAI INT NOT NULL CONSTRAINT DF_SANPHAM_SO_UU_DAI DEFAULT (2), -- Số ưu đãi hiển thị kèm sản phẩm
    GIA_SOC BIT NOT NULL CONSTRAINT DF_SANPHAM_GIA_SOC DEFAULT (0), -- Sản phẩm thuộc chương trình giá sốc
    SO_LUONG_DA_BAN INT NOT NULL CONSTRAINT DF_SANPHAM_SO_LUONG_DA_BAN DEFAULT (0), -- Số lượng đã bán
    TRANG_THAI NVARCHAR(50) NOT NULL CONSTRAINT DF_SANPHAM_TRANG_THAI DEFAULT (N'Đang kinh doanh'), -- Trạng thái kinh doanh
    NGAY_TAO DATETIME NOT NULL CONSTRAINT DF_SANPHAM_NGAY_TAO DEFAULT (GETDATE()), -- Thời điểm tạo sản phẩm
    CONSTRAINT FK_SANPHAM_DANHMUC FOREIGN KEY (ID_DANHMUC) REFERENCES dbo.DANHMUC(ID_DANHMUC),
    CONSTRAINT CK_SANPHAM_GIA_BAN CHECK (GIA_BAN >= 0 AND GIA_CU >= 0),
    CONSTRAINT CK_SANPHAM_SO_LUONG_TON CHECK (SO_LUONG_TON >= 0)
);

-- ============================================================================
-- 4. BẢNG KHUYENMAI (Quản lý khuyến mãi / Mã giảm giá - UC13, UC16)
-- ============================================================================
CREATE TABLE dbo.KHUYENMAI (
    ID_KHUYENMAI INT IDENTITY(1,1) PRIMARY KEY, -- Mã định danh chương trình
    TEN_KHUYEN_MAI NVARCHAR(150) NOT NULL, -- Tên chương trình
    MA_GIAM_GIA NVARCHAR(50) NOT NULL UNIQUE, -- Mã giảm giá
    LOAI_GIAM_GIA NVARCHAR(20) NOT NULL, -- Cách giảm: theo tỷ lệ phần trăm hoặc số tiền cố định
    MUC_GIAM_GIA DECIMAL(18,0) NOT NULL, -- Mức giảm
    GIA_TRI_DON_TOI_THIEU DECIMAL(18,0) NOT NULL CONSTRAINT DF_KHUYENMAI_DON_TOI_THIEU DEFAULT (0), -- Giá trị đơn tối thiểu
    MUC_GIAM_TOI_DA DECIMAL(18,0) NOT NULL CONSTRAINT DF_KHUYENMAI_GIAM_TOI_DA DEFAULT (0), -- Số tiền giảm tối đa
    GIOI_HAN_SU_DUNG INT NOT NULL CONSTRAINT DF_KHUYENMAI_GIOI_HAN DEFAULT (100), -- Giới hạn lượt dùng
    SO_LUOT_DA_DUNG INT NOT NULL CONSTRAINT DF_KHUYENMAI_LUOT_DA_DUNG DEFAULT (0), -- Số lượt đã dùng
    NGAY_BAT_DAU DATETIME NOT NULL, -- Thời điểm bắt đầu
    NGAY_KET_THUC DATETIME NOT NULL, -- Thời điểm kết thúc
    MO_TA NVARCHAR(500) NULL, -- Mô tả chương trình
    DANG_HOAT_DONG BIT NOT NULL CONSTRAINT DF_KHUYENMAI_DANG_HOAT_DONG DEFAULT (1), -- Chương trình đang hoạt động
    CONSTRAINT CK_KHUYENMAI_LOAI_GIAM CHECK (LOAI_GIAM_GIA IN ('PERCENT', 'AMOUNT')),
    CONSTRAINT CK_KHUYENMAI_THOI_HAN CHECK (NGAY_KET_THUC >= NGAY_BAT_DAU),
    CONSTRAINT CK_KHUYENMAI_MUC_GIAM CHECK (
        (LOAI_GIAM_GIA = 'PERCENT' AND MUC_GIAM_GIA > 0 AND MUC_GIAM_GIA <= 100)
        OR (LOAI_GIAM_GIA = 'AMOUNT' AND MUC_GIAM_GIA > 0)
    )
);

-- ============================================================================
-- 5. BẢNG DONHANG (Đơn đặt hàng - UC07, UC08, UC11, UC14)
-- ============================================================================
CREATE TABLE dbo.DONHANG (
    ID_DONHANG INT IDENTITY(1,1) PRIMARY KEY, -- Mã định danh đơn hàng
    MA_DON_HANG NVARCHAR(30) NOT NULL UNIQUE, -- Mã đơn hiển thị cho khách hàng
    ID_TAIKHOAN INT NOT NULL, -- Mã tài khoản đặt hàng
    TEN_NGUOI_NHAN NVARCHAR(100) NOT NULL, -- Tên người nhận
    DIEN_THOAI_NGUOI_NHAN NVARCHAR(20) NOT NULL, -- Số điện thoại người nhận
    DIA_CHI_GIAO_HANG NVARCHAR(300) NOT NULL, -- Địa chỉ giao hàng
    GHI_CHU NVARCHAR(500) NULL, -- Ghi chú đơn hàng
    PHUONG_THUC_THANH_TOAN NVARCHAR(50) NOT NULL CONSTRAINT DF_DONHANG_THANH_TOAN DEFAULT (N'COD - Thanh toán khi nhận hàng'), -- Phương thức thanh toán
    TAM_TINH DECIMAL(18,0) NOT NULL, -- Tiền hàng trước giảm giá
    MA_GIAM_GIA NVARCHAR(50) NULL, -- Mã giảm giá đã áp dụng
    SO_TIEN_GIAM DECIMAL(18,0) NOT NULL CONSTRAINT DF_DONHANG_GIAM_GIA DEFAULT (0), -- Số tiền được giảm
    TONG_TIEN DECIMAL(18,0) NOT NULL, -- Tổng tiền phải trả
    TRANG_THAI_DON_HANG NVARCHAR(50) NOT NULL CONSTRAINT DF_DONHANG_TRANG_THAI DEFAULT (N'Chờ xác nhận'), -- Trạng thái đơn hàng
    NGAY_TAO DATETIME NOT NULL CONSTRAINT DF_DONHANG_NGAY_TAO DEFAULT (GETDATE()), -- Thời điểm đặt hàng
    NGAY_CAP_NHAT DATETIME NOT NULL CONSTRAINT DF_DONHANG_NGAY_CAP_NHAT DEFAULT (GETDATE()), -- Thời điểm cập nhật gần nhất
    CONSTRAINT FK_DONHANG_TAIKHOAN FOREIGN KEY (ID_TAIKHOAN) REFERENCES dbo.TAIKHOAN(ID_TAIKHOAN)
);

-- ============================================================================
-- 6. BẢNG CHITIETDONHANG (Chi tiết đơn hàng - UC07, UC08, UC11, UC14)
-- ============================================================================
CREATE TABLE dbo.CHITIETDONHANG (
    ID_CHITIETDONHANG INT IDENTITY(1,1) PRIMARY KEY, -- Mã dòng chi tiết
    ID_DONHANG INT NOT NULL, -- Mã đơn hàng
    ID_SANPHAM INT NOT NULL, -- Mã định danh sản phẩm
    MA_SAN_PHAM NVARCHAR(30) NOT NULL, -- Mã hàng tại thời điểm đặt
    TEN_SAN_PHAM NVARCHAR(250) NOT NULL, -- Tên sản phẩm tại thời điểm đặt
    DUONG_DAN_ANH NVARCHAR(255) NULL, -- Đường dẫn ảnh sản phẩm
    DON_GIA DECIMAL(18,0) NOT NULL, -- Đơn giá tại thời điểm đặt
    SO_LUONG INT NOT NULL, -- Số lượng đặt mua
    THANH_TIEN DECIMAL(18,0) NOT NULL, -- Thành tiền của dòng
    CONSTRAINT FK_CHITIETDONHANG_DONHANG FOREIGN KEY (ID_DONHANG) REFERENCES dbo.DONHANG(ID_DONHANG) ON DELETE CASCADE,
    CONSTRAINT FK_CHITIETDONHANG_SANPHAM FOREIGN KEY (ID_SANPHAM) REFERENCES dbo.SANPHAM(ID_SANPHAM),
    CONSTRAINT CK_CHITIETDONHANG_SO_LUONG CHECK (SO_LUONG > 0)
);

-- ============================================================================
-- 7. BẢNG LICHSUTRANGTHAIDONHANG (Lịch sử cập nhật trạng thái đơn hàng - UC11)
-- ============================================================================
CREATE TABLE dbo.LICHSUTRANGTHAIDONHANG (
    ID_LICHSU INT IDENTITY(1,1) PRIMARY KEY, -- Mã lượt cập nhật
    ID_DONHANG INT NOT NULL, -- Mã đơn hàng
    TRANG_THAI NVARCHAR(50) NOT NULL, -- Trạng thái sau khi cập nhật
    GHI_CHU NVARCHAR(300) NULL, -- Ghi chú cập nhật
    NGUOI_CAP_NHAT NVARCHAR(100) NULL, -- Tên người cập nhật
    NGAY_CAP_NHAT DATETIME NOT NULL CONSTRAINT DF_LICHSUTRANGTHAIDONHANG_NGAY_CAP_NHAT DEFAULT (GETDATE()), -- Thời điểm cập nhật
    CONSTRAINT FK_LICHSUTRANGTHAIDONHANG_DONHANG FOREIGN KEY (ID_DONHANG) REFERENCES dbo.DONHANG(ID_DONHANG) ON DELETE CASCADE
);

-- ============================================================================
-- 8. BẢNG LIENHE (Liên hệ & Hỗ trợ khách hàng)
-- ============================================================================
CREATE TABLE dbo.LIENHE (
    ID_LIENHE INT IDENTITY(1,1) PRIMARY KEY, -- Mã liên hệ
    HO_TEN NVARCHAR(100) NOT NULL, -- Họ và tên người gửi
    SO_DIEN_THOAI NVARCHAR(20) NOT NULL, -- Số điện thoại người gửi
    THU_DIEN_TU NVARCHAR(100) NOT NULL, -- Địa chỉ thư điện tử
    TIEU_DE NVARCHAR(200) NULL, -- Tiêu đề liên hệ
    NOI_DUNG NVARCHAR(MAX) NOT NULL, -- Nội dung liên hệ
    NGAY_TAO DATETIME NOT NULL CONSTRAINT DF_LIENHE_NGAY_TAO DEFAULT (GETDATE()), -- Thời điểm gửi
    DA_XU_LY BIT NOT NULL CONSTRAINT DF_LIENHE_DA_XU_LY DEFAULT (0) -- Liên hệ đã được xử lý
);

-- ============================================================================
-- DỮ LIỆU MẪU
-- Mật khẩu mặc định '123456' băm SHA-256:
-- 8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92
-- ============================================================================

INSERT INTO dbo.TAIKHOAN (TEN_DANG_NHAP, MA_BAM_MAT_KHAU, HO_TEN, THU_DIEN_TU, SO_DIEN_THOAI, DIA_CHI, VAI_TRO, BI_KHOA)
VALUES
(N'admin', N'8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', N'Quản Trị Viên Hệ Thống', N'admin@pcmcomputer.vn', N'0366258142', N'83-85 Thái Hà, Đống Đa, Hà Nội', N'Admin', 0),
(N'staff', N'8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', N'Nguyễn Văn Nhân Viên', N'staff@pcmcomputer.vn', N'0879979997', N'83A Cửu Long, Quận 10, TP.HCM', N'Staff', 0),
(N'staff2', N'8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', N'Trần Thị Tư Vấn', N'tuvan@pcmcomputer.vn', N'0912345678', N'83-85 Thái Hà, Đống Đa, Hà Nội', N'Staff', 0),
(N'khachhang', N'8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', N'Lê Hoàng Khách Hàng', N'khachhang@gmail.com', N'0987654321', N'Số 12 Cầu Giấy, Phường Quan Hoa, Cầu Giấy, Hà Nội', N'Customer', 0),
(N'minhanh', N'8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', N'Phạm Minh Anh', N'minhanh@gmail.com', N'0905112233', N'45 Nguyễn Thị Minh Khai, Quận 1, TP.HCM', N'Customer', 0),
(N'userlocked', N'8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', N'Tài Khoản Vi Phạm', N'locked@gmail.com', N'0933445566', N'Hà Nội', N'Customer', 1);

-- Danh mục sản phẩm khớp với trình đơn và thanh bên của PCM Computer
INSERT INTO dbo.DANHMUC (TEN_DANH_MUC, TEN_RUT_GON, DUONG_DAN_TRANG, DUONG_DAN_BIEU_TUONG, MO_TA, THU_TU_HIEN_THI, DANG_HOAT_DONG)
VALUES
(N'Laptop Gaming - Đồ Họa', N'gaming-laptops', N'MayTinhXachTayChoiGame.aspx', N'./BieuTuong/cat.png', N'Laptop cấu hình cao chuyên game và thiết kế đồ họa 3D, render', 1, 1),
(N'Laptop - Máy Tính Xách Tay', N'laptops', N'MayTinhXachTay.aspx', N'./BieuTuong/laptop.png', N'Laptop văn phòng, học tập mỏng nhẹ, pin bền bỉ', 2, 1),
(N'PC Gaming - Học Tập', N'gaming-pcs', N'MayTinhChoiGame.aspx', N'./BieuTuong/pcgaming.png', N'Bộ máy tính PC Gaming chiến mọi tựa game Esports & AAA', 3, 1),
(N'PC Đồ Họa, Thiết Kế, AI', N'workstations', N'MayTram.aspx', N'./BieuTuong/pcdohoa.png', N'Máy trạm Workstation chuyên Render, dựng phim, chạy mô hình AI', 4, 1),
(N'PC Văn Phòng - Làm Việc', N'office-pcs', N'MayTinhVanPhong.aspx', N'./BieuTuong/pcvanphong.png', N'Máy tính để bàn & Mini PC tối ưu cho doanh nghiệp, văn phòng', 5, 1),
(N'Linh Kiện Máy Tính', N'components', N'LinhKien.aspx', N'./BieuTuong/linhkien.png', N'CPU, VGA Card màn hình, Mainboard, RAM, SSD, Nguồn PSU chính hãng', 6, 1),
(N'Màn Hình, Máy In', N'monitors-printers', N'ManHinhMayIn.aspx', N'./BieuTuong/manghinh.png', N'Màn hình Gaming tần số quét cao, màn hình đồ họa chuẩn màu, máy in', 7, 1),
(N'Bàn Phím, Chuột - Gaming', N'keyboards-mice', N'BanPhimChuot.aspx', N'./BieuTuong/banphimchuot.png', N'Bàn phím cơ, chuột gaming, tay cầm & máy chơi game cầm tay', 8, 1),
(N'Phụ Kiện Laptop, PC, Khác', N'accessories', N'PhuKien.aspx', N'./BieuTuong/phukien.png', N'Balo, đế tản nhiệt, cáp chuyển đổi, hub USB-C và phụ kiện PC', 9, 1),
(N'Loa, Tai Nghe, Webcam, Tivi', N'audio-video', N'AmThanhHinhAnh.aspx', N'./BieuTuong/loa.png', N'Tai nghe gaming, loa vi tính, webcam hội nghị trực tuyến', 10, 1),
(N'Cooling, Tản Nhiệt', N'cooling', N'TanNhiet.aspx', N'./BieuTuong/tannhiet.png', N'Tản nhiệt nước AIO, tản nhiệt khí CPU, quạt fan case RGB', 11, 1),
(N'Thiết Bị Mạng, Camera', N'networking-cameras', N'ThietBiMangCamera.aspx', N'./BieuTuong/Thietbimang.png', N'Router WiFi 6, bộ phát Mesh, Switch mạng và Camera an ninh', 12, 1),
(N'Điện Thoại & Máy Chơi Game', N'phones', N'DienThoai.aspx', N'./BieuTuong/cat.png', N'Thiết bị di động thông minh và máy chơi game cầm tay cao cấp', 13, 1),
(N'Đồng Hồ Thông Minh', N'watches', N'DongHoThongMinh.aspx', N'./BieuTuong/phukien.png', N'Đồng hồ thông minh theo dõi sức khỏe, thể thao', 14, 1);

-- Sản phẩm phong phú (Sử dụng hình ảnh thực tế trong thư mục ./anh pc/)
INSERT INTO dbo.SANPHAM (
    MA_SAN_PHAM, TEN_SAN_PHAM, ID_DANHMUC, THUONG_HIEU, GIA_CU, GIA_BAN, SO_LUONG_TON, SO_THANG_BAO_HANH,
    DUONG_DAN_ANH, THONG_SO_KY_THUAT, MO_TA, SO_UU_DAI, GIA_SOC, SO_LUONG_DA_BAN, TRANG_THAI
)
VALUES
-- 1. Laptop Gaming - Đồ Họa (CategoryId = 1)
(N'NBGI0099', N'Laptop Gigabyte AORUS 16X 9KG-43VNC54SH (Intel Core i7-13650HX | RTX 4060 | 16 inch WQXGA | 16GB | 1TB | Win 11 | Xám)',
 1, N'Gigabyte', 32390000, 31990000, 8, 24, N'./anh pc/lap1.jpg',
 N'CPU: Intel Core i7-13650HX (14 nhân 20 luồng, Turbo 4.9GHz) | VGA: NVIDIA GeForce RTX 4060 8GB GDDR6 (MUX Switch) | RAM: 16GB DDR5 4800MHz (Nâng cấp tối đa 64GB) | Ổ cứng: 1TB PCIe Gen4x4 NVMe SSD | Màn hình: 16 inch WQXGA (2560x1600) 165Hz, 100% sRGB, Pantone Validated | Pin: 99Wh | Trọng lượng: 2.3 kg | HĐH: Windows 11 Home bản quyền',
 N'Laptop Gaming cao cấp dòng AORUS 16X sở hữu thiết kế chuẩn Esports, tản nhiệt WINDFORCE Infinity mát mẻ và màn hình 16:10 viền siêu mỏng.',
 3, 1, 15, N'Đang kinh doanh'),

(N'NBGI0049', N'Laptop Gigabyte Gaming A16 CMHH2VN893SH (Core i7-13620H | RTX 4050 6GB | 16GB DDR5 | 512GB SSD | 16 inch 165Hz)',
 1, N'Gigabyte', 28990000, 22490000, 12, 24, N'./anh pc/lap_giga.jpg',
 N'CPU: Intel Core i7-13620H (10 nhân 16 luồng, tới 4.9GHz) | VGA: NVIDIA GeForce RTX 4050 6GB GDDR6 | RAM: 16GB DDR5 5200MHz | Ổ cứng: 512GB NVMe PCIe Gen4 SSD | Màn hình: 16 inch FHD+ (1920x1200) IPS 165Hz | Kết nối: Wi-Fi 6E, Bluetooth 5.2, HDMI 2.1 | HĐH: Windows 11 Home',
 N'Hiệu năng vượt trội trong tầm giá cho sinh viên kỹ thuật, lập trình viên và game thủ với card đồ họa RTX 4000 series hỗ trợ DLSS 3.',
 3, 1, 24, N'Đang kinh doanh'),

(N'NBAS1483', N'Laptop ASUS Gaming V16 V3607VM-RP044W (Core i7-14650HX | RTX 4060 8GB | 16GB RAM | 1TB SSD | 16 inch 144Hz)',
 1, N'ASUS', 37300000, 32990000, 6, 24, N'./anh pc/lap_asus.jpg',
 N'CPU: Intel Core i7-14650HX (16 nhân 24 luồng, 5.2GHz) | VGA: NVIDIA GeForce RTX 4060 8GB GDDR6 TGP 140W | RAM: 16GB DDR5 5600MHz | Ổ cứng: 1TB M.2 NVMe PCIe 4.0 SSD | Màn hình: 16 inch FHD+ 16:10 144Hz IPS chống chói | Bàn phím: LED RGB Backlit | HĐH: Windows 11 Home',
 N'Laptop ASUS Gaming V16 mang sức mạnh vi xử lý Intel thế hệ 14 HX-series cùng GPU RTX 4060 full TGP, xử lý mượt mà mọi tác vụ đồ họa nặng.',
 4, 1, 19, N'Đang kinh doanh'),

(N'NBMS0301', N'Laptop MSI Katana 15 B13VFK-676VN (Intel Core i7-13620H | RTX 4060 8GB | 16GB DDR5 | 1TB SSD | 15.6 inch 144Hz)',
 1, N'MSI', 26560000, 24990000, 9, 24, N'./anh pc/lap3.jpg',
 N'CPU: Intel Core i7-13620H (24MB Cache, up to 4.90 GHz) | VGA: NVIDIA GeForce RTX 4060 Laptop GPU 8GB GDDR6 | RAM: 16GB (2x8GB) DDR5-5200 | Ổ cứng: 1TB NVMe PCIe SSD Gen4x4 | Màn hình: 15.6 inch FHD (1920x1080) 144Hz IPS-Level | Tản nhiệt: Cooler Boost 5 (2 quạt 6 ống đồng)',
 N'Dòng MSI Katana 15 nổi tiếng với bàn phím RGB 4 vùng hành trình 1.7mm và hệ thống tản nhiệt Cooler Boost 5 bền bỉ khi chiến game dài giờ.',
 2, 1, 14, N'Đang kinh doanh'),

(N'NBAS1990', N'Laptop ASUS ROG Strix SCAR 16 G634JZ (Core i9-13980HX | RTX 4080 12GB | 32GB DDR5 | 1TB SSD | 16 inch MiniLED 240Hz)',
 1, N'ASUS', 60990000, 59990000, 4, 24, N'./anh pc/lap5.jpg',
 N'CPU: Intel Core i9-13980HX (24 nhân 32 luồng, tới 5.6GHz) | VGA: NVIDIA GeForce RTX 4080 12GB GDDR6 TGP 175W | RAM: 32GB DDR5 4800MHz | Ổ cứng: 1TB PCIe 4.0 NVMe M.2 Performance SSD | Màn hình: ROG Nebula HDR 16 inch QHD+ Mini LED 240Hz, 100% DCI-P3, 1100 nits | Tản nhiệt: 3 quạt Tri-Fan & Keo kim loại lỏng Conductonaut Extreme',
 N'Siêu phẩm flagship ASUS ROG Strix SCAR 16 dành cho game thủ chuyên nghiệp và kỹ sư AI/3D cần hiệu năng đỉnh cao không thỏa hiệp.',
 4, 1, 7, N'Đang kinh doanh'),

-- 2. Laptop - Máy Tính Xách Tay (CategoryId = 2)
(N'NBAC0403', N'Laptop Acer Aspire 5 A514-56P-55K5 NX.KHRSV.003 (Core i5-1335U | 16GB LPDDR5 | 512GB SSD | 14 inch WUXGA IPS | Win 11)',
 2, N'Acer', 16990000, 12990000, 18, 12, N'./anh pc/lap_acer.jpg',
 N'CPU: Intel Core i5-1335U (10 nhân 12 luồng, tiết kiệm điện) | VGA: Intel Iris Xe Graphics | RAM: 16GB Onboard LPDDR5 4800MHz | Ổ cứng: 512GB PCIe NVMe SSD | Màn hình: 14 inch WUXGA (1920x1200) IPS Acer ComfyView | Trọng lượng: 1.48 kg | Vỏ: Hợp kim nhôm sang trọng | HĐH: Windows 11 Home',
 N'Mẫu laptop văn phòng - sinh viên bán chạy hàng đầu với màn hình tỉ lệ 16:10 sắc nét, sẵn 16GB RAM đa nhiệm mượt mà.',
 2, 1, 31, N'Đang kinh doanh'),

(N'NBDE0512', N'Laptop Dell Inspiron 15 3530 N5I7240W1 (Core i7-1355U | 16GB RAM | 512GB SSD | 15.6 inch FHD 120Hz | Win 11 + Office)',
 2, N'Dell', 21990000, 19490000, 10, 12, N'./anh pc/lap4.jpg',
 N'CPU: Intel Core i7-1355U (12MB Cache, up to 5.0 GHz) | VGA: Intel Iris Xe Graphics | RAM: 16GB DDR4 3200MHz (2 khe) | Ổ cứng: 512GB M.2 PCIe NVMe SSD | Màn hình: 15.6 inch FHD (1920x1080) 120Hz 250 nits WVA Anti-Glare | Phần mềm: Windows 11 Home + Office Home & Student vĩnh viễn',
 N'Laptop Dell Inspiron 15 3530 độ bền chuẩn doanh nghiệp, màn hình 120Hz mượt mà kèm bản quyền Office vĩnh viễn.',
 2, 0, 16, N'Đang kinh doanh'),

-- 3. PC Gaming - Học Tập (CategoryId = 3)
(N'PCAPT0199', N'PC ULTRA GAMING AI - PCAP TITAN (Intel Core i5-12400F | RTX 4060 8GB | 16GB RAM | 500GB NVMe SSD | PSU 650W)',
 3, N'PCM Build', 28000000, 25399000, 10, 36, N'./anh pc/pc8.jpg',
 N'CPU: Intel Core i5-12400F (6 nhân 12 luồng, up to 4.4GHz) | Mainboard: B760M DDR4 chính hãng | RAM: 16GB (2x8GB) DDR4 3200MHz Tản nhiệt thép | VGA: GeForce RTX 4060 8GB GDDR6 Dual Fan | SSD: 500GB PCIe Gen4 NVMe M.2 | Nguồn: 650W 80 Plus Bronze | Vỏ case: Gaming Bể Cá Kính Cường Lực + 4 Fan ARGB',
 N'Cấu hình PC Gaming quốc dân tối ưu hiệu năng/giá thành, chiến mượt Cyberpunk 2077, Black Myth: Wukong, Valorant, CS2 ở mức thiết lập cao.',
 3, 0, 28, N'Đang kinh doanh'),

(N'PCGM0205', N'PC PCM DRAGON BALL EDITION (Intel Core i5-13400F | RTX 3060 12GB | 16GB RAM | 512GB SSD | Tản Khí ARGB)',
 3, N'PCM Build', 21500000, 18990000, 7, 36, N'./anh pc/pc2.jpg',
 N'CPU: Intel Core i5-13400F (10 nhân 16 luồng, tới 4.6GHz) | Mainboard: ASUS Prime B760M-A | RAM: 16GB DDR4 3200MHz | VGA: Gigabyte RTX 3060 12GB GDDR6 (VRAM lớn làm đồ họa & AI tốt) | SSD: 512GB NVMe | Nguồn: 650W 80 Plus | Case: Gaming Mid-Tower LED RGB',
 N'Bộ PC Gaming & Học tập đa năng với card RTX 3060 bản 12GB VRAM cực kỳ phù hợp cho cả chơi game lẫn chạy Stable Diffusion, Premiere.',
 3, 0, 12, N'Đang kinh doanh'),

(N'PCGM0208', N'PC PCM WHITE SNOW ARGB (AMD Ryzen 5 7600 | RTX 4060 Ti 8GB | 32GB DDR5 | 1TB NVMe Gen4)',
 3, N'PCM Build', 31990000, 28490000, 5, 36, N'./anh pc/pc3.jpg',
 N'CPU: AMD Ryzen 5 7600 (6 nhân 12 luồng, tới 5.1GHz, Socket AM5) | Mainboard: B650M AORUS Elite AX | RAM: 32GB (2x16GB) DDR5 6000MHz RGB White | VGA: RTX 4060 Ti 8GB White Edition | SSD: 1TB PCIe 4.0 NVMe | Tản nhiệt: Nước AIO 240mm White ARGB | Nguồn: 750W 80 Plus Gold',
 N'Bộ PC Full Trắng tuyệt đẹp trên nền tảng AMD AM5 DDR5 mới nhất, dễ dàng nâng cấp về sau.',
 4, 0, 9, N'Đang kinh doanh'),

(N'PCGM0215', N'PC PCM ESPORTS PRO (Intel Core i3-12100F | GTX 1660 Super 6GB | 16GB RAM | 512GB SSD)',
 3, N'PCM Build', 12990000, 10890000, 15, 36, N'./anh pc/pc4.jpg',
 N'CPU: Intel Core i3-12100F (4 nhân 8 luồng, 4.3GHz) | Mainboard: H610M-E DDR4 | RAM: 16GB DDR4 3200MHz | VGA: GTX 1660 Super 6GB GDDR6 | SSD: 512GB NVMe M.2 | Nguồn: 550W CST | Case: Xigmatek 3 Fan LED',
 N'Cấu hình tiết kiệm cho học sinh - sinh viên học tập lập trình, chỉnh sửa ảnh nhẹ nhàng và chơi mượt Liên Minh Huyền Thoại, FIFA Online 4.',
 2, 0, 22, N'Đang kinh doanh'),

-- 4. PC Đồ Họa, Thiết Kế, AI (CategoryId = 4)
(N'PCI0212', N'PC ULTRA GAMING AI - PCAP TITAN PRO (Core i7-14700K | RTX 4070 Ti SUPER 16GB | 32GB DDR5 | 1TB SSD)',
 4, N'PCM Build', 45999000, 41990000, 5, 36, N'./anh pc/pc1.png',
 N'CPU: Intel Core i7-14700K (20 nhân 28 luồng, tới 5.6GHz) | Mainboard: Z790 AORUS Elite AX | RAM: 32GB (2x16GB) DDR5 6000MHz | VGA: NVIDIA GeForce RTX 4070 Ti SUPER 16GB GDDR6X | SSD: 1TB Samsung 990 PRO PCIe 4.0 NVMe | Tản nhiệt: AIO 360mm Display LCD | Nguồn: 850W 80 Plus Gold ATX 3.0',
 N'Máy trạm Workstation chuyên nghiệp phục vụ huấn luyện mô hình AI/Deep Learning, dựng hình 3Ds Max, V-Ray, Lumion, Blender và dựng phim 4K/8K.',
 4, 0, 11, N'Đang kinh doanh'),

(N'PCWS0302', N'PC WORKSTATION CREATOR 3D (Intel Core i9-14900K | RTX 4080 SUPER 16GB | 64GB DDR5 | 2TB Gen4 SSD)',
 4, N'PCM Build', 68900000, 63500000, 3, 36, N'./anh pc/pc5.jpg',
 N'CPU: Intel Core i9-14900K (24 nhân 32 luồng, tới 6.0GHz) | Mainboard: ASUS ProArt Z790-CREATOR WIFI | RAM: 64GB (2x32GB) DDR5 6000MHz | VGA: RTX 4080 SUPER 16GB GDDR6X | SSD: 2TB NVMe Gen4 (7400MB/s) | Tản nhiệt: AIO 360mm Cao Cấp | Nguồn: 1000W 80 Plus Platinum',
 N'Đỉnh cao máy trạm đồ họa kiến trúc và AI Studio, đảm bảo vận hành liên tục 24/7 với linh kiện chuẩn Workstation.',
 4, 0, 5, N'Đang kinh doanh'),

-- 5. PC Văn Phòng - Làm Việc (CategoryId = 5)
(N'PCIT0122', N'Bộ Mini PC ASUS NUC13 PRO Tall NUC13ANHH5 (Intel Core i5-1340P | 16GB DDR4 | 512GB NVMe | Wi-Fi 6E)',
 5, N'ASUS', 11290000, 99890000 / 10, 14, 36, N'./anh pc/minipc.jpg',
 N'CPU: Intel Core i5-1340P (12 nhân 16 luồng, tới 4.6GHz) | Đồ họa: Intel Iris Xe Graphics hỗ trợ xuất 4 màn hình 4K | RAM: 16GB DDR4 3200MHz | Ổ cứng: 512GB M.2 PCIe Gen4 SSD | Kết nối: 2x Thunderbolt 4, 2x HDMI 2.1, LAN 2.5GbE, Wi-Fi 6E | Kích thước: Siêu nhỏ gọn 117 x 112 x 54 mm (Gắn sau màn hình VESA)',
 N'Bộ Mini PC ASUS NUC 13 Pro nhỏ gọn trong lòng bàn tay, tiết kiệm điện năng tối đa và vận hành êm ái cho văn phòng hiện đại.',
 1, 0, 17, N'Đang kinh doanh'),

(N'PCOF0105', N'PC Văn Phòng PCM OFFICE PRO S1 (Intel Core i5-12400 | 16GB RAM | 512GB NVMe SSD | Wifi)',
 5, N'PCM Build', 10500000, 8990000, 20, 36, N'./anh pc/pc6.jpg',
 N'CPU: Intel Core i5-12400 (Có đồ họa tích hợp Intel UHD 730) | Mainboard: ASUS H610M-K D4 | RAM: 16GB DDR4 3200MHz | SSD: 512GB M.2 NVMe | Nguồn: 450W Công suất thực | Vỏ case: Văn phòng nhỏ gọn mát mẻ kèm thu Wi-Fi',
 N'Giải pháp máy tính văn phòng bền bỉ cho kế toán, nhân sự, bán hàng, khởi động Windows trong 5 giây.',
 2, 0, 35, N'Đang kinh doanh'),

-- 6. Linh Kiện Máy Tính (CategoryId = 6)
(N'VGGI0324', N'VGA Gigabyte GeForce RTX 3060 WINDFORCE OC 12GB (GDDR6 | 192-bit | Dual Fan)',
 6, N'Gigabyte', 8999000, 7999000, 16, 36, N'./anh pc/vga.jpg',
 N'GPU: NVIDIA GeForce RTX 3060 | Bộ nhớ VRAM: 12GB GDDR6 | Bus bộ nhớ: 192-bit | Xung nhịp Boost: 1792 MHz | Số nhân CUDA: 3584 | Tản nhiệt: WINDFORCE 2X với 2 quạt 90mm quay đảo chiều | Cổng xuất hình: 2x DisplayPort 1.4a, 2x HDMI 2.1 | Nguồn khuyến nghị: 550W (1 đầu 8-pin)',
 N'Card màn hình quốc dân Gigabyte RTX 3060 12GB OC sở hữu dung lượng VRAM 12GB cực lớn, hoạt động mát mẻ và bền bỉ.',
 2, 0, 42, N'Đang kinh doanh'),

(N'CPIN1490', N'CPU Intel Core i9-14900K (24 Nhân 32 Luồng | Up to 6.0GHz | 36MB Cache | Socket LGA1700)',
 6, N'Intel', 16490000, 14690000, 11, 36, N'./anh pc/cpu.jpg',
 N'Số nhân / Số luồng: 24 Nhân (8 P-core + 16 E-core) / 32 Luồng | Xung nhịp tối đa: 6.0 GHz (Thermal Velocity Boost) | Bộ nhớ đệm: 36MB Intel Smart Cache | Đồ họa tích hợp: Intel UHD Graphics 770 | Hỗ trợ RAM: DDR5 5600MHz & DDR4 3200MHz | Điện năng TDP: 125W (Max Turbo 253W) | Socket: FCLGA1700',
 N'Bộ vi xử lý Intel Core i9-14900K mở khóa hệ số nhân, mang lại tốc độ xung nhịp lên tới 6.0GHz cho trải nghiệm gaming và sáng tạo nội dung đỉnh cao.',
 2, 0, 18, N'Đang kinh doanh'),

(N'CPIN1340', N'CPU Intel Core i5-13400F (10 Nhân 16 Luồng | Up to 4.6GHz | 20MB Cache | LGA1700)',
 6, N'Intel', 5890000, 4890000, 25, 36, N'./anh pc/cpu.jpg',
 N'Số nhân / Số luồng: 10 Nhân (6 P-core + 4 E-core) / 16 Luồng | Xung nhịp Turbo: 4.6 GHz | Bộ nhớ đệm: 20MB Intel Smart Cache | Hỗ trợ bộ nhớ: DDR4-3200 / DDR5-4800 | Điện năng cơ bản: 65W | Kèm quạt tản nhiệt Intel Laminar RM1 trong hộp',
 N'Vi xử lý tầm trung đáng mua nhất cho các cấu hình PC Gaming và đồ họa phổ thông.',
 1, 0, 39, N'Đang kinh doanh'),

(N'VGAS4060', N'VGA ASUS Dual GeForce RTX 4060 OC Edition 8GB GDDR6 (DLSS 3 | Axial-tech Fan)',
 6, N'ASUS', 9690000, 8490000, 14, 36, N'./anh pc/vga.jpg',
 N'GPU: NVIDIA GeForce RTX 4060 | VRAM: 8GB GDDR6 128-bit | Nhân CUDA: 3072 | Xung nhịp OC Mode: 2535 MHz | Công nghệ: DLSS 3, Ray Tracing thế hệ 3, NVIDIA Reflex | Quạt: 2x Axial-tech với chế độ 0dB | Nguồn đề xuất: 550W',
 N'Card đồ họa kiến trúc Ada Lovelace tiết kiệm điện năng, hiệu năng Ray Tracing và Frame Generation vượt trội.',
 2, 0, 27, N'Đang kinh doanh'),

-- 7. Màn Hình, Máy In (CategoryId = 7)
(N'MOSS0148', N'Màn Hình Đồ Họa SAMSUNG ViewFinity S8 LS27B800 (27 inch | 4K UHD | IPS | 98% DCI-P3 | USB-C 90W)',
 7, N'Samsung', 8589000, 7689000, 9, 24, N'./anh pc/monitor_ss.jpg',
 N'Kích thước: 27 inch Phẳng | Độ phân giải: 4K UHD (3840 x 2160) | Tấm nền: IPS chống chói Matte Display | Độ phủ màu: 98% DCI-P3, Pantone Validated, HDR400 | Cổng kết nối: USB-C (Sạc 90W + Truyền hình ảnh), HDMI 2.0, DisplayPort 1.4, Hub USB 3.0, cổng LAN RJ45 | Chân đế: Công thái học nâng hạ, xoay dọc Pivot',
 N'Màn hình đồ họa chuyên nghiệp Samsung ViewFinity S8 4K chuẩn màu Pantone, tích hợp cổng USB-C 90W cực tiện lợi cho MacBook và Laptop cao cấp.',
 4, 0, 21, N'Đang kinh doanh'),

(N'MOSS0185', N'Màn Hình Gaming SAMSUNG Odyssey OLED G9 G93SC (49 inch | Dual QHD 5120x1440 | OLED 240Hz | 0.03ms)',
 7, N'Samsung', 39989000, 28449000, 4, 24, N'./anh pc/man1.jpg',
 N'Kích thước: 49 inch Siêu rộng tỉ lệ 32:9 Cong 1800R | Độ phân giải: Dual QHD (5120 x 1440) tương đương 2 màn 27 inch 2K ghép lại | Tấm nền: Quantum Dot OLED | Tần số quét: 240Hz | Thời gian phản hồi: 0.03ms (GtG) | Độ phủ màu: 99% DCI-P3, DisplayHDR True Black 400 | Kết nối: DisplayPort 1.4, HDMI 2.1, Micro HDMI, USB Hub',
 N'Tuyệt tác màn hình cong siêu rộng 49 inch OLED 240Hz mang lại không gian hiển thị choáng ngợp cho Sim Racing, Gaming và đa nhiệm.',
 4, 0, 8, N'Đang kinh doanh'),

-- 8. Bàn Phím, Chuột - Gaming / Máy chơi game (CategoryId = 8)
(N'NBAS1535', N'Máy Chơi Game Cầm Tay ASUS ROG Ally RC71L-NH002W (AMD Ryzen Z1 Extreme | 16GB LPDDR5 | 512GB SSD | 7 inch FHD 120Hz)',
 8, N'ASUS', 14990000, 13490000, 8, 24, N'./anh pc/rog_ally.jpg',
 N'Vi xử lý: AMD Ryzen Z1 Extreme (8 nhân 16 luồng, kiến trúc Zen 4, đồ họa RDNA 3 8.6 TFlops) | RAM: 16GB LPDDR5 6400MHz Dual Channel | Ổ cứng: 512GB PCIe 4.0 NVMe M.2 SSD | Màn hình: 7 inch FHD (1920x1080) IPS Cảm ứng 120Hz, 500 nits, Gorilla Glass Victus | Trọng lượng: 608g | Hệ điều hành: Windows 11 Home bản quyền (Chơi mọi game Steam, Epic, Xbox Game Pass)',
 N'Máy chơi game cầm tay chạy Windows 11 mạnh mẽ nhất từ ASUS ROG, cho phép chiến mượt các tựa game PC AAA mọi lúc mọi nơi.',
 1, 0, 19, N'Đang kinh doanh'),

-- 9. Các sản phẩm và phụ kiện công nghệ (Khai thác 100% hình ảnh trong ./anh pc/)
(N'ACCP0101', N'Bộ Hub Chuyển Đổi Đa Năng PCM Type-C 8-in-1 (HDMI 4K, LAN 1Gbps, PD 100W, USB 3.0)',
 9, N'PCM', 1590000, 1190000, 30, 12, N'./anh pc/acc_hub.jpg',
 N'Chất liệu: Hợp kim nhôm CNC tản nhiệt nhanh | Cổng kết nối: 1x HDMI 4K@60Hz, 1x RJ45 Gigabit LAN, 3x USB-A 3.2, 1x USB-C PD 100W, Khe thẻ SD/MicroSD | Tương thích: Laptop Windows, MacBook, ROG Ally, iPad',
 N'Phụ kiện mở rộng kết nối toàn diện cho Laptop mỏng nhẹ và máy chơi game cầm tay.',
 1, 0, 26, N'Đang kinh doanh'),

(N'ACST0102', N'Giá Đỡ Laptop Nhôm PCM Stand Pro Xoay 360 Độ (Hợp Kim Nhôm CNC, Đệm Silicon Chống Trầy)',
 9, N'PCM', 450000, 320000, 85, 12, N'./anh pc/acc_stand.jpg',
 N'Chất liệu: Hợp kim nhôm nguyên khối cắt CNC | Khả năng xoay: 360 độ linh hoạt | Tương thích: Laptop và máy tính bảng từ 10 - 17.3 inch | Tải trọng: Lên đến 10kg | Đệm silicon: Chống trơn trượt và chống trầy xước',
 N'Giá đỡ laptop công thái học cao cấp giúp điều chỉnh độ cao góc nhìn chuẩn, giảm mỏi cổ vai gáy và hỗ trợ tản nhiệt đáy máy tối ưu.',
 1, 0, 42, N'Đang kinh doanh'),

(N'AUDV0102', N'Loa Vi Tính Edifier R1280DB Bluetooth Vỏ Gỗ Cao Cấp (Công Suất 42W RMS | Cổng Optical & Coaxial)',
 10, N'Edifier', 2590000, 2190000, 25, 24, N'./anh pc/speaker_edifier.jpg',
 N'Công suất tổng: 42W RMS | Củ loa: Bass 4 inch, Treble lụa 13mm | Kết nối: Bluetooth 5.0, Optical, Coaxial, Dual RCA AUX | Điều khiển: Núm chỉnh Bass/Treble/Volume bên hông và Remote điều khiển từ xa',
 N'Mẫu loa để bàn vỏ gỗ acoustic sang trọng, âm trầm sâu lắng và âm cao trong trẻo cho không gian làm việc giải trí.',
 2, 0, 38, N'Đang kinh doanh'),

(N'AUDH0101', N'Tai Nghe Gaming Kingston HyperX Cloud II Red 7.1 Virtual Surround (Khung Nhôm Siêu Bền, Mic Khử Ồn)',
 10, N'HyperX', 2490000, 1890000, 35, 24, N'./anh pc/headset_hyperx.jpg',
 N'Màng loa: Driver Dynamic 53mm với nam châm đất hiếm Neodymium | Âm thanh: Âm vòm ảo 7.1 thông qua soundcard USB rời | Đệm tai: Mút hoạt tính bọc da cao cấp | Microphone: Định hướng có thể tháo rời, lọc tạp âm',
 N'Dòng tai nghe huyền thoại được giới game thủ và streamer ưa chuộng nhờ chất âm trung thực, khả năng định vị tiếng bước chân chuẩn xác.',
 1, 0, 65, N'Đang kinh doanh'),

(N'AUDW0103', N'Webcam Logitech C922 Pro Stream Full HD 1080p 60fps (Kèm Chân Tripod Để Bàn, 2 Mic Lọc Ồn)',
 10, N'Logitech', 2690000, 2090000, 30, 24, N'./anh pc/webcam_logi.jpg',
 N'Độ phân giải video: Full HD 1080p ở 30fps hoặc 720p siêu mượt ở 60fps | Ống kính: Kính Full HD tự động lấy nét Autofocus | Góc nhìn: 78 độ | Âm thanh: 2 mic thu đa hướng lọc tạp âm | Phụ kiện: Chân Tripod mini',
 N'Webcam chuyên dụng dành cho streamer và họp trực tuyến chuyên nghiệp, tự động cân bằng sáng trong điều kiện thiếu sáng.',
 1, 0, 38, N'Đang kinh doanh'),

(N'COOL0103', N'Tản Nhiệt Nước AIO NZXT Kraken Elite 360 RGB White LCD (Màn Hình 2.36 inch | 3 Fan 120mm)',
 11, N'NZXT', 7890000, 6990000, 15, 72, N'./anh pc/aio_nzxt.jpg',
 N'Kích thước Radiator: 360mm nhôm nguyên khối màu trắng | Màn hình: LCD 2.36 inch độ phân giải 640x640, hiển thị GIF và nhiệt độ thời gian thực | Quạt: 3x F120 RGB Core Fans | Bơm: Asetek 7th Gen tốc độ 2800 RPM',
 N'Tuyệt tác tản nhiệt nước AIO cao cấp nhất của NZXT, màn hình LCD tùy biến ảnh động độc đáo và hiệu năng làm mát đỉnh cao.',
 3, 1, 22, N'Đang kinh doanh'),

(N'COOL0104', N'Tản Nhiệt Khí DeepCool AG620 ARGB Dual Tower (6 Ống Đồng, 2 Quạt 120mm PWM, TDP 260W)',
 11, N'DeepCool', 1150000, 890000, 40, 24, N'./anh pc/cooler_air.jpg',
 N'Số ống dẫn nhiệt: 6 ống đồng D6mm mạ niken | Quạt làm mát: 2x 120mm Hydro Bearing PWM (300-1850 RPM) | Đèn LED: ARGB Sync 5V 3-pin | Khả năng tản nhiệt (TDP): 260W | Socket tương thích: Intel LGA1700/1200/115x và AMD AM5/AM4',
 N'Tản nhiệt khí tháp đôi hiệu năng cao của DeepCool với khả năng làm mát êm ái cho các vi xử lý Core i7/i9 và Ryzen 7/9.',
 2, 1, 35, N'Đang kinh doanh'),

(N'NETW0104', N'Camera IP Wifi IMOU Ranger 2 4MP 2K Xoay 360 Độ (AI Phát Hiện Người, Đàm Thoại 2 Chiều)',
 12, N'IMOU', 990000, 690000, 60, 24, N'./anh pc/cam_imou.jpg',
 N'Độ phân giải: 4.0 Megapixel (2K QHD 2560x1440) | Góc quay quét: Ngang 355 độ, dọc -5 đến 80 độ | AI thông minh: Phát hiện người, bám theo chuyển động Smart Tracking, còi báo động | Đàm thoại: 2 chiều to rõ | Lưu trữ: Thẻ MicroSD up to 256GB hoặc Cloud',
 N'Camera giám sát gia đình thông minh góc nhìn toàn cảnh 360 độ không điểm mù, hồng ngoại ban đêm rõ nét.',
 1, 0, 75, N'Đang kinh doanh'),

(N'NETW0105', N'Hệ Thống Mesh Wi-Fi 6 TP-Link Deco X20 AX1800 (Bộ 2 Thiết Bị Băng Tần Kép Phủ Sóng 370m2)',
 12, N'TP-Link', 2890000, 2290000, 25, 24, N'./anh pc/mesh_tplink.jpg',
 N'Tốc độ: 1201 Mbps (5GHz) + 574 Mbps (2.4GHz) | Công nghệ: Wi-Fi 6, OFDMA, MU-MIMO, Seamless Roaming | Kết nối: Lên tới 150 thiết bị đồng thời | Cổng mạng: Mỗi thiết bị có 2 cổng Gigabit LAN/WAN tự nhận | Quản lý: Ứng dụng TP-Link Deco',
 N'Giải pháp phủ sóng mạng toàn bộ ngôi nhà hoặc văn phòng nhiều tầng không góc chết, chuyển vùng mượt mà một tên Wi-Fi duy nhất.',
 1, 0, 28, N'Đang kinh doanh'),

(N'NETW0106', N'Router Wi-Fi 6 Gaming ASUS RT-AX82U V2 Chuẩn AX5400 (RGB Aura Sync, Mobile Game Mode, AiProtection Pro)',
 12, N'ASUS', 4290000, 3690000, 20, 36, N'./anh pc/router_asus.jpg',
 N'Băng thông: AX5400 (4804 Mbps trên 5GHz + 574 Mbps trên 2.4GHz) | Đèn RGB: Asus Aura Sync tùy biến hàng triệu màu | Tính năng chơi game: Cổng chuyên dụng Gaming Port, Chế độ Mobile Game Mode giảm ping | Bảo mật: Trend Micro AiProtection Pro trọn đời',
 N'Bộ phát Wi-Fi gaming chuyên nghiệp tối ưu đường truyền cho game thủ, thiết kế đậm chất chiến binh và hệ thống đèn Aura RGB rực rỡ.',
 2, 0, 19, N'Đang kinh doanh'),

(N'PHON0105', N'Thiết Bị Chơi Game Di Động ASUS ROG Ally X 2024 (Ryzen Z1 Extreme | 24GB RAM | 1TB SSD | Pin 80Wh)',
 13, N'ASUS', 24990000, 22990000, 5, 24, N'./anh pc/rog_ally.jpg',
 N'CPU: AMD Ryzen Z1 Extreme | RAM: 24GB LPDDR5X-7500 | SSD: 1TB M.2 2280 PCIe 4.0 | Pin: 80Wh gấp đôi thời lượng sử dụng | Cổng: 2x USB-C (1x USB4 Thunderbolt)',
 N'Phiên bản nâng cấp hoàn hảo của thiết bị di động chơi game cầm tay với 24GB RAM và pin 80Wh.',
 2, 0, 10, N'Đang kinh doanh'),

(N'PS5S0101', N'Máy Chơi Game Sony PlayStation 5 (PS5) Slim Standard Edition 1TB (Có Ổ Đĩa Blu-ray 4K Ultra HD)',
 13, N'Sony', 15490000, 13990000, 15, 12, N'./anh pc/console_ps5.jpg',
 N'Bộ vi xử lý: AMD Ryzen Zen 2 8 nhân 16 luồng up to 3.5GHz | Đồ họa: AMD Radeon RDNA 2 up to 2.23GHz (10.3 TFLOPS) | Bộ nhớ: 16GB GDDR6 256-bit | Ổ cứng: 1TB NVMe SSD tốc độ cao | Tay cầm: DualSense không dây Haptic Feedback',
 N'Thế hệ máy chơi game PlayStation 5 Slim thiết kế mỏng nhẹ hơn 30%, ổ cứng 1TB rộng rãi cùng khả năng xuất hình 4K 120Hz và Ray Tracing chân thực.',
 3, 1, 30, N'Đang kinh doanh'),

(N'CPUA7800', N'CPU AMD Ryzen 7 7800X3D (8 Nhân 16 Luồng | Up to 5.0GHz | 104MB Cache 3D V-Cache | Socket AM5)',
 6, N'AMD', 11990000, 10490000, 20, 36, N'./anh pc/cpu_amd.jpg',
 N'Số nhân / Số luồng: 8 Nhân 16 Luồng | Xung nhịp: Cơ bản 4.2GHz, Boost tối đa 5.0GHz | Bộ nhớ đệm L3: 96MB (Tổng Cache 104MB với công nghệ 3D V-Cache) | Chuẩn socket: AMD AM5 | TDP: 120W',
 N'Vi xử lý chơi game mạnh nhất hiện nay từ AMD được trang bị công nghệ 3D V-Cache độc quyền, tối ưu khung hình FPS mượt mà cho mọi tựa game Esports và AAA.',
 2, 1, 45, N'Đang kinh doanh'),

(N'KBAK0101', N'Bàn Phím Cơ Akko 3087 v2 Dragon Ball Super Goku (Akko Pink Switch v2, Keycap PBT Dye-Sub)',
 8, N'Akko', 1690000, 1390000, 25, 12, N'./anh pc/kb_akko.jpg',
 N'Layout: TKL 87 phím gọn gàng | Switch: Akko Pink Switch v2 (Linear, lực nhấn 45g) | Keycap: PBT Dye-subbed OEM profile họa tiết Goku bản quyền Toei | Kết nối: Cáp USB Type-C rời | Hỗ trợ: N-Key Rollover',
 N'Phiên bản đặc biệt Dragon Ball Son Goku với bộ keycap bền màu vĩnh viễn, cảm giác gõ êm mượt và hành trình phím nhạy bén.',
 2, 0, 52, N'Đang kinh doanh'),

(N'KBLG0102', N'Bàn Phím Cơ Không Dây Logitech G Pro X TKL Lightspeed RGB (GX Brown Switch, Kết Nối Đa Thiết Bị)',
 8, N'Logitech', 4790000, 3990000, 18, 24, N'./anh pc/kb_logitech.jpg',
 N'Công nghệ không dây: LIGHTSPEED độc quyền độ trễ 1ms + Bluetooth + Dây Type-C | Switch: GX Brown Tactile | Keycap: PBT Double-shot | Thời lượng pin: Lên đến 50 giờ chơi liên tục | Đèn LED: LIGHTSYNC RGB',
 N'Bàn phím cơ thi đấu thể thao điện tử chuẩn Pro được kiểm chứng bởi các tuyển thủ Esports thế giới, thiết kế bền bỉ kèm túi đựng du lịch cao cấp.',
 3, 1, 29, N'Đang kinh doanh'),

(N'MSLG0103', N'Chuột Gaming Logitech G502 HERO High Performance (Cảm Biến HERO 25.600 DPI, 11 Phím Lập Trình, Bộ Tạ Rời)',
 8, N'Logitech', 1390000, 990000, 50, 24, N'./anh pc/mouse_g502.jpg',
 N'Cảm biến: HERO 25K (DPI 100 - 25.600) | Tốc độ quét: > 400 IPS, gia tốc 40G | Phím bấm: 11 nút bấm có thể gán macro | Con lăn: Cuộn vô cực siêu nhanh Dual-mode | Phụ kiện: 5 tạ kim loại 3.6g',
 N'Mẫu chuột gaming bán chạy nhất hành tinh, công thái học vừa vặn lòng bàn tay, mắt đọc siêu chuẩn không gia tốc ảo.',
 2, 1, 110, N'Đang kinh doanh'),

(N'MSRZ0104', N'Chuột Gaming Siêu Nhẹ Razer DeathAdder V3 Pro Wireless (Cảm Biến Focus Pro 30K, Trọng Lượng Siêu Nhẹ 63g)',
 8, N'Razer', 3890000, 3190000, 20, 24, N'./anh pc/mouse_razer.jpg',
 N'Trọng lượng: Siêu nhẹ chỉ 63 gram | Cảm biến: Quang học Focus Pro 30K Optical Sensor | Switch: Razer Optical Mouse Gen-3 (Tuổi thọ 90 triệu lần nhấn) | Thời lượng pin: Lên tới 90 giờ',
 N'Tuyệt phẩm chuột gaming không dây siêu nhẹ cho game thủ bắn súng FPS chuyên nghiệp, form cầm DeathAdder huyền thoại được cải tiến tối đa.',
 2, 0, 34, N'Đang kinh doanh'),

(N'NBDE0934', N'Laptop Dell XPS 13 9340 (Intel Core Ultra 7 155H | 16GB LPDDR5X | 512GB PCIe Gen4 | 13.4 inch FHD+ IPS | Platinum)',
 2, N'Dell', 42990000, 38990000, 12, 24, N'./anh pc/lap_dell_xps.jpg',
 N'CPU: Intel Core Ultra 7 155H (16 nhân 22 luồng, tích hợp NPU Intel AI Boost) | RAM: 16GB LPDDR5X 7467MHz | Ổ cứng: 512GB M.2 PCIe NVMe SSD | Màn hình: 13.4 inch FHD+ 120Hz 500 nits 100% sRGB | Trọng lượng: 1.19 kg | Vỏ nhôm CNC Platinum',
 N'Đỉnh cao của dòng Ultrabook doanh nhân cao cấp với bàn phím liền mạch không viền Zero-lattice, touchpad vô hình và chip AI xử lý thông minh.',
 3, 1, 16, N'Đang kinh doanh'),

(N'NBHP0207', N'Laptop HP Pavilion 14-dv2073TU (Intel Core i5-1235U | 16GB RAM | 512GB SSD | 14 inch FHD IPS | Vàng Gold)',
 2, N'HP', 17890000, 15490000, 25, 12, N'./anh pc/lap_hp.jpg',
 N'CPU: Intel Core i5-1235U (10 nhân 12 luồng, Turbo 4.4GHz) | RAM: 16GB DDR4 3200MHz | Ổ cứng: 512GB PCIe NVMe M.2 SSD | Màn hình: 14 inch Full HD IPS chống chói | Âm thanh: Bang & Olufsen | Trọng lượng: 1.41 kg',
 N'Mẫu laptop thời trang mỏng nhẹ với tông màu vàng đồng lịch lãm, thời lượng pin cả ngày, hoàn hảo cho nhân viên văn phòng và sinh viên.',
 2, 0, 48, N'Đang kinh doanh'),

(N'NBLN015I', N'Laptop Lenovo IdeaPad Slim 3 15IAH8 (Intel Core i5-12450H | 16GB LPDDR5 | 512GB SSD | 15.6 inch FHD IPS)',
 2, N'Lenovo', 15990000, 13990000, 30, 24, N'./anh pc/lap_lenovo.jpg',
 N'CPU: Intel Core i5-12450H (8 nhân 12 luồng, dòng H hiệu năng cao 45W) | RAM: 16GB LPDDR5 4800MHz | Ổ cứng: 512GB SSD PCIe NVMe | Màn hình: 15.6 inch FHD IPS 300 nits | Độ bền: MIL-STD-810H | Trọng lượng: 1.62 kg',
 N'Trang bị chip dòng H mạnh mẽ vượt trội trong phân khúc giá phổ thông, bàn phím số đầy đủ thuận tiện nhập liệu kế toán và học tập.',
 1, 0, 55, N'Đang kinh doanh'),

(N'NBTP0145', N'Laptop Lenovo ThinkPad E14 Gen 5 (Intel Core i7-1355U | 16GB DDR4 | 512GB NVMe SSD | 14 inch WUXGA IPS)',
 2, N'Lenovo', 23490000, 20990000, 20, 36, N'./anh pc/lap_thinkpad.jpg',
 N'CPU: Intel Core i7-1355U (10 nhân 12 luồng) | RAM: 16GB DDR4 3200MHz | Ổ cứng: 512GB SSD M.2 PCIe 4.0 | Màn hình: 14 inch WUXGA (1920x1200) 16:10 sắc nét 300 nits | Bàn phím: ThinkPad TrackPoint chống tràn nước',
 N'Dòng máy ThinkPad biểu tượng về độ bền bỉ và bàn phím gõ sướng nhất thế giới, bảo hành chính hãng 3 năm an tâm tuyệt đối.',
 2, 0, 31, N'Đang kinh doanh'),

(N'MBAS0760', N'Mainboard ASUS ROG STRIX B760-A GAMING WIFI D4 (Socket LGA1700 | ATX | PCIe 5.0 | Wi-Fi 6E)',
 6, N'ASUS', 6290000, 5490000, 18, 36, N'./anh pc/main_asus.jpg',
 N'Chipset: Intel B760 | Socket: LGA1700 (Hỗ trợ Gen 12, 13, 14) | Pha nguồn: 12+1 Power Stages 60A | Khe RAM: 4 khe DDR4 up to 5333MHz | Khe mở rộng: 1x PCIe 5.0 x16 bọc kim loại SafeSlot | M.2: 3 khe PCIe 4.0 tản nhiệt nhôm',
 N'Bo mạch chủ phân khúc cao cấp phối màu trắng bạc thời thượng, linh kiện chuẩn ROG mang lại khả năng cấp điện ổn định và thẩm mỹ tuyệt đỉnh.',
 2, 0, 22, N'Đang kinh doanh'),

(N'MBMS0760', N'Mainboard MSI B760M BOMBER DDR4 (Socket LGA1700 | M-ATX | Core Boost | Khe PCIe Steel Armor)',
 6, N'MSI', 2590000, 2190000, 35, 36, N'./anh pc/main_b760.jpg',
 N'Chipset: Intel B760 | Kích thước: Micro-ATX nhỏ gọn | Khe RAM: 2 khe DDR4 Dual Channel up to 4800+ MHz (OC) | Lưu trữ: 2 khe M.2 PCIe 4.0 x4 tốc độ cao | Cổng mạng: Realtek 2.5Gbps LAN',
 N'Mainboard quốc dân cho các dàn máy Gaming và đồ họa giá rẻ, chạy mượt các vi xử lý Core i5-12400F và i5-13400F.',
 1, 0, 68, N'Đang kinh doanh'),

(N'MOAS0278', N'Màn Hình Đồ Họa ASUS ProArt Display PA278CV (27 inch | 2K QHD 2560x1440 | IPS | 100% sRGB | Type-C 65W)',
 7, N'ASUS', 9490000, 8290000, 15, 36, N'./anh pc/mon_asus.jpg',
 N'Kích thước: 27 inch | Độ phân giải: 2K WQHD (2560x1440) | Tấm nền: IPS 178 độ | Màu sắc: 100% sRGB, 100% Rec. 709, Delta E < 2 | Chứng nhận: Calman Verified cân màu sẵn | Cổng kết nối: USB-C sạc 65W, HDMI, DisplayPort Daisy-chain',
 N'Màn hình chuẩn đồ họa chuyên nghiệp cho designer, editor dựng phim với độ chuẩn màu tuyệt đối và kết nối 1 cáp Type-C tiện lợi.',
 2, 1, 27, N'Đang kinh doanh'),

(N'MOLG027G', N'Màn Hình Gaming LG UltraGear 27GR75Q-B (27 inch | 2K QHD | 165Hz 1ms IPS | G-Sync Compatible | HDR10)',
 7, N'LG', 7690000, 6590000, 22, 24, N'./anh pc/mon_lg.jpg',
 N'Kích thước: 27 inch | Độ phân giải: 2K QHD (2560x1440) | Tần số quét: 165Hz | Thời gian phản hồi: 1ms (GtG) | Tấm nền: IPS 99% sRGB | Công nghệ: G-Sync Compatible, FreeSync Premium | Chân đế: Điều chỉnh độ cao, xoay dọc 90 độ',
 N'Dòng màn hình UltraGear thế hệ mới mang đến trải nghiệm đồ họa sắc nét gấp 1.7 lần Full HD và triệt tiêu hoàn toàn hiện tượng xé hình khi chơi game.',
 2, 1, 41, N'Đang kinh doanh'),

(N'PCGM0211', N'PC Gaming PCM Cyberpunk ARGB (Intel Core i5-13600K | RTX 4070 12GB | 32GB RAM DDR5 | 1TB NVMe | Case Kính)',
 3, N'PCM', 32900000, 28990000, 10, 36, N'./anh pc/pc11.jpg',
 N'CPU: Intel Core i5-13600K (14 nhân 20 luồng, up to 5.1GHz) | Tản nhiệt: Nước AIO 240 ARGB | Mainboard: B760 Gaming WiFi D5 | RAM: 32GB DDR5 5600MHz RGB | VGA: NVIDIA GeForce RTX 4070 12GB GDDR6X | Ổ cứng: 1TB NVMe Gen4 SSD | Nguồn: 750W 80 Plus',
 N'Cấu hình chiến mượt mọi tựa game AAA ở độ phân giải 2K max setting, ray tracing đỉnh cao và khả năng render video đồ họa vượt trội.',
 3, 1, 18, N'Đang kinh doanh'),

(N'PCWS0307', N'PC Đồ Họa PCM MASTER ARTIST (AMD Ryzen 9 7900X | RTX 4070 Ti 12GB | 32GB DDR5 | 1TB Gen4 SSD | Case Lian Li)',
 4, N'PCM', 48900000, 43900000, 8, 36, N'./anh pc/pc7.jpg',
 N'CPU: AMD Ryzen 9 7900X (12 nhân 24 luồng, Turbo 5.6GHz) | Tản nhiệt: AIO 360mm ARGB | Mainboard: X670 Gaming WiFi | RAM: 32GB DDR5 6000MHz | VGA: RTX 4070 Ti 12GB GDDR6X | SSD: 1TB Samsung Gen4 tốc độ 7000MB/s | Nguồn: 850W 80 Plus Gold | Case: Lian Li O11 Dynamic EVO',
 N'Trạm đồ họa cao cấp chuyên dụng cho dựng hình 3D Maya, Blender, kiến trúc AutoCAD và dựng phim 4K After Effects tốc độ siêu tốc.',
 3, 0, 11, N'Đang kinh doanh'),

(N'PCGM0209', N'PC Gaming PCM ARGB Prism Edition (Intel Core i7-13700F | RTX 4060 Ti 8GB | 32GB RAM DDR4 | 1TB NVMe SSD)',
 3, N'PCM', 26900000, 23990000, 14, 36, N'./anh pc/pc9.png',
 N'CPU: Intel Core i7-13700F (16 nhân 24 luồng, up to 5.2GHz) | Tản nhiệt: Khí RGB 4 ống đồng | Mainboard: B760M Gaming | RAM: 32GB DDR4 3200MHz | VGA: NVIDIA GeForce RTX 4060 Ti 8GB GDDR6 | SSD: 1TB PCIe NVMe M.2 | Nguồn: 650W 80 Plus | Vỏ case: ARGB Prism',
 N'Dàn máy chiến game hiện đại với hệ thống quạt LED RGB đa sắc, cân mượt mọi game Esports và làm đồ họa Photoshop, Premiere.',
 2, 1, 26, N'Đang kinh doanh'),

(N'PCGM0210', N'PC Gaming PCM Pink Cute Edition (Intel Core i5-12400F | RTX 3060 12GB | 16GB RAM | Vỏ Case Hồng Nữ Tính)',
 3, N'PCM', 19500000, 16990000, 15, 36, N'./anh pc/pc10.jpg',
 N'CPU: Intel Core i5-12400F (6 nhân 12 luồng, Turbo 4.4GHz) | RAM: 16GB (2x8GB) DDR4 3200MHz | VGA: RTX 3060 12GB GDDR6 White/Pink | SSD: 512GB NVMe M.2 | Nguồn: 600W 80 Plus | Vỏ case: Hồng pastel kính cường lực kèm 4 fan ARGB',
 N'Phiên bản PC tone màu hồng ngọt ngào dành riêng cho các nữ streamer và game thủ, hiệu năng mạnh mẽ cân tốt cả game lẫn công việc.',
 2, 0, 33, N'Đang kinh doanh'),

(N'PRCA0290', N'Máy In Laser Trắng Đen Đơn Năng Canon LBP2900 (Độ Phân Giải 2400x600 dpi | Khay Giấy 150 Tờ | Siêu Bền)',
 7, N'Canon', 4490000, 3990000, 40, 12, N'./anh pc/printer_canon.jpg',
 N'Loại máy in: Laser đen trắng đơn năng | Khổ giấy: A4, Letter | Tốc độ in: 12 trang/phút | Độ phân giải: 2400 x 600 dpi | Hộp mực: Canon 303 ~2000 trang | Cổng kết nối: USB 2.0',
 N'Mẫu máy in quốc dân huyền thoại của Canon nổi tiếng về độ bền nồi đồng cối đá, mực in rẻ và dễ thay thế, chi phí sử dụng cực thấp.',
 1, 0, 88, N'Đang kinh doanh'),

(N'PRHP0141', N'Máy In Laser Đa Năng HP LaserJet MFP M141w (In, Scan, Copy | Kết Nối Không Dây Wi-Fi | In Từ Điện Thoại)',
 7, N'HP', 3990000, 3390000, 30, 12, N'./anh pc/printer_hp.jpg',
 N'Chức năng: In, Sao chép (Copy), Quét (Scan) đa năng | Tốc độ in: 20 trang/phút | Công nghệ in: HP Auto-On/Auto-Off | Kết nối: Wi-Fi 802.11b/g/n, USB 2.0 | In di động: HP Smart App, Apple AirPrint | Khay: 150 tờ',
 N'Thiết kế nhỏ gọn bậc nhất trong dòng máy in đa năng, dễ dàng in ấn tài liệu trực tiếp từ điện thoại thông minh qua mạng Wi-Fi.',
 1, 0, 52, N'Đang kinh doanh'),

(N'PSCR0750', N'Nguồn Máy Tính Corsair RM750e 750W (80 Plus Gold | Chuẩn ATX 3.0 & PCIe 5.0 | Dây Rời Full Modular)',
 6, N'Corsair', 3190000, 2690000, 35, 84, N'./anh pc/psu_corsair.jpg',
 N'Công suất thực: 750W liên tục | Hiệu suất: 80 PLUS Gold | Chuẩn tương thích: ATX 3.0 và PCIe 5.0 (kèm cáp 12VHPWR cho RTX 40 series) | Quạt: 120mm Zero RPM im lặng | Dây cáp: Full Modular tháo rời 100%',
 N'Nguồn cao cấp chuẩn ATX 3.0 thế hệ mới của Corsair, tụ điện Nhật Bản chịu nhiệt 105°C và chính sách bảo hành chính hãng lên đến 7 năm.',
 2, 1, 40, N'Đang kinh doanh'),

(N'RAMC032G', N'RAM Corsair Vengeance RGB 32GB (2x16GB) DDR5 6000MHz White (C16 | Intel XMP 3.0 & AMD EXPO)',
 6, N'Corsair', 3590000, 2990000, 45, 36, N'./anh pc/ram_corsair.jpg',
 N'Dung lượng: 32GB Kit (2 thanh 16GB) | Chuẩn: DDR5 Bus 6000MHz | Timing: CL36-44-44-96 | Đèn LED: 10 vùng LED RGB động tùy biến iCUE | Tản nhiệt: Nhôm nguyên khối màu trắng tuyết',
 N'Bộ kit RAM DDR5 cao cấp tông màu trắng sang chảnh, xung nhịp 6000MHz cực cao mở ra băng thông dữ liệu tối đa cho gaming và sáng tạo nội dung.',
 2, 1, 58, N'Đang kinh doanh'),

(N'SSDS0990', N'Ổ Cứng SSD Samsung 990 Pro 1TB M.2 PCIe Gen 4.0 x4 NVMe (Tốc Độ Đọc 7450 MB/s, Ghi 6900 MB/s)',
 6, N'Samsung', 3290000, 2790000, 60, 60, N'./anh pc/ssd_samsung.jpg',
 N'Chuẩn giao tiếp: PCIe Gen 4.0 x4, NVMe 2.0 | Form Factor: M.2 2280 | Dung lượng: 1TB | Đọc tuần tự: Lên tới 7,450 MB/s | Ghi tuần tự: Lên tới 6,900 MB/s | Độ bền: 600 TBW | Bộ điều khiển: Samsung Pascal',
 N'Ổ cứng SSD NVMe nhanh nhất thế giới chuẩn PCIe 4.0 của Samsung, tối ưu hóa cho game thủ hạng nặng, dựng phim 4K/8K và thiết bị PS5.',
 2, 1, 94, N'Đang kinh doanh'),

(N'WATP0094', N'Đồng Hồ Thông Minh Apple Watch Series 9 GPS 45mm (Viền Nhôm Dây Cao Su Sport Band | Chống Nước 50m)',
 14, N'Apple', 11290000, 9890000, 20, 12, N'./anh pc/watch_apple.jpg',
 N'Kích thước mặt: 45mm | Màn hình: LTPO OLED Always-On 2000 nits | Chip: Apple S9 SiP lõi kép | Tính năng: Chạm hai lần (Double Tap) | Cảm biến: Điện tâm đồ ECG, SpO2, theo dõi giấc ngủ, đo nhiệt độ cơ thể',
 N'Thế hệ Apple Watch thông minh nhất với chip S9 siêu nhạy, màn hình siêu sáng ngoài trời nắng và trợ thủ theo dõi sức khỏe toàn diện mỗi ngày.',
 3, 1, 37, N'Đang kinh doanh'),

(N'WATR0265', N'Đồng Hồ Thể Thao Thông Minh Garmin Forerunner 265 (Màn Hình AMOLED Cảm Ứng | GPS Đa Băng Tần | Pin 13 Ngày)',
 14, N'Garmin', 12190000, 10990000, 18, 12, N'./anh pc/watch_garmin.jpg',
 N'Màn hình: AMOLED 1.3 inch cảm ứng kính Gorilla Glass 3 | Định vị: Đa băng tần GNSS với công nghệ SatIQ | Pin: Lên đến 13 ngày | Tính năng: Báo cáo buổi sáng Morning Report, Trạng thái luyện tập Training Readiness, VO2 Max',
 N'Người bạn đồng hành số 1 cho người chạy bộ và ba môn phối hợp (Triathlon), tích hợp kho nhạc và kế hoạch tập luyện cá nhân hóa theo từng ngày.',
 2, 0, 24, N'Đang kinh doanh');

-- ============================================================================
-- KHUYẾN MÃI & MÃ GIẢM GIÁ (UC13, UC16)
-- ============================================================================
INSERT INTO dbo.KHUYENMAI (
    TEN_KHUYEN_MAI, MA_GIAM_GIA, LOAI_GIAM_GIA, MUC_GIAM_GIA, GIA_TRI_DON_TOI_THIEU, MUC_GIAM_TOI_DA,
    GIOI_HAN_SU_DUNG, SO_LUOT_DA_DUNG, NGAY_BAT_DAU, NGAY_KET_THUC, MO_TA, DANG_HOAT_DONG
)
VALUES
(N'Giảm 500.000đ cho đơn từ 10 triệu', N'PCM500K', N'AMOUNT', 500000, 10000000, 500000,
 100, 12, '2025-01-01', '2027-12-31', N'Giảm trực tiếp 500.000đ cho các đơn hàng Laptop, PC từ 10.000.000đ', 1),
(N'Ưu đãi 5% tối đa 1.500.000đ', N'GIAM5', N'PERCENT', 5, 5000000, 1500000,
 200, 25, '2025-01-01', '2027-12-31', N'Giảm 5% (tối đa 1.500.000đ) cho đơn hàng từ 5.000.000đ', 1),
(N'Tân thủ giảm 200.000đ mọi đơn hàng', N'NEWUSER', N'AMOUNT', 200000, 1000000, 200000,
 500, 40, '2025-01-01', '2027-12-31', N'Chào mừng khách hàng mới giảm ngay 200.000đ cho đơn từ 1.000.000đ', 1),
(N'Khuyến mãi Hè đã hết hạn (Test ngoại lệ)', N'HETHAN', N'PERCENT', 10, 2000000, 1000000,
 50, 10, '2024-01-01', '2024-06-30', N'Mã đã hết hạn để kiểm thử luồng ngoại lệ UC16', 1);

-- ============================================================================
-- ĐƠN HÀNG MẪU (Để kiểm thử UC08, UC11 và Thống kê doanh thu UC14)
-- ============================================================================
INSERT INTO dbo.DONHANG (
    MA_DON_HANG, ID_TAIKHOAN, TEN_NGUOI_NHAN, DIEN_THOAI_NGUOI_NHAN, DIA_CHI_GIAO_HANG, GHI_CHU,
    PHUONG_THUC_THANH_TOAN, TAM_TINH, MA_GIAM_GIA, SO_TIEN_GIAM, TONG_TIEN, TRANG_THAI_DON_HANG, NGAY_TAO, NGAY_CAP_NHAT
)
VALUES
(N'DH20261101', 4, N'Lê Hoàng Khách Hàng', N'0987654321', N'Số 12 Cầu Giấy, Phường Quan Hoa, Cầu Giấy, Hà Nội', N'Giao giờ hành chính giúp mình',
 N'COD - Thanh toán khi nhận hàng', 31990000, N'PCM500K', 500000, 31490000, N'Đã giao', DATEADD(DAY, -5, GETDATE()), DATEADD(DAY, -3, GETDATE())),

(N'DH20261102', 5, N'Phạm Minh Anh', N'0905112233', N'45 Nguyễn Thị Minh Khai, Quận 1, TP.HCM', N'Gọi trước khi giao 30 phút',
 N'COD - Thanh toán khi nhận hàng', 25399000, N'PCM500K', 500000, 24899000, N'Đã giao', DATEADD(DAY, -2, GETDATE()), DATEADD(DAY, -1, GETDATE())),

(N'DH20261103', 4, N'Lê Hoàng Khách Hàng', N'0987654321', N'Số 12 Cầu Giấy, Phường Quan Hoa, Cầu Giấy, Hà Nội', N'Lắp sẵn driver card màn hình',
 N'COD - Thanh toán khi nhận hàng', 15688000, N'NEWUSER', 200000, 15488000, N'Đang giao', DATEADD(DAY, -1, GETDATE()), GETDATE()),

(N'DH20261104', 4, N'Lê Hoàng Khách Hàng', N'0987654321', N'Số 12 Cầu Giấy, Phường Quan Hoa, Cầu Giấy, Hà Nội', N'Đơn mới đặt chờ nhân viên xác nhận',
 N'COD - Thanh toán khi nhận hàng', 12990000, NULL, 0, 12990000, N'Chờ xác nhận', GETDATE(), GETDATE());

INSERT INTO dbo.CHITIETDONHANG (ID_DONHANG, ID_SANPHAM, MA_SAN_PHAM, TEN_SAN_PHAM, DUONG_DAN_ANH, DON_GIA, SO_LUONG, THANH_TIEN)
VALUES
(1, 1, N'NBGI0099', N'Laptop Gigabyte AORUS 16X 9KG-43VNC54SH (Intel Core i7-13650HX | RTX 4060 | 16 inch WQXGA | 16GB | 1TB | Win 11 | Xám)', N'./anh pc/lap1.jpg', 31990000, 1, 31990000),
(2, 8, N'PCAPT0199', N'PC ULTRA GAMING AI - PCAP TITAN (Intel Core i5-12400F | RTX 4060 8GB | 16GB RAM | 500GB NVMe SSD | PSU 650W)', N'./anh pc/pc8.jpg', 25399000, 1, 25399000),
(3, 16, N'VGGI0324', N'VGA Gigabyte GeForce RTX 3060 WINDFORCE OC 12GB (GDDR6 | 192-bit | Dual Fan)', N'./anh pc/vga.jpg', 7999000, 1, 7999000),
(3, 20, N'MOSS0148', N'Màn Hình Đồ Họa SAMSUNG ViewFinity S8 LS27B800 (27 inch | 4K UHD | IPS | 98% DCI-P3 | USB-C 90W)', N'./anh pc/monitor_ss.jpg', 7689000, 1, 7689000),
(4, 6, N'NBAC0403', N'Laptop Acer Aspire 5 A514-56P-55K5 NX.KHRSV.003 (Core i5-1335U | 16GB LPDDR5 | 512GB SSD | 14 inch WUXGA IPS | Win 11)', N'./anh pc/lap_acer.jpg', 12990000, 1, 12990000);

INSERT INTO dbo.LICHSUTRANGTHAIDONHANG (ID_DONHANG, TRANG_THAI, GHI_CHU, NGUOI_CAP_NHAT, NGAY_CAP_NHAT)
VALUES
(1, N'Chờ xác nhận', N'Khách hàng tạo đơn hàng trực tuyến', N'khachhang', DATEADD(DAY, -5, GETDATE())),
(1, N'Đang giao', N'Nhân viên đã xác nhận và bàn giao vận chuyển', N'staff', DATEADD(DAY, -4, GETDATE())),
(1, N'Đã giao', N'Giao hàng thành công và thu COD đủ', N'staff', DATEADD(DAY, -3, GETDATE())),
(2, N'Chờ xác nhận', N'Khách hàng tạo đơn hàng trực tuyến', N'minhanh', DATEADD(DAY, -2, GETDATE())),
(2, N'Đã giao', N'Khách nhận máy tại TP.HCM và thanh toán COD', N'staff', DATEADD(DAY, -1, GETDATE())),
(3, N'Chờ xác nhận', N'Khách hàng tạo đơn hàng trực tuyến', N'khachhang', DATEADD(DAY, -1, GETDATE())),
(3, N'Đang giao', N'Đã đóng gói VGA và Màn hình, đang giao', N'staff', GETDATE()),
(4, N'Chờ xác nhận', N'Khách hàng tạo đơn hàng trực tuyến', N'khachhang', GETDATE());

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
END;
GO
