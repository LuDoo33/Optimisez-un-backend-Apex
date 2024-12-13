public class UpdateAllAccounts {

    // Calcul du revenu total pour un compte donné
    public static Decimal calculateAccountRevenue(List<OrderItem> orderItems) {
        Decimal totalRevenue = 0;
        for (OrderItem orderItem : orderItems) {
            if (orderItem.UnitPrice != null && orderItem.Quantity != null) {
                totalRevenue += orderItem.UnitPrice * orderItem.Quantity;
            }
        }
        return totalRevenue;
    }
}
