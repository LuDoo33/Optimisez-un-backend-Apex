global class UpdateAllAccounts implements Database.Batchable<sObject>, Database.Stateful {

    private Integer globalRecordsProcessed = 0; // Nombre total de comptes mis à jour
    private Integer globalOrdersProcessed = 0; // Nombre total de commandes traitées
    private Decimal globalRevenueUpdated = 0; // Montant total du chiffre d'affaires mis à jour
    private List<Suivi_des_Batchs__c> suiviBatchRecords = new List<Suivi_des_Batchs__c>();
    private final String notificationEmail = 'ludo024@gmail.com'; // Email de notification
    private String updatedAccountNames = ''; // Chaîne pour stocker les noms des comptes mis à jour

    global Database.QueryLocator start(Database.BatchableContext info) {
        return Database.getQueryLocator(
            'SELECT Id, Name, Chiffre_d_affaire__c FROM Account WHERE Id IN (SELECT AccountId FROM Order WHERE Status = \'Ordered\')'
        );
    }

    global void execute(Database.BatchableContext info, List<Account> scope) {
        Integer localRecordsProcessed = 0; // Compteur local pour les comptes réellement mis à jour
        Integer localOrdersProcessed = 0; // Compteur local pour les commandes réellement traitées
        Decimal localRevenueUpdated = 0; // Montant local du chiffre d'affaires mis à jour

        // Liste des IDs des comptes à traiter
        Set<Id> accountIds = new Map<Id, Account>(scope).keySet();

        // Calculer le chiffre d'affaires et traiter les commandes
        Map<Id, Decimal> accountRevenueMap = calculateAnnualRevenue(accountIds);

        // Mise à jour des comptes et création des enregistrements de suivi
        List<Account> accountsToUpdate = new List<Account>();
        for (Account acc : scope) {
            if (accountRevenueMap.containsKey(acc.Id)) {
                Decimal newRevenue = accountRevenueMap.get(acc.Id);
                if (acc.Chiffre_d_affaire__c != newRevenue) { // Vérification : mise à jour nécessaire ?
                    Decimal oldRevenue = acc.Chiffre_d_affaire__c != null ? acc.Chiffre_d_affaire__c : 0;
                    acc.Chiffre_d_affaire__c = newRevenue;
                    accountsToUpdate.add(acc);

                    // Concaténer les noms des comptes mis à jour
                    if (updatedAccountNames.length() > 0) {
                        updatedAccountNames += ', ';
                    }
                    updatedAccountNames += acc.Name;

                    // Mettre à jour le montant du chiffre d'affaires mis à jour
                    localRevenueUpdated += newRevenue - oldRevenue;

                    // Créer un enregistrement de suivi pour chaque compte réellement mis à jour
                    suiviBatchRecords.add(new Suivi_des_Batchs__c(
                        Compte__c = acc.Id,
                        Chiffre_d_affaire_mis_a_jour__c = newRevenue
                    ));
                    localRecordsProcessed++; // Incrémenter seulement pour les mises à jour effectives
                    localOrdersProcessed++; // Incrémenter pour chaque commande qui entraîne une mise à jour
                }
            }
        }

        // Mettre à jour les comptes dans Salesforce
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }

        // Mettre à jour les compteurs globaux
        globalRecordsProcessed += localRecordsProcessed;
        globalOrdersProcessed += localOrdersProcessed;
        globalRevenueUpdated += localRevenueUpdated;

        // Insérer un enregistrement de suivi pour cette exécution
        suiviBatchRecords.add(new Suivi_des_Batchs__c(
            Nom_du_Batch__c = 'UpdateAllAccounts',
            Statut__c = 'Complété',
            Nombre_Comptes_Mis_A_Jour__c = localRecordsProcessed,
            Nombre_Commandes_Traitees__c = localOrdersProcessed,
            Compte__c = updatedAccountNames,
            Montant_du_CA_mis_a_jour__c = String.valueOf(globalRevenueUpdated)
        ));
    }

    global void finish(Database.BatchableContext info) {
        // Créer un enregistrement de suivi global pour le batch
        AsyncApexJob job = [SELECT Status, CreatedDate, CompletedDate FROM AsyncApexJob WHERE Id = :info.getJobId()];
        suiviBatchRecords.add(new Suivi_des_Batchs__c(
            Nom_du_Batch__c = 'UpdateAllAccounts',
            Date_de_Lancement__c = job.CreatedDate,
            Date_de_Fin__c = job.CompletedDate,
            Statut__c = (job.Status == 'Completed' ? 'Complété' : 'Échoué'),
            Nombre_Comptes_Mis_A_Jour__c = globalRecordsProcessed,
            Nombre_Commandes_Traitees__c = globalOrdersProcessed,
            Compte__c = updatedAccountNames,
            Montant_du_CA_mis_a_jour__c = String.valueOf(globalRevenueUpdated)
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

        // Récupérer les produits commandés liés aux comptes
        List<OrderItem> orderItems = [
            SELECT Order.AccountId, UnitPrice, Quantity
            FROM OrderItem
            WHERE Order.AccountId IN :accountIds AND Order.Status = 'Ordered'
        ];

        // Calculer le chiffre d'affaires total pour chaque compte
        for (OrderItem orderItem : orderItems) {
            if (orderItem.UnitPrice != null && orderItem.Quantity != null) {
                Decimal totalRevenue = revenueMap.containsKey(orderItem.Order.AccountId) ? revenueMap.get(orderItem.Order.AccountId) : 0;
                revenueMap.put(orderItem.Order.AccountId, totalRevenue + (orderItem.UnitPrice * orderItem.Quantity));
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
            'Nombre total de comptes mis à jour : ' + globalRecordsProcessed + '.\n' +
            'Nombre total de commandes traitées : ' + globalOrdersProcessed + '.\n' +
            'Montant du CA mis à jour : ' + globalRevenueUpdated.format() + '€.\n' +
            'Comptes mis à jour : ' + updatedAccountNames + '.\n\n' +
            'Cordialement,\nVotre système Salesforce.'
        );
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }
}
