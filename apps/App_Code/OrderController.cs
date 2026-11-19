using System;
using System.Collections.Generic;

namespace PCMComputer
{
    /// <summary>
    /// Lớp điều khiển đặt hàng (:OrderController) theo đúng Biểu đồ tuần tự (Mục 3.7 - UC07)
    /// </summary>
    public class OrderController
    {
        private readonly OrderService _orderService;

        public OrderController()
        {
            _orderService = new OrderService();
        }

        // Thông điệp 2: requestCheckout(userId, cart)
        public UserInfo requestCheckout(int userId, List<CartItem> cart)
        {
            return _orderService.getUserDefaultInfo(userId);
        }

        // Thông điệp 9: submitOrder(orderDTO)
        public OrderResult submitOrder(OrderDTO orderDTO)
        {
            return _orderService.processCreateOrder(orderDTO);
        }
    }
}
