@isTest
public class TestCreate700Accounts {

    @isTest
    static void testBatchWith700Accounts() {
        // Étape 1 : Créer des comptes avec TestDataFactory
        List<Account> accounts = TestDataFactory.createAccounts(700, 'Test Account');
        System.debug('Accounts created: ' + accounts.size());

        // Étape 2 : Créer des produits
        List<Product2> products = TestDataFactory.createProducts(1, 'Test Product', 'Test Family');
        System.debug('Products created: ' + products.size());

        // Étape 3 : Créer des entrées dans le Pricebook pour les produits
        List<PricebookEntry> pricebookEntries = TestDataFactory.createPricebookEntries(products, 100.00, true);
        System.debug('PricebookEntries created: ' + pricebookEntries.size());

        // Étape 4 : Créer des commandes pour chaque compte
        List<Order> orders = TestDataFactory.createOrders(accounts, Test.getStandardPricebookId(), 'Ordered');
        System.debug('Orders created: ' + orders.size());

        // Étape 5 : Créer des éléments de commande pour chaque commande et produit
        List<OrderItem> orderItems = TestDataFactory.createOrderItems(orders, pricebookEntries, 2, 100.00);
        System.debug('OrderItems created: ' + orderItems.size());

        // Vérification avant le batch
        System.assertEquals(700, orderItems.size(), 'Le nombre d\'éléments de commande insérés doit être 700.');

        // Simuler l'exécution du batch dans la méthode de test (sans utiliser executeBatch)
        UpdateAllAccountsBatch batch = new UpdateAllAccountsBatch();

        // Récupérer les comptes à mettre à jour (au début)
        List<Account> accountsToUpdate = [SELECT Id, Name, Chiffre_d_affaire__c FROM Account WHERE Name LIKE 'Test Account%'];
        System.debug('Accounts to update: ' + accountsToUpdate.size());

        // Vérifier que nous avons bien 700 comptes à traiter
        System.assertEquals(700, accountsToUpdate.size(), 'Il devrait y avoir 700 comptes à traiter.');

        // Exécuter le batch
        Test.startTest();
        batch.execute(null, accountsToUpdate); // Utiliser une liste d'IDs de comptes comme input
        Test.stopTest();

        // Vérifier les mises à jour des comptes
        List<Account> updatedAccounts = [SELECT Id, Name, Chiffre_d_affaire__c FROM Account WHERE Name LIKE 'Test Account%'];
        System.debug('Updated accounts: ' + updatedAccounts.size());

        // Vérifier qu'on a bien 700 comptes mis à jour
        System.assertEquals(700, updatedAccounts.size(), 'Tous les comptes doivent avoir été mis à jour.');

        // Vérification que chaque compte a bien un chiffre d'affaires mis à jour
        for (Account acc : updatedAccounts) {
            System.assertNotEquals(null, acc.Chiffre_d_affaire__c, 'Le chiffre d\'affaires doit être mis à jour pour le compte : ' + acc.Name);
            System.assert(acc.Chiffre_d_affaire__c > 0, 'Le chiffre d\'affaires doit être supérieur à zéro pour le compte : ' + acc.Name);
        }

        // Phrase de fin pour confirmer la création des 700 comptes
        System.debug('Les 700 comptes ont été créés et mis à jour avec succès.');
    }
}
