global class UpdateAllAccounts implements Database.Batchable<sObject> {
    
    // Requête pour récupérer les comptes liés à des commandes avec le statut 'Ordered'
    global Database.QueryLocator start(Database.BatchableContext info) {
        return Database.getQueryLocator(
            'SELECT Id FROM Account WHERE Id IN (SELECT AccountId FROM Order WHERE Status = \'Ordered\')'
        );
    }
    
    // Traiter les comptes par lots pour calculer et mettre à jour leur chiffre d'affaires
    global void execute(Database.BatchableContext info, List<Account> scope) {
        Set<Id> accountIds = (new Map<Id, SObject>(scope)).keySet();

        // Calculer et mettre à jour le chiffre d'affaires des comptes
        if (!accountIds.isEmpty()) {
            updateAccountChiffreAffaire(accountIds);
        }
    }
    
    // Actions finales après l'exécution du batch
    global void finish(Database.BatchableContext info) {
        // Envoyer un email ou loguer un message pour indiquer la fin du traitement
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] { 'ludo024@gmail.com' });
        email.setSubject('Mise à jour des chiffres d\'affaires - Batch terminé');
        email.setPlainTextBody('Le batch de mise à jour des chiffres d\'affaires des comptes a été exécuté avec succès.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }
    
    // Méthode auxiliaire pour mettre à jour le chiffre d'affaires des comptes
    private static void updateAccountChiffreAffaire(Set<Id> accountIds) {
        // Étape 1 : Récupérer les commandes liées aux comptes concernés
        Map<Id, Decimal> accountSalesMap = new Map<Id, Decimal>();
        List<Order> relatedOrders = [
            SELECT AccountId, TotalAmount 
            FROM Order 
            WHERE AccountId IN :accountIds AND Status = 'Ordered'
        ];
        
        // Étape 2 : Calculer le chiffre d'affaires total pour chaque compte
        for (Order order : relatedOrders) {
            if (order.TotalAmount != null) {
                Decimal currentTotal = accountSalesMap.containsKey(order.AccountId)
                    ? accountSalesMap.get(order.AccountId)
                    : 0;
                accountSalesMap.put(order.AccountId, currentTotal + order.TotalAmount);
            }
        }

        // Étape 3 : Récupérer les comptes et mettre à jour leur champ 'Chiffre_d_affaire__c'
        List<Account> accountsToUpdate = [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id IN :accountIds];

        for (Account acc : accountsToUpdate) {
            Decimal updatedSales = accountSalesMap.containsKey(acc.Id) 
                ? accountSalesMap.get(acc.Id)
                : 0;
            acc.Chiffre_d_affaire__c = updatedSales;
        }

        // Mise à jour des comptes en une seule opération DML
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}
