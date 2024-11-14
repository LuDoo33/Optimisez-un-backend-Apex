@isTest
private class TestUpdateAccountCA {

    // Test avec 1 commande
    @isTest static void test() {
        Account acc1 = new Account(Name = 'Test Account 1');
        insert acc1;

        Product2 pd1 = new Product2(Name = 'Chemise Verte longue XYX', Family = 'Chemise');
        insert pd1;

        // Utilisation de Test.getStandardPricebookId() pour récupérer l'ID du Pricebook standard
        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = pd1.Id,
            UnitPrice = 1020,
            IsActive = true
        );
        insert pbe;

        Order o1 = new Order(
            AccountId = acc1.Id,
            Pricebook2Id = pricebookId, // Affecter le même Pricebook ID à la commande
            EffectiveDate = Date.today(),
            Status = 'Ordered' // Utilisation de "Ordered" ici
        );
        insert o1;

        OrderItem oi1 = new OrderItem(OrderId = o1.Id, PricebookEntryId = pbe.Id, Quantity = 10, UnitPrice = 150);
        insert oi1;
        OrderItem oi2 = new OrderItem(OrderId = o1.Id, PricebookEntryId = pbe.Id, Quantity = 20, UnitPrice = 1000);
        insert oi2;
    }

    // Test avec 101 commandes
    @isTest static void testWith101Orders() {
        Account acc2 = new Account(Name = 'Test Account 2');
        insert acc2;

        Product2 pd2 = new Product2(Name = 'Pantalon Bleu 3XL', Family = 'Pantalon');
        insert pd2;

        // Utilisation de Test.getStandardPricebookId() pour récupérer l'ID du Pricebook standard
        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = pd2.Id,
            UnitPrice = 500,
            IsActive = true
        );
        insert pbe;

        // Créer 101 commandes pour le compte acc2
        List<Order> orders = new List<Order>();
        List<OrderItem> orderItems = new List<OrderItem>();

        for (Integer i = 0; i < 101; i++) {
            Order o = new Order(
                AccountId = acc2.Id,
                Pricebook2Id = pricebookId,
                EffectiveDate = Date.today(),
                Status = 'Ordered'  // Utilisation de "Ordered" ici
            );
            orders.add(o);
        }

        insert orders;

        // Créer des OrderItems pour chaque commande
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

        // Maintenant, on peut effectuer une mise à jour de la commande
        for (Order o : orders) {
            o.Status = 'Ordered'; // Mise à jour avec le même statut "Ordered"
        }
        update orders;

        // Vérifier que la mise à jour du chiffre d'affaires a fonctionné sans erreur
        Account updatedAccount = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :acc2.Id];
        
        // Calcul du chiffre d'affaire attendu
        Decimal expectedChiffreAffaire = 101 * 5 * 200; // 101 commandes, 5 items par commande, prix unitaire 200
        System.assertEquals(expectedChiffreAffaire, updatedAccount.Chiffre_d_affaire__c, 
                            'Le chiffre d\'affaires doit être correctement mis à jour.');
        
        // Vérification du nombre de commandes
        acc2 = [SELECT Id, (SELECT Id FROM Orders) FROM Account WHERE Id = :acc2.Id];
        System.assertEquals(101, acc2.Orders.size(), 'Le compte doit avoir 101 commandes.');
    }
}
