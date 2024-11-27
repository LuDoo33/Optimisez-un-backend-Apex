@isTest
public class TestCalculMontant {

    @isTest
    static void testNetAmountCalculation() {
        // Créer un compte de test
        List<Account> testAccounts = TestDataFactory.createAccounts(1, 'Test Account');
        Account testAccount = testAccounts[0];

        // Créer un produit de test
        List<Product2> testProducts = TestDataFactory.createProducts(1, 'Test Product', 'FamilyA');
        Product2 testProduct = testProducts[0];

        // Créer une entrée de Pricebook pour ce produit
        List<PricebookEntry> testPricebookEntries = TestDataFactory.createPricebookEntries(testProducts, 100.0, true);
        PricebookEntry testPricebookEntry = testPricebookEntries[0];

        // Créer une commande pour le compte de test
        List<Order> testOrders = TestDataFactory.createOrders(testAccounts, Test.getStandardPricebookId(), 'Ordered');
        Order testOrder = testOrders[0];

        // Créer un élément de commande pour la commande test
        TestDataFactory.createOrderItems(testOrders, testPricebookEntries, 1, 100.0);

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
        List<Account> testAccounts = TestDataFactory.createAccounts(1, 'Test Account');
        Account testAccount = testAccounts[0];

        // Créer un produit de test
        List<Product2> testProducts = TestDataFactory.createProducts(1, 'Test Product', 'FamilyA');
        Product2 testProduct = testProducts[0];

        // Créer une entrée de Pricebook pour ce produit
        List<PricebookEntry> testPricebookEntries = TestDataFactory.createPricebookEntries(testProducts, 100.0, true);
        PricebookEntry testPricebookEntry = testPricebookEntries[0];

        // Créer plusieurs commandes pour le compte de test
        List<Order> testOrders = new List<Order>();
        for (Integer i = 0; i < 3; i++) {
            testOrders.addAll(TestDataFactory.createOrders(testAccounts, Test.getStandardPricebookId(), 'Ordered'));
        }

        // Créer des éléments de commande pour chaque commande
        List<OrderItem> testOrderItems = new List<OrderItem>{
            TestDataFactory.createOrderItems(new List<Order>{testOrders[0]}, new List<PricebookEntry>{testPricebookEntry}, 1, 100.0)[0],
            TestDataFactory.createOrderItems(new List<Order>{testOrders[1]}, new List<PricebookEntry>{testPricebookEntry}, 1, 200.0)[0],
            TestDataFactory.createOrderItems(new List<Order>{testOrders[2]}, new List<PricebookEntry>{testPricebookEntry}, 1, 300.0)[0]
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
