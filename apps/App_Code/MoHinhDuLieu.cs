using System;
using System.Collections.Generic;

namespace PCMComputer
{
    [Serializable]
    public class UserInfo
    {
        public int UserId { get; set; }
        public string Username { get; set; }
        public string PasswordHash { get; set; }
        public string FullName { get; set; }
        public string Email { get; set; }
        public string Phone { get; set; }
        public string Address { get; set; }
        public string Role { get; set; } // Admin, Staff, Customer
        public bool IsLocked { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    [Serializable]
    public class CategoryInfo
    {
        public int CategoryId { get; set; }
        public string CategoryName { get; set; }
        public string Slug { get; set; }
        public string PageUrl { get; set; }
        public string IconPath { get; set; }
        public string Description { get; set; }
        public int DisplayOrder { get; set; }
        public bool IsActive { get; set; }
        public int ProductCount { get; set; }
    }

    [Serializable]
    public class ProductInfo
    {
        public int ProductId { get; set; }
        public string ProductCode { get; set; }
        public string ProductName { get; set; }
        public int CategoryId { get; set; }
        public string CategoryName { get; set; }
        public string Brand { get; set; }
        public decimal OldPrice { get; set; }
        public decimal Price { get; set; }
        public int StockQuantity { get; set; }
        public int WarrantyMonths { get; set; }
        public string ImageUrl { get; set; }
        public string Specifications { get; set; }
        public string Description { get; set; }
        public int PromoCount { get; set; }
        public bool IsDeal { get; set; }
        public int SoldCount { get; set; }
        public string Status { get; set; }
        public DateTime CreatedAt { get; set; }

        public int DiscountPercent
        {
            get
            {
                if (OldPrice > Price && OldPrice > 0)
                {
                    return (int)Math.Round(((OldPrice - Price) / OldPrice) * 100M);
                }
                return 0;
            }
        }
    }

    [Serializable]
    public class CartItem
    {
        public int ProductId { get; set; }
        public string ProductCode { get; set; }
        public string ProductName { get; set; }
        public string ImageUrl { get; set; }
        public decimal UnitPrice { get; set; }
        public int Quantity { get; set; }
        public int StockQuantity { get; set; }

        public decimal LineTotal
        {
            get { return UnitPrice * Quantity; }
        }
    }

    [Serializable]
    public class PromotionInfo
    {
        public int PromotionId { get; set; }
        public string PromotionName { get; set; }
        public string VoucherCode { get; set; }
        public string DiscountType { get; set; } // PERCENT or AMOUNT
        public decimal DiscountValue { get; set; }
        public decimal MinOrderAmount { get; set; }
        public decimal MaxDiscountAmount { get; set; }
        public int UsageLimit { get; set; }
        public int UsedCount { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public string Description { get; set; }
        public bool IsActive { get; set; }

        public int RemainingUses
        {
            get { return UsageLimit - UsedCount > 0 ? UsageLimit - UsedCount : 0; }
        }
    }

    [Serializable]
    public class VoucherCheckResult
    {
        public bool IsValid { get; set; }
        public string Message { get; set; }
        public decimal DiscountAmount { get; set; }
        public PromotionInfo Promotion { get; set; }
    }

    [Serializable]
    public class OrderDTO
    {
        public int UserId { get; set; }
        public string Username { get; set; }
        public string ReceiverName { get; set; }
        public string ReceiverPhone { get; set; }
        public string ShippingAddress { get; set; }
        public string Note { get; set; }
        public string PaymentMethod { get; set; }
        public string VoucherCode { get; set; }
        public List<CartItem> Items { get; set; }

        public OrderDTO()
        {
            Items = new List<CartItem>();
        }
    }

    [Serializable]
    public class OrderResult
    {
        public bool IsSuccess { get; set; }
        public string ResultCode { get; set; } // SUCCESS, OUT_OF_STOCK, INVALID_VOUCHER, INVALID_INPUT, ERROR
        public string Message { get; set; }
        public int OrderId { get; set; }
        public string OrderCode { get; set; }
    }

    [Serializable]
    public class OrderInfo
    {
        public int OrderId { get; set; }
        public string OrderCode { get; set; }
        public int UserId { get; set; }
        public string CustomerUsername { get; set; }
        public string ReceiverName { get; set; }
        public string ReceiverPhone { get; set; }
        public string ShippingAddress { get; set; }
        public string Note { get; set; }
        public string PaymentMethod { get; set; }
        public decimal SubTotal { get; set; }
        public string VoucherCode { get; set; }
        public decimal DiscountAmount { get; set; }
        public decimal TotalAmount { get; set; }
        public string OrderStatus { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public List<OrderDetailInfo> Details { get; set; }
        public List<OrderHistoryInfo> History { get; set; }

        public OrderInfo()
        {
            Details = new List<OrderDetailInfo>();
            History = new List<OrderHistoryInfo>();
        }
    }

    [Serializable]
    public class OrderDetailInfo
    {
        public int OrderDetailId { get; set; }
        public int OrderId { get; set; }
        public int ProductId { get; set; }
        public string ProductCode { get; set; }
        public string ProductName { get; set; }
        public string ImageUrl { get; set; }
        public decimal UnitPrice { get; set; }
        public int Quantity { get; set; }
        public decimal LineTotal { get; set; }
    }

    [Serializable]
    public class OrderHistoryInfo
    {
        public int HistoryId { get; set; }
        public int OrderId { get; set; }
        public string Status { get; set; }
        public string Note { get; set; }
        public string UpdatedBy { get; set; }
        public DateTime UpdatedAt { get; set; }
    }

    [Serializable]
    public class RevenueStats
    {
        public decimal TotalRevenue { get; set; }
        public int TotalOrders { get; set; }
        public int DeliveredOrders { get; set; }
        public int PendingOrders { get; set; }
        public int ShippingOrders { get; set; }
        public int CancelledOrders { get; set; }
        public int LowStockCount { get; set; }
    }

    [Serializable]
    public class DailyRevenueItem
    {
        public string DateLabel { get; set; }
        public decimal Revenue { get; set; }
        public int OrderCount { get; set; }
    }

    [Serializable]
    public class CategoryRevenueItem
    {
        public string CategoryName { get; set; }
        public decimal TotalRevenue { get; set; }
        public int TotalSold { get; set; }
    }

    [Serializable]
    public class OrderStatusItem
    {
        public string StatusName { get; set; }
        public int Count { get; set; }
        public decimal TotalAmount { get; set; }
        public string ColorHex { get; set; }
    }
}
