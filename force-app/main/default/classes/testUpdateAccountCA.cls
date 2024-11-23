@isTest
private class TestUpdateAccountCA {

    // Test avec 1 commande
    @isTest static void test() {
        // Créer un compte
        Account acc1 = new Account(Name = 'Test Account 1');
        insert acc1;

        // Créer un produit
        Product2 pd1 = new Product2(Name = 'Chemise Verte longue XYX', Family = 'Chemise');
        insert pd1;

        // Récupérer l'ID du Pricebook standard
        Id pricebookId = Test.getStandardPricebookId();

        // Créer une entrée de catalogue de prix
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = pd1.Id,
            UnitPrice = 1020,
            IsActive = true
        );
        insert pbe;

        // Créer une commande
        Order o1 = new Order(
            AccountId = acc1.Id,
            Pricebook2Id = pricebookId,
            EffectiveDate = Date.today(),
            Status = 'Ordered'
        );
        insert o1;

        // Créer des éléments de commande
        OrderItem oi1 = new OrderItem(OrderId = o1.Id, PricebookEntryId = pbe.Id, Quantity = 10, UnitPrice = 150);
        insert oi1;
        OrderItem oi2 = new OrderItem(OrderId = o1.Id, PricebookEntryId = pbe.Id, Quantity = 20, UnitPrice = 1000);
        insert oi2;

        // Vérifier que le chiffre d'affaires a été mis à jour (facultatif pour ce test)
        Account updatedAccount = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :acc1.Id];
        System.assertNotEquals(null, updatedAccount.Chiffre_d_affaire__c, 'Le chiffre d\'affaires doit être mis à jour.');
    }

    @isTest static void testWith101Orders() {
        // Créer un compte
        Account acc2 = new Account(Name = 'Test Account 2');
        insert acc2;

        // Créer un produit
        Product2 pd2 = new Product2(Name = 'Pantalon Bleu 3XL', Family = 'Pantalon');
        insert pd2;

        // Récupérer l'ID du Pricebook standard
        Id pricebookId = Test.getStandardPricebookId();

        // Créer une entrée de catalogue de prix
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = pd2.Id,
            UnitPrice = 500,
            IsActive = true
        );
        insert pbe;

        // Créer 100 commandes initiales
        List<Order> orders = new List<Order>();
        for (Integer i = 0; i < 100; i++) {
            Order o = new Order(
                AccountId = acc2.Id,
                Pricebook2Id = pricebookId,
                EffectiveDate = Date.today(),
                Status = 'Ordered'
            );
            orders.add(o);
        }
        insert orders;

        // Créer des éléments de commande pour chaque commande initiale
        List<OrderItem> orderItems = new List<OrderItem>();
        for (Order o : orders) {
            OrderItem oi = new OrderItem(
                OrderId = o.Id,
                PricebookEntryId = pbe.Id,
                Quantity = 5,
                UnitPrice = 200
            );
            orderItems.add(oi);
        }
        insert orderItems;

        // === Début du scénario de mise à jour ===

        // Créer la 101ème commande avec un statut différent
        Order newOrder = new Order(
            AccountId = acc2.Id,
            Pricebook2Id = pricebookId,
            EffectiveDate = Date.today(),
            Status = 'Draft' // Statut initial différent
        );
        insert newOrder;

        // Créer un élément de commande pour la nouvelle commande
        OrderItem newOrderItem = new OrderItem(
            OrderId = newOrder.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 10, // Quantité différente pour le test
            UnitPrice = 300  // Prix unitaire différent
        );
        insert newOrderItem;

        // Récupérer le chiffre d'affaires actuel du compte
        Account accountBeforeUpdate = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :acc2.Id];

        // Mettre à jour le statut de la nouvelle commande pour déclencher le trigger
        newOrder.Status = 'Ordered';
        update newOrder;

        // === Vérifications ===

        // Vérifier que le chiffre d'affaires a été correctement mis à jour
        Account accountAfterUpdate = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :acc2.Id];
        Decimal expectedChiffreAffaire = accountBeforeUpdate.Chiffre_d_affaire__c + (10 * 300);
        System.debug('Expected Chiffre d\'affaire: ' + expectedChiffreAffaire);
        System.debug('Actual Chiffre d\'affaire: ' + accountAfterUpdate.Chiffre_d_affaire__c);
        System.assertEquals(expectedChiffreAffaire, accountAfterUpdate.Chiffre_d_affaire__c,
                            'Le chiffre d\'affaires doit être correctement mis à jour après modification.');

        // Vérifier le nombre total de commandes
        acc2 = [SELECT Id, (SELECT Id FROM Orders) FROM Account WHERE Id = :acc2.Id];
        System.assertEquals(101, acc2.Orders.size(), 'Le compte doit avoir 101 commandes.');
    }
}
