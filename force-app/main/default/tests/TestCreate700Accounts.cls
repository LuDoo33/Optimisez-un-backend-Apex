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

        // Log dans Batch_Execution_Log__c
        List<Batch_Execution_Log__c> logEntries = new List<Batch_Execution_Log__c>();
        for (Account acc : updatedAccounts) {
            Batch_Execution_Log__c logEntry = new Batch_Execution_Log__c();
            logEntry.Name = 'Batch Log ' + acc.Name; // Nom du log basé sur le compte
            logEntry.Account_Name__c = acc.Name;
            logEntry.Updated__c = acc.Chiffre_d_affaire__c; // Chiffre d'affaires mis à jour
            logEntry.Statuts__c = 'Success';  // Statut "Success" pour l'exécution réussie
            logEntry.Date__c = Date.today(); // Date d'exécution du batch
            logEntries.add(logEntry);

            // Débogage supplémentaire pour vérifier les valeurs des champs
            System.debug('Log Entry: ' + logEntry.Name + ', Account: ' + logEntry.Account_Name__c + ', Updated: ' + logEntry.Updated__c + ', Status: ' + logEntry.Statuts__c + ', Date: ' + logEntry.Date__c);
        }

        // Insérer les logs dans Batch_Execution_Log__c
        insert logEntries;
        System.debug('Log entries created: ' + logEntries.size());

        // Vérifier que les logs ont été créés
        List<Batch_Execution_Log__c> insertedLogs = [SELECT Id, Name, Account_Name__c, Updated__c, Statuts__c, Date__c FROM Batch_Execution_Log__c];
        System.assertEquals(700, insertedLogs.size(), 'Tous les logs doivent avoir été créés.');

        // Vérification supplémentaire des logs insérés
        for (Batch_Execution_Log__c log : insertedLogs) {
            System.debug('Inserted Log: ' + log.Name + ', Account: ' + log.Account_Name__c + ', Updated: ' + log.Updated__c + ', Status: ' + log.Statuts__c + ', Date: ' + log.Date__c);
            System.assertNotEquals(null, log.Account_Name__c, 'Le nom du compte doit être défini.');
            System.assertNotEquals(null, log.Updated__c, 'Le chiffre d\'affaires mis à jour doit être défini.');
            System.assertEquals('Success', log.Statuts__c, 'Le statut doit être "Success".');
            System.assertEquals(Date.today(), log.Date__c, 'La date doit être aujourd\'hui.');
        }

        // Phrase de fin pour confirmer la création des 700 comptes
        System.debug('Les 700 comptes ont été créés et mis à jour avec succès.');
    }
}
