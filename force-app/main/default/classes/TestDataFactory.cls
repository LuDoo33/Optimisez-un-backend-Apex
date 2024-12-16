public class TestDataFactory {

    // Méthode pour créer plusieurs comptes
    // Étape 1 : Création de comptes
    // Cette méthode crée une liste de comptes en fonction du nombre spécifié et ajoute un préfixe au nom de chaque compte.
    // Les comptes sont ensuite insérés dans la base de données pour les tests.
    public static List<Account> createAccounts(Integer numberOfAccounts, String namePrefix) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < numberOfAccounts; i++) {
            Account acc = new Account(Name = namePrefix + ' ' + i);
            accounts.add(acc);
        }
        insert accounts;  // Insertion des comptes dans la base de données
        return accounts;  // Retourne la liste des comptes créés
    }

    // Méthode pour créer plusieurs produits
    // Étape 2 : Création de produits
    // Cette méthode crée une liste de produits avec un préfixe ajouté au nom et une famille spécifiée.
    // Les produits sont ensuite insérés dans la base de données pour les tests.
    public static List<Product2> createProducts(Integer numberOfProducts, String namePrefix, String family) {
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < numberOfProducts; i++) {
            Product2 prod = new Product2(Name = namePrefix + ' ' + i, Family = family, IsActive = true);
            products.add(prod);
        }
        insert products;  // Insertion des produits dans la base de données
        return products;  // Retourne la liste des produits créés
    }

    // Méthode pour créer plusieurs entrées dans le Pricebook
    // Étape 3 : Création des entrées dans le Pricebook
    // Cette méthode crée des entrées dans le Pricebook pour les produits donnés avec un prix unitaire et un état actif spécifié.
    // Les entrées dans le Pricebook sont ensuite insérées dans la base de données.
    public static List<PricebookEntry> createPricebookEntries(List<Product2> products, Decimal unitPrice, Boolean isActive) {
        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        for (Product2 prod : products) {
            PricebookEntry pbe = new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(),  // Utilisation du Pricebook standard
                Product2Id = prod.Id,
                UnitPrice = unitPrice,
                IsActive = isActive
            );
            pricebookEntries.add(pbe);
        }
        insert pricebookEntries;  // Insertion des entrées dans le Pricebook
        return pricebookEntries;  // Retourne la liste des entrées dans le Pricebook créées
    }

    // Méthode pour créer plusieurs commandes
    // Étape 4 : Création de commandes
    // Cette méthode crée une liste de commandes associées à des comptes donnés avec un Pricebook et un statut spécifié.
    // Les commandes sont ensuite insérées dans la base de données.
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
        insert orders;  // Insertion des commandes dans la base de données
        return orders;  // Retourne la liste des commandes créées
    }

    // Méthode pour créer plusieurs éléments de commande
    // Étape 5 : Création des éléments de commande
    // Cette méthode crée des éléments de commande pour chaque commande créée à l'étape précédente,
    // en associant chaque élément de commande à une entrée du Pricebook et en spécifiant la quantité et le prix unitaire.
    // Les éléments de commande sont ensuite insérés dans la base de données.
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
        insert orderItems;  // Insertion des éléments de commande dans la base de données
        return orderItems;  // Retourne la liste des éléments de commande créés
    }
}
