@isTest
private class TestUpdateAllAccounts {

    @isTest
    static void test() {
        // Créer un compte
        List<Account> accounts = TestDataFactory.createAccounts(1, 'Test Account 1');
        Account acc1 = accounts[0];

        // Créer un produit
        List<Product2> products = TestDataFactory.createProducts(1, 'Chemise Verte longue XYX', 'Chemise');
        Product2 pd1 = products[0];

        // Créer une entrée de Pricebook
        List<PricebookEntry> pricebookEntries = TestDataFactory.createPricebookEntries(products, 1020.0, true);
        PricebookEntry pbe = pricebookEntries[0];

        // Créer une commande et des éléments de commande
        List<Order> orders = TestDataFactory.createOrders(accounts, Test.getStandardPricebookId(), 'Ordered');
        Order o1 = orders[0];

        TestDataFactory.createOrderItems(orders, pricebookEntries, 10, 150.0);
        TestDataFactory.createOrderItems(orders, pricebookEntries, 20, 1000.0);

        // Exécuter le batch
        Test.startTest();
        UpdateAllAccountsBatch batch = new UpdateAllAccountsBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        // Récupérer l'Account pour vérifier la mise à jour du chiffre d'affaires
        Account updatedAccount = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :acc1.Id];

        // Vérification
        System.assertNotEquals(null, updatedAccount.Chiffre_d_affaire__c, 'Le chiffre d\'affaires doit être mis à jour.');
    }

    @isTest
    static void testWith101Orders() {
        // Créer un compte
        List<Account> accounts = TestDataFactory.createAccounts(1, 'Test Account 2');
        Account acc2 = accounts[0];

        // Créer un produit
        List<Product2> products = TestDataFactory.createProducts(1, 'Pantalon Bleu 3XL', 'Pantalon');
        Product2 pd2 = products[0];

        // Créer une entrée de Pricebook
        List<PricebookEntry> pricebookEntries = TestDataFactory.createPricebookEntries(products, 500.0, true);
        PricebookEntry pbe = pricebookEntries[0];

        // Créer 100 commandes avec EffectiveDate
        List<Order> orders = new List<Order>();
        Date today = Date.today();  // Utiliser la date du jour pour EffectiveDate
        for (Integer i = 0; i < 100; i++) {
            orders.add(new Order(
                AccountId = acc2.Id,
                Pricebook2Id = Test.getStandardPricebookId(),
                Status = 'Ordered',
                EffectiveDate = today  // Assigner EffectiveDate ici
            ));
        }
        insert orders;

        // Créer des éléments de commande pour chaque commande
        List<OrderItem> orderItems = new List<OrderItem>();
        for (Order o : orders) {
            orderItems.add(new OrderItem(
                OrderId = o.Id,
                PricebookEntryId = pbe.Id,
                Quantity = 5,
                UnitPrice = 200
            ));
        }
        insert orderItems;

        // Créer une nouvelle commande avec EffectiveDate
        Order newOrder = new Order(
            AccountId = acc2.Id,
            Pricebook2Id = Test.getStandardPricebookId(),
            Status = 'Draft',
            EffectiveDate = today  // Assigner EffectiveDate ici
        );
        insert newOrder;  // Insertion de la nouvelle commande
        TestDataFactory.createOrderItems(new List<Order>{newOrder}, pricebookEntries, 10, 300.0);  // Ajouter des éléments de commande

        // Récupérer le chiffre d'affaires avant la mise à jour
        Account accountBeforeUpdate = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :acc2.Id];

        // Mettre à jour le statut de la commande
        newOrder.Status = 'Ordered';
        update newOrder;

        // Exécuter le batch
        Test.startTest();
        UpdateAllAccountsBatch batch = new UpdateAllAccountsBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        // Vérifier le chiffre d'affaires après la mise à jour
        Account accountAfterUpdate = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :acc2.Id];
        Decimal expectedChiffreAffaire = accountBeforeUpdate.Chiffre_d_affaire__c + (10 * 300);

        System.assertEquals(expectedChiffreAffaire, accountAfterUpdate.Chiffre_d_affaire__c, 'Le chiffre d\'affaires doit être mis à jour.');

        // Vérification du nombre de commandes
        acc2 = [SELECT Id, (SELECT Id FROM Orders) FROM Account WHERE Id = :acc2.Id];
        System.assertEquals(101, acc2.Orders.size(), 'Le compte doit avoir 101 commandes.');
    }
}
