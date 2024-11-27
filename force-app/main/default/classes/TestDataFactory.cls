public class TestDataFactory {

    // Méthode pour créer plusieurs comptes
    public static List<Account> createAccounts(Integer numberOfAccounts, String namePrefix) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < numberOfAccounts; i++) {
            Account acc = new Account(Name = namePrefix + ' ' + i);
            accounts.add(acc);
        }
        insert accounts;
        return accounts;
    }

    // Méthode pour créer plusieurs produits
    public static List<Product2> createProducts(Integer numberOfProducts, String namePrefix, String family) {
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < numberOfProducts; i++) {
            Product2 prod = new Product2(Name = namePrefix + ' ' + i, Family = family, IsActive = true);
            products.add(prod);
        }
        insert products;
        return products;
    }

    // Méthode pour créer plusieurs entrées dans le Pricebook
    public static List<PricebookEntry> createPricebookEntries(List<Product2> products, Decimal unitPrice, Boolean isActive) {
        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        for (Product2 prod : products) {
            PricebookEntry pbe = new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = prod.Id,
                UnitPrice = unitPrice,
                IsActive = isActive
            );
            pricebookEntries.add(pbe);
        }
        insert pricebookEntries;
        return pricebookEntries;
    }

    // Méthode pour créer plusieurs commandes
    public static List<Order> createOrders(List<Account> accounts, Id pricebookId, String status) {
        List<Order> orders = new List<Order>();
        for (Account acc : accounts) {
            Order ord = new Order(
                AccountId = acc.Id,
                Pricebook2Id = pricebookId,
                EffectiveDate = Date.today(),
                Status = status
            );
            orders.add(ord);
        }
        insert orders;
        return orders;
    }

    // Méthode pour créer plusieurs éléments de commande
    public static List<OrderItem> createOrderItems(List<Order> orders, List<PricebookEntry> pricebookEntries, Integer quantity, Decimal unitPrice) {
        List<OrderItem> orderItems = new List<OrderItem>();
        for (Order ord : orders) {
            for (PricebookEntry pbe : pricebookEntries) {
                OrderItem oi = new OrderItem(
                    OrderId = ord.Id,
                    PricebookEntryId = pbe.Id,
                    Quantity = quantity,
                    UnitPrice = unitPrice
                );
                orderItems.add(oi);
            }
        }
        insert orderItems;
        return orderItems;
    }
}
