@isTest
public class TestCreate700Accounts {

    @isTest
    static void testCreate700Accounts() {
        // Créer 700 comptes
        List<Account> accounts = TestDataFactory.createAccounts(700, 'Test Account');

        // Vérifier que 700 comptes ont été créés
        System.assertEquals(700, accounts.size(), 'Le nombre de comptes créés doit être 700.');

        // Vérifier que les comptes ont été insérés correctement
        List<Account> insertedAccounts = [SELECT Id, Name FROM Account WHERE Name LIKE 'Test Account%'];
        System.assertEquals(700, insertedAccounts.size(), 'Le nombre de comptes insérés doit être 700.');

        // Vérifier les noms des comptes
        for (Integer i = 0; i < 700; i++) {
            System.assertEquals('Test Account ' + i, insertedAccounts[i].Name, 'Le nom du compte doit être correct.');
        }
    }
}
