public class TestDataFactory {

    // Méthode pour créer un compte
    public static Account createAccount(String name) {
        Account acc = new Account(Name = name);
        insert acc;
        return acc;
    }

    // Méthode pour créer un produit
    public static Product2 createProduct(String name, String family) {
        Product2 prod = new Product2(Name = name, Family = family, IsActive = true);
        insert prod;
        return prod;
    }

    // Méthode pour créer une entrée dans le Pricebook, avec des Ids en paramètre
    public static PricebookEntry createPricebookEntry(Id productId, Decimal unitPrice, Boolean isActive) {
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = productId,
            UnitPrice = unitPrice,
            IsActive = isActive
        );
        insert pbe;
        return pbe;
    }

    // Méthode pour créer une commande, acceptant des Ids pour le compte et le pricebook
    public static Order createOrder(Id accountId, Id pricebookId, String status) {
        Order ord = new Order(
            AccountId = accountId,
            Pricebook2Id = pricebookId,
            EffectiveDate = Date.today(),
            Status = status
        );
        insert ord;
        return ord;
    }

    // Méthode pour créer un élément de commande, avec des Ids pour la commande et l'entrée du pricebook
    public static OrderItem createOrderItem(Id orderId, Id pricebookEntryId, Integer quantity, Decimal unitPrice) {
        OrderItem oi = new OrderItem(
            OrderId = orderId,
            PricebookEntryId = pricebookEntryId,
            Quantity = quantity,
            UnitPrice = unitPrice
        );
        insert oi;
        return oi;
    }
}
