global class UpdateAllAccounts implements Database.Batchable<sObject>, Database.Stateful {
    
    private Integer totalRecordsProcessed = 0; // Nombre total de comptes traités
    private List<Suivi_des_Batchs__c> suiviBatchRecords = new List<Suivi_des_Batchs__c>();
    private final String notificationEmail = 'ludo024@gmail.com'; // Email de notification
    
    global Database.QueryLocator start(Database.BatchableContext info) {
        return Database.getQueryLocator(
            'SELECT Id, Name FROM Account WHERE Id IN (SELECT AccountId FROM Order WHERE Status = \'Ordered\')'
        );
    }
    
    global void execute(Database.BatchableContext info, List<Account> scope) {
        // Liste des IDs des comptes à traiter
        Set<Id> accountIds = new Map<Id, Account>(scope).keySet();
        Map<Id, Decimal> accountRevenueMap = calculateAnnualRevenue(accountIds);
        
        // Mise à jour des comptes et création des enregistrements de suivi
        List<Account> accountsToUpdate = new List<Account>();
        for (Account acc : scope) {
            if (accountRevenueMap.containsKey(acc.Id)) {
                acc.AnnualRevenue = accountRevenueMap.get(acc.Id);
                accountsToUpdate.add(acc);
                
                // Créer un enregistrement de suivi pour chaque compte
                suiviBatchRecords.add(new Suivi_des_Batchs__c(
                    Account__c = acc.Id,
                    Chiffre_d_affaire_mis_a_jour__c = accountRevenueMap.get(acc.Id)
                ));
            }
        }
        
        // Mettre à jour les comptes dans Salesforce
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
            totalRecordsProcessed += accountsToUpdate.size();
        }
    }
    
    global void finish(Database.BatchableContext info) {
        // Créer un enregistrement de suivi global pour le batch
        AsyncApexJob job = [SELECT Status, CreatedDate, CompletedDate FROM AsyncApexJob WHERE Id = :info.getJobId()];
        suiviBatchRecords.add(new Suivi_des_Batchs__c(
            Nom_du_Batch__c = 'UpdateAllAccounts',
            Date_de_Lancement__c = job.CreatedDate,
            Date_de_Fin__c = job.CompletedDate,
            Statut__c = (job.Status == 'Completed' ? 'Complété' : 'Échoué') // Modifié pour gérer les deux statuts
        ));
        
        // Insérer les enregistrements de suivi
        if (!suiviBatchRecords.isEmpty()) {
            insert suiviBatchRecords;
        }
        
        // Envoyer l'email de notification
        sendCompletionEmail();
    }
    
    private Map<Id, Decimal> calculateAnnualRevenue(Set<Id> accountIds) {
        Map<Id, Decimal> revenueMap = new Map<Id, Decimal>();
        
        // Récupérer les commandes liées aux comptes
        List<Order> orders = [
            SELECT AccountId, NetAmount__c
            FROM Order
            WHERE AccountId IN :accountIds AND Status = 'Ordered'
        ];
        
        // Calculer le chiffre d'affaires total pour chaque compte
        for (Order order : orders) {
            if (order.NetAmount__c != null) {
                Decimal totalRevenue = revenueMap.containsKey(order.AccountId) ? revenueMap.get(order.AccountId) : 0;
                revenueMap.put(order.AccountId, totalRevenue + order.NetAmount__c);
            }
        }
        
        return revenueMap;
    }
    
    private void sendCompletionEmail() {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] { notificationEmail });
        email.setSubject('Mise à jour des comptes - Résultats');
        email.setPlainTextBody(
            'Le batch de mise à jour des comptes a été exécuté avec succès.\n\n' +
            'Nombre total de comptes traités : ' + totalRecordsProcessed + '.\n\n' +
            'Cordialement,\nVotre système Salesforce.'
        );
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }
}
