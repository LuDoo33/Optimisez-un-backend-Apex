@isTest
public class TestCalculMontant {

    @isTest
    static void testNetAmountCalculation() {
        // Créer un compte de test
        Account testAccount = TestDataFactory.createAccount('Test Account');
        
        // Créer un produit de test
        Product2 testProduct = TestDataFactory.createProduct('Test Product', null);
        
        // Créer une entrée de Pricebook pour ce produit
        PricebookEntry testPricebookEntry = TestDataFactory.createPricebookEntry(testProduct.Id, 100.0, true);
        
        // Créer une commande pour le compte de test
        Order testOrder = TestDataFactory.createOrder(testAccount.Id, Test.getStandardPricebookId(), 'Ordered');
        
        // Créer un élément de commande pour la commande test
        TestDataFactory.createOrderItem(testOrder.Id, testPricebookEntry.Id, 1, 100.0);

        // Mise à jour de la commande pour déclencher le trigger (ajout des frais de livraison)
        testOrder.ShipmentCost__c = 20.0;
        update testOrder;

        // Récupérer la commande mise à jour
        Order updatedOrder = [SELECT Id, TotalAmount, ShipmentCost__c, NetAmount__c FROM Order WHERE Id = :testOrder.Id];
        
        // Vérification du montant net attendu après les frais de livraison
        System.assertEquals(80.0, updatedOrder.NetAmount__c, 'NetAmount__c should be 80.0');
    }

    @isTest
    static void testMultipleOrders() {
        // Créer un compte de test
        Account testAccount = TestDataFactory.createAccount('Test Account');
        
        // Créer un produit de test
        Product2 testProduct = TestDataFactory.createProduct('Test Product', null);
        
        // Créer une entrée de Pricebook pour ce produit
        PricebookEntry testPricebookEntry = TestDataFactory.createPricebookEntry(testProduct.Id, 100.0, true);

        // Créer plusieurs commandes pour le compte de test
        List<Order> testOrders = new List<Order>();
        for (Integer i = 1; i <= 3; i++) {
            testOrders.add(TestDataFactory.createOrder(testAccount.Id, Test.getStandardPricebookId(), 'Ordered'));
        }

        // Créer des éléments de commande pour chaque commande
        List<OrderItem> testOrderItems = new List<OrderItem>{
            TestDataFactory.createOrderItem(testOrders[0].Id, testPricebookEntry.Id, 1, 100.0),
            TestDataFactory.createOrderItem(testOrders[1].Id, testPricebookEntry.Id, 1, 200.0),
            TestDataFactory.createOrderItem(testOrders[2].Id, testPricebookEntry.Id, 1, 300.0)
        };

        // Mise à jour des frais de livraison pour chaque commande
        for (Integer i = 0; i < 3; i++) {
            testOrders[i].ShipmentCost__c = (20.0 + (10 * i));
        }
        update testOrders;

        // Récupérer les commandes mises à jour
        List<Order> updatedOrders = [SELECT Id, TotalAmount, ShipmentCost__c, NetAmount__c FROM Order WHERE Id IN :testOrders];
        
        // Vérification des montants nets attendus pour chaque commande
        System.assertEquals(80.0, updatedOrders[0].NetAmount__c, 'NetAmount__c for Order 1 should be 80.0');
        System.assertEquals(170.0, updatedOrders[1].NetAmount__c, 'NetAmount__c for Order 2 should be 170.0');
        System.assertEquals(260.0, updatedOrders[2].NetAmount__c, 'NetAmount__c for Order 3 should be 260.0');
    }
}
