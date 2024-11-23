@isTest
public class TestCalculMontant {
    @isTest
    static void testNetAmountCalculation() {
        // Créer un compte pour le test
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Créer un produit pour le test
        Product2 testProduct = new Product2(Name = 'Test Product', IsActive = true);
        insert testProduct;

        // Créer une entrée de catalogue de prix pour le test
        PricebookEntry testPricebookEntry = new PricebookEntry(
            Product2Id = testProduct.Id,
            Pricebook2Id = Test.getStandardPricebookId(),
            UnitPrice = 100.0,
            IsActive = true
        );
        insert testPricebookEntry;

        // Créer un enregistrement de commande pour le test
        Order testOrder = new Order(
            Name = 'Test Order',
            EffectiveDate = Date.today(),
            Status = 'Ordered',
            AccountId = testAccount.Id,
            Pricebook2Id = Test.getStandardPricebookId()
        );

        // Insérer l'enregistrement de commande
        insert testOrder;

        // Créer un enregistrement de ligne de commande pour le test
        OrderItem testOrderItem = new OrderItem(
            OrderId = testOrder.Id,
            Quantity = 1,
            UnitPrice = 100.0,
            PricebookEntryId = testPricebookEntry.Id
        );

        // Insérer l'enregistrement de ligne de commande
        insert testOrderItem;

        // Mettre à jour l'enregistrement de commande pour déclencher le trigger
        testOrder.ShipmentCost__c = 20.0;
        update testOrder;

        // Requêter l'enregistrement de commande pour vérifier le calcul
        Order updatedOrder = [SELECT Id, TotalAmount, ShipmentCost__c, NetAmount__c FROM Order WHERE Id = :testOrder.Id];

        // Vérifier que le champ NetAmount__c est correctement calculé
        System.assertEquals(80.0, updatedOrder.NetAmount__c, 'NetAmount__c should be 80.0');
    }

    @isTest
static void testMultipleOrders() {
    // Créer un compte pour le test
    Account testAccount = new Account(Name = 'Test Account');
    insert testAccount;

    // Créer un produit pour le test
    Product2 testProduct = new Product2(Name = 'Test Product', IsActive = true);
    insert testProduct;

    // Créer une entrée de catalogue de prix pour le test
    PricebookEntry testPricebookEntry = new PricebookEntry(
        Product2Id = testProduct.Id,
        Pricebook2Id = Test.getStandardPricebookId(),
        UnitPrice = 100.0,
        IsActive = true
    );
    insert testPricebookEntry;

    // Créer plusieurs enregistrements de commande pour le test
    List<Order> testOrders = new List<Order>{
        new Order(Name = 'Test Order 1', EffectiveDate = Date.today(), Status = 'Ordered', AccountId = testAccount.Id, Pricebook2Id = Test.getStandardPricebookId()),
        new Order(Name = 'Test Order 2', EffectiveDate = Date.today(), Status = 'Ordered', AccountId = testAccount.Id, Pricebook2Id = Test.getStandardPricebookId()),
        new Order(Name = 'Test Order 3', EffectiveDate = Date.today(), Status = 'Ordered', AccountId = testAccount.Id, Pricebook2Id = Test.getStandardPricebookId())
    };

    // Insérer les enregistrements de commande
    insert testOrders;

    // Créer des enregistrements de ligne de commande pour le test
    List<OrderItem> testOrderItems = new List<OrderItem>{
        new OrderItem(OrderId = testOrders[0].Id, Quantity = 1, UnitPrice = 100.0, PricebookEntryId = testPricebookEntry.Id),
        new OrderItem(OrderId = testOrders[1].Id, Quantity = 1, UnitPrice = 200.0, PricebookEntryId = testPricebookEntry.Id),
        new OrderItem(OrderId = testOrders[2].Id, Quantity = 1, UnitPrice = 300.0, PricebookEntryId = testPricebookEntry.Id)
    };

    // Insérer les enregistrements de ligne de commande
    insert testOrderItems;

    // Mettre à jour les enregistrements de commande pour déclencher le trigger
    testOrders[0].ShipmentCost__c = 20.0;
    testOrders[1].ShipmentCost__c = 30.0;
    testOrders[2].ShipmentCost__c = 40.0;
    update testOrders;

    // Requêter les enregistrements de commande pour vérifier le calcul
    List<Order> updatedOrders = [SELECT Id, TotalAmount, ShipmentCost__c, NetAmount__c FROM Order WHERE Id IN :testOrders];

    // Vérifier les valeurs intermédiaires
    System.assertEquals(100.0, updatedOrders[0].TotalAmount, 'TotalAmount for Order 1 should be 100.0');
    System.assertEquals(200.0, updatedOrders[1].TotalAmount, 'TotalAmount for Order 2 should be 200.0');
    System.assertEquals(300.0, updatedOrders[2].TotalAmount, 'TotalAmount for Order 3 should be 300.0');

    System.assertEquals(20.0, updatedOrders[0].ShipmentCost__c, 'ShipmentCost__c for Order 1 should be 20.0');
    System.assertEquals(30.0, updatedOrders[1].ShipmentCost__c, 'ShipmentCost__c for Order 2 should be 30.0');
    System.assertEquals(40.0, updatedOrders[2].ShipmentCost__c, 'ShipmentCost__c for Order 3 should be 40.0');

    // Vérifier que le champ NetAmount__c est correctement calculé pour chaque commande
    System.assertEquals(80.0, updatedOrders[0].NetAmount__c, 'NetAmount__c for Order 1 should be 80.0');
    System.assertEquals(170.0, updatedOrders[1].NetAmount__c, 'NetAmount__c for Order 2 should be 170.0');
    System.assertEquals(260.0, updatedOrders[2].NetAmount__c, 'NetAmount__c for Order 3 should be 260.0');
}
    
}
