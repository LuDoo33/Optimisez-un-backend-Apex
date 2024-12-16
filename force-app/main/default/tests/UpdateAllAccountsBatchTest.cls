@isTest
private class UpdateAllAccountsBatchTest {

    @isTest
    static void testOrderItemsNull() {
        // Créer un compte de test
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Créer une map avec des éléments de commande null
        Map<Id, List<OrderItem>> orderItemsByAccountId = new Map<Id, List<OrderItem>>();
        orderItemsByAccountId.put(testAccount.Id, null);

        // Exécuter le batch
        Test.startTest();
        UpdateAllAccountsBatch batch = new UpdateAllAccountsBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        // Vérification
        Account updatedAccount = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(null, updatedAccount.Chiffre_d_affaire__c, 'Le chiffre d\'affaires ne doit pas être mis à jour.');
    }

    @isTest
    static void testOrderItemsEmpty() {
        // Créer un compte de test
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Créer une map avec des éléments de commande vide
        Map<Id, List<OrderItem>> orderItemsByAccountId = new Map<Id, List<OrderItem>>();
        orderItemsByAccountId.put(testAccount.Id, new List<OrderItem>());

        // Exécuter le batch
        Test.startTest();
        UpdateAllAccountsBatch batch = new UpdateAllAccountsBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        // Vérification
        Account updatedAccount = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(null, updatedAccount.Chiffre_d_affaire__c, 'Le chiffre d\'affaires ne doit pas être mis à jour.');
    }

    @isTest
    static void testNewRevenueDifferent() {
        // Créer un compte de test
        Account testAccount = new Account(Name = 'Test Account', Chiffre_d_affaire__c = 100.0);
        insert testAccount;

        // Créer un produit de test
        Product2 testProduct = new Product2(Name = 'Test Product', Family = 'FamilyA');
        insert testProduct;

        // Créer une entrée de Pricebook pour ce produit
        PricebookEntry testPricebookEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = testProduct.Id,
            UnitPrice = 200.0,
            IsActive = true
        );
        insert testPricebookEntry;

        // Créer une commande de test
        Order testOrder = new Order(
            AccountId = testAccount.Id,
            Pricebook2Id = Test.getStandardPricebookId(),
            Status = 'Draft',
            EffectiveDate = Date.today()
        );
        insert testOrder;

        // Créer un élément de commande de test
        OrderItem testOrderItem = new OrderItem(
            OrderId = testOrder.Id,
            PricebookEntryId = testPricebookEntry.Id,
            Quantity = 1,
            UnitPrice = 200.0
        );
        insert testOrderItem;

        // Mettre à jour le statut de la commande pour déclencher le batch
        testOrder.Status = 'Ordered';
        update testOrder;

        // Exécuter le batch
        Test.startTest();
        UpdateAllAccountsBatch batch = new UpdateAllAccountsBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        // Vérification
        Account updatedAccount = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(200.0, updatedAccount.Chiffre_d_affaire__c, 'Le chiffre d\'affaires doit être mis à jour.');
    }

    @isTest
    static void testNewRevenueSame() {
        // Créer un compte de test
        Account testAccount = new Account(Name = 'Test Account', Chiffre_d_affaire__c = 200.0);
        insert testAccount;

        // Créer un produit de test
        Product2 testProduct = new Product2(Name = 'Test Product', Family = 'FamilyA');
        insert testProduct;

        // Créer une entrée de Pricebook pour ce produit
        PricebookEntry testPricebookEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = testProduct.Id,
            UnitPrice = 200.0,
            IsActive = true
        );
        insert testPricebookEntry;

        // Créer une commande de test
        Order testOrder = new Order(
            AccountId = testAccount.Id,
            Pricebook2Id = Test.getStandardPricebookId(),
            Status = 'Draft',
            EffectiveDate = Date.today()
        );
        insert testOrder;

        // Créer un élément de commande de test
        OrderItem testOrderItem = new OrderItem(
            OrderId = testOrder.Id,
            PricebookEntryId = testPricebookEntry.Id,
            Quantity = 1,
            UnitPrice = 200.0
        );
        insert testOrderItem;

        // Mettre à jour le statut de la commande pour déclencher le batch
        testOrder.Status = 'Ordered';
        update testOrder;

        // Exécuter le batch
        Test.startTest();
        UpdateAllAccountsBatch batch = new UpdateAllAccountsBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        // Vérification
        Account updatedAccount = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(200.0, updatedAccount.Chiffre_d_affaire__c, 'Le chiffre d\'affaires ne doit pas être mis à jour.');
    }
    @isTest
    static void testExecuteBatch() {
        // Créer un compte de test
        Account testAccount = new Account(Name = 'Test Account', Chiffre_d_affaire__c = 100.0);
        insert testAccount;

        // Créer un produit de test
        Product2 testProduct = new Product2(Name = 'Test Product', Family = 'FamilyA');
        insert testProduct;

        // Créer une entrée de Pricebook pour ce produit
        PricebookEntry testPricebookEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = testProduct.Id,
            UnitPrice = 200.0,
            IsActive = true
        );
        insert testPricebookEntry;

        // Créer une commande de test
        Order testOrder = new Order(
            AccountId = testAccount.Id,
            Pricebook2Id = Test.getStandardPricebookId(),
            Status = 'Ordered',
            EffectiveDate = Date.today()
        );
        insert testOrder;

        // Créer un élément de commande de test
        OrderItem testOrderItem = new OrderItem(
            OrderId = testOrder.Id,
            PricebookEntryId = testPricebookEntry.Id,
            Quantity = 1,
            UnitPrice = 200.0
        );
        insert testOrderItem;

        // Exécuter le batch
        Test.startTest();
        UpdateAllAccountsBatch batch = new UpdateAllAccountsBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        // Vérification
        Account updatedAccount = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(200.0, updatedAccount.Chiffre_d_affaire__c, 'Le chiffre d\'affaires doit être mis à jour.');
    }

    @isTest
    static void testNoOrderItems() {
        // Créer un compte de test
        Account testAccount = new Account(Name = 'Test Account', Chiffre_d_affaire__c = 100.0);
        insert testAccount;

        // Exécuter le batch
        Test.startTest();
        UpdateAllAccountsBatch batch = new UpdateAllAccountsBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        // Vérification
        Account updatedAccount = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(100.0, updatedAccount.Chiffre_d_affaire__c, 'Le chiffre d\'affaires ne doit pas être mis à jour.');
    }
    @isTest
    static void testUpdateAccountRevenueInBatch() {
        // Créer un compte de test
        Account testAccount = new Account(Name = 'Test Account', Chiffre_d_affaire__c = 100.0);
        insert testAccount;

        // Créer un produit de test
        Product2 testProduct = new Product2(Name = 'Test Product', Family = 'FamilyA');
        insert testProduct;

        // Créer une entrée de Pricebook pour ce produit
        PricebookEntry testPricebookEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = testProduct.Id,
            UnitPrice = 200.0,
            IsActive = true
        );
        insert testPricebookEntry;

        // Créer une commande de test
        Order testOrder = new Order(
            AccountId = testAccount.Id,
            Pricebook2Id = Test.getStandardPricebookId(),
            Status = 'Draft',
            EffectiveDate = Date.today()
        );
        insert testOrder;

        // Créer un élément de commande de test
        OrderItem testOrderItem = new OrderItem(
            OrderId = testOrder.Id,
            PricebookEntryId = testPricebookEntry.Id,
            Quantity = 1,
            UnitPrice = 200.0
        );
        insert testOrderItem;

        // Mettre à jour le statut de la commande pour déclencher le batch
        testOrder.Status = 'Ordered';
        update testOrder;

        // Exécuter le batch
        Test.startTest();
        UpdateAllAccountsBatch batch = new UpdateAllAccountsBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        // Vérification
        Account updatedAccount = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(200.0, updatedAccount.Chiffre_d_affaire__c, 'Le chiffre d\'affaires doit être mis à jour.');
    }
}
