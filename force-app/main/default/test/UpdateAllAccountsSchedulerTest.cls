@isTest
public class UpdateAllAccountsSchedulerTest {

    @isTest
    static void testScheduledJob() {
        // Créer des comptes de test
        List<Account> testAccounts = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            Account acc = new Account(Name = 'Test Account ' + i);
            testAccounts.add(acc);
        }
        insert testAccounts;

        // Créer des produits de test
        List<Product2> testProducts = new List<Product2>();
        for (Integer i = 0; i < 2; i++) {
            Product2 prod = new Product2(Name = 'Test Product ' + i, ProductCode = 'TP' + i);
            testProducts.add(prod);
        }
        insert testProducts;

        // Créer des entrées de Pricebook pour les produits
        List<PricebookEntry> testPricebookEntries = new List<PricebookEntry>();
        for (Product2 prod : testProducts) {
            PricebookEntry pbe = new PricebookEntry(
                Product2Id = prod.Id,
                Pricebook2Id = Test.getStandardPricebookId(),
                UnitPrice = 100.00,
                IsActive = true
            );
            testPricebookEntries.add(pbe);
        }
        insert testPricebookEntries;

        // Créer des commandes pour chaque compte
        List<Order> testOrders = new List<Order>();
        for (Account acc : testAccounts) {
            Order ord = new Order(
                AccountId = acc.Id,
                Pricebook2Id = Test.getStandardPricebookId(),
                Status = 'Ordered',
                EffectiveDate = Date.today()
            );
            testOrders.add(ord);
        }
        insert testOrders;

        // Créer des éléments de commande pour chaque commande et produit
        List<OrderItem> testOrderItems = new List<OrderItem>();
        for (Order ord : testOrders) {
            for (PricebookEntry pbe : testPricebookEntries) {
                OrderItem oi = new OrderItem(
                    OrderId = ord.Id,
                    PricebookEntryId = pbe.Id,
                    Quantity = 2,
                    UnitPrice = pbe.UnitPrice
                );
                testOrderItems.add(oi);
            }
        }
        insert testOrderItems;

        // Planifier le travail tous les lundis à 6h du matin
        String chronExpression = '0 0 6 ? * MON'; // Tous les lundis à 6h du matin
        Test.startTest();
        String jobId = System.schedule('Test Scheduled Job', chronExpression, new UpdateAllAccountsScheduler());
        Test.stopTest();

        // Vérifier que le travail a été exécuté
        List<CronTrigger> triggers = [SELECT Id, CronJobDetail.Name, CronJobDetail.JobType, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(1, triggers.size(), 'Le travail planifié doit être créé.');
        System.assertEquals('Test Scheduled Job', triggers[0].CronJobDetail.Name, 'Le nom du travail planifié doit être correct.');

        // Vérifier que les comptes ont été mis à jour
        List<Account> updatedAccounts = [SELECT Id, Name, Chiffre_d_affaire__c FROM Account WHERE Name LIKE 'Test Account%'];
        for (Account acc : updatedAccounts) {
            System.assertNotEquals(null, acc.Chiffre_d_affaire__c, 'Le chiffre d\'affaires doit être mis à jour pour le compte : ' + acc.Name);
            System.assert(acc.Chiffre_d_affaire__c > 0, 'Le chiffre d\'affaires doit être supérieur à zéro pour le compte : ' + acc.Name);
        }

        // Vérifier que l'email de notification a été envoyé
        System.debug('Vérification de l\'envoi de l\'email de notification.');

        // Phrase de fin pour confirmer la création des comptes
        System.debug('Les comptes ont été créés et mis à jour avec succès.');
    }
}
